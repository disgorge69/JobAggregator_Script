# ============================================================================
# Job Aggregator Script - Configurable Template
# ============================================================================
# Purpose: Aggregates job listings from multiple websites
# Author: Disgorge with Claude Ai
# Date: December 2025
# ============================================================================

# ============================================================================
# CONFIGURATION SECTION - Modify these variables for your needs
# ============================================================================

# Job search parameters
$JobTitle = "Soutien informatique"   # Change to your desired job title
$Location = "Montréal"               # Your city
$Province = "Québec"                 # Your province
$Radius = "50"                       # Search radius in km

# Alternative search terms (used as fallback or additional searches)
$AlternativeSearchTerms = @(
    "IT Support",
    "Technicien informatique",
    "Analyste informatique",
    "Support technique"
)

# ============================================================================
# JOB SITES CONFIGURATION
# ============================================================================
# Add or remove job sites here. Each site has a name and URL template.
# Use {JOBTITLE}, {LOCATION}, {PROVINCE}, {RADIUS} as placeholders

$JobSites = @(
    @{
        Name = "Indeed Canada"
        URL = "https://ca.indeed.com/jobs?q={JOBTITLE}&l={LOCATION}%2C+{PROVINCE}&radius={RADIUS}"
        Enabled = $true
    },
    @{
        Name = "Emploi Québec"
        URL = "https://placement.emploiquebec.gouv.qc.ca/mbe/ut/recherchemploi/rechoffreempl.asp?mtcle={JOBTITLE}&muncp={LOCATION}&CL=french"
        Enabled = $true
    },
    @{
        Name = "Job Bank Canada"
        URL = "https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring={JOBTITLE}&locationstring={LOCATION}%2C+{PROVINCE}"
        Enabled = $true
    },
    @{
        Name = "LinkedIn Jobs"
        URL = "https://www.linkedin.com/jobs/search/?keywords={JOBTITLE}&location={LOCATION}%2C+{PROVINCE}"
        Enabled = $true
    },
    @{
        Name = "Monster Canada"
        URL = "https://www.monster.ca/jobs/search?q={JOBTITLE}&where={LOCATION}__2C-{PROVINCE}"
        Enabled = $true
    },
    @{
        Name = "Workopolis"
        URL = "https://www.workopolis.com/jobsearch/find-jobs?ak={JOBTITLE}&l={LOCATION}%2C+{PROVINCE}"
        Enabled = $false  # Note: Workopolis may be defunct, set to false by default
    },
    @{
        Name = "Jobboom"
        URL = "https://www.jobboom.com/recherche/emplois?d=50&keywords={JOBTITLE}&location={LOCATION}"
        Enabled = $true
    }
)

# ============================================================================
# OUTPUT CONFIGURATION
# ============================================================================

$OutputFile = "JobListings_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').html"
$OutputDirectory = "$PSScriptRoot\JobSearchResults"
$OpenInBrowser = $true  # Set to $false if you don't want to auto-open the results

# ============================================================================
# FUNCTIONS
# ============================================================================

function Format-URLParameter {
    param([string]$Text)
    # URL encode the text
    return [System.Web.HttpUtility]::UrlEncode($Text)
}

function Build-JobSearchURL {
    param(
        [string]$Template,
        [string]$JobTitle,
        [string]$Location,
        [string]$Province,
        [string]$Radius
    )
    
    $url = $Template
    $url = $url -replace '\{JOBTITLE\}', (Format-URLParameter $JobTitle)
    $url = $url -replace '\{LOCATION\}', (Format-URLParameter $Location)
    $url = $url -replace '\{PROVINCE\}', (Format-URLParameter $Province)
    $url = $url -replace '\{RADIUS\}', $Radius
    
    return $url
}

function Create-HTMLReport {
    param(
        [array]$Sites,
        [string]$SearchTitle,
        [string]$SearchLocation
    )
    
    $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Résultats de recherche d'emploi - $SearchTitle</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .search-info {
            background-color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .job-site {
            background-color: white;
            margin: 15px 0;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .job-site:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .site-name {
            font-size: 1.3em;
            color: #2980b9;
            margin-bottom: 10px;
            font-weight: bold;
        }
        .search-link {
            display: inline-block;
            background-color: #3498db;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 10px;
            transition: background-color 0.3s;
        }
        .search-link:hover {
            background-color: #2980b9;
        }
        .url-display {
            font-size: 0.85em;
            color: #7f8c8d;
            word-break: break-all;
            margin-top: 10px;
        }
        .timestamp {
            text-align: right;
            color: #95a5a6;
            font-style: italic;
            margin-top: 20px;
        }
        .stats {
            background-color: #3498db;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <h1>🔍 Résultats de recherche d'emploi</h1>
    
    <div class="search-info">
        <strong>Poste recherché:</strong> $SearchTitle<br>
        <strong>Lieu:</strong> $SearchLocation<br>
        <strong>Date de recherche:</strong> $(Get-Date -Format 'dddd, MMMM dd, yyyy HH:mm:ss')
    </div>
    
    <div class="stats">
        <strong>Nombre de sites de recherche:</strong> $($Sites.Count)
    </div>
"@

    foreach ($site in $Sites) {
        $html += @"
    <div class="job-site">
        <div class="site-name">📌 $($site.Name)</div>
        <a href="$($site.URL)" target="_blank" class="search-link">Voir les offres d'emploi →</a>
        <div class="url-display">$($site.URL)</div>
    </div>
"@
    }

    $html += @"
    <div class="timestamp">
        Généré le $(Get-Date -Format 'yyyy-MM-dd à HH:mm:ss')
    </div>
</body>
</html>
"@

    return $html
}

# ============================================================================
# MAIN SCRIPT EXECUTION
# ============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Job Aggregator Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Load required assembly for URL encoding
Add-Type -AssemblyName System.Web

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    Write-Host "Created output directory: $OutputDirectory" -ForegroundColor Green
}

# Build URLs for each enabled job site
$ActiveSites = @()
foreach ($site in $JobSites) {
    if ($site.Enabled) {
        $url = Build-JobSearchURL -Template $site.URL -JobTitle $JobTitle -Location $Location -Province $Province -Radius $Radius
        $ActiveSites += @{
            Name = $site.Name
            URL = $url
        }
        Write-Host "✓ Prepared search for: $($site.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Active job sites: $($ActiveSites.Count)" -ForegroundColor Yellow
Write-Host ""

# Generate HTML report
$htmlContent = Create-HTMLReport -Sites $ActiveSites -SearchTitle $JobTitle -SearchLocation "$Location, $Province"
$fullOutputPath = Join-Path $OutputDirectory $OutputFile
$htmlContent | Out-File -FilePath $fullOutputPath -Encoding UTF8

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Report generated successfully!" -ForegroundColor Green
Write-Host "Location: $fullOutputPath" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan

# Open in default browser
if ($OpenInBrowser) {
    Write-Host ""
    Write-Host "Opening report in default browser..." -ForegroundColor Cyan
    Start-Process $fullOutputPath
}

# ============================================================================
# OPTIONAL: Generate searches for alternative terms
# ============================================================================
# Uncomment this section if you want to generate additional searches


Write-Host ""
Write-Host "Generating alternative searches..." -ForegroundColor Cyan
foreach ($altTerm in $AlternativeSearchTerms) {
    $altOutputFile = "JobListings_$($altTerm -replace ' ','_')_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').html"
    $altSites = @()
    foreach ($site in $JobSites) {
        if ($site.Enabled) {
            $url = Build-JobSearchURL -Template $site.URL -JobTitle $altTerm -Location $Location -Province $Province -Radius $Radius
            $altSites += @{
                Name = $site.Name
                URL = $url
            }
        }
    }
    $altHtml = Create-HTMLReport -Sites $altSites -SearchTitle $altTerm -SearchLocation "$Location, $Province"
    $altFullPath = Join-Path $OutputDirectory $altOutputFile
    $altHtml | Out-File -FilePath $altFullPath -Encoding UTF8
    Write-Host "✓ Created search for: $altTerm" -ForegroundColor Green
}


Write-Host ""
Write-Host "Script completed!" -ForegroundColor Green
