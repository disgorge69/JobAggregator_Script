# Job Aggregator Script - Configurable Template

## Instructions

Key Features:
Easy Configuration Section at the top where you can modify:

Job title (currently set to "Soutien informatique")
Location (Trois-Rivières, Québec)
Search radius
Alternative search terms

Pre-configured Job Sites for the Quebec/Canadian market:

Indeed Canada
Emploi Québec
Job Bank Canada
LinkedIn Jobs
Monster Canada
Jobboom

Generates an HTML Report with:

All job search links in one place
Clean, professional layout in French
Clickable links that open in new tabs
Timestamp and search parameters

How to Use:

Save the script as JobAggregator.ps1
Run it in PowerShell: .\JobAggregator.ps1
The script creates a JobSearchResults folder with an HTML file
The HTML file opens automatically in your browser

Easy Modifications:

Add new job sites: Add entries to the $JobSites array
Change location: Modify $Location and $Province variables
Enable alternative searches: Uncomment the section at the bottom
Disable sites: Set Enabled = $false for any site
Change job titles: Modify $JobTitle or add to $AlternativeSearchTerms
