#Variables
$root = Split-Path -parent $MyInvocation.MyCommand.Definition
$nuspec = Join-Path $root -ChildPath 'proget.nuspec'
#functions
function Get-ProGetMetadata {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $url = "https://my.inedo.com/downloads/installers?Product=ProGet"
    )
    #Go fetch the page HTML
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing

    #Parse and capture the table with all the data
    $Null = $response.Content -match '(?<table><table.*?>(.*?)<\/table>)'
    $table = $Matches.table

    #Capture the first row of the table, that's all we care about
    $rowMatcher = '(?<row><tr[^>]*>((?!<th>).)*?<\/tr>)'
    $null = $table -match $rowMatcher
    $rows = $matches.row

    #parse the row for actual values'
    $regex = '<tr[^>]*>\s*<td[^>]*>[^<]*<\/td>\s*<td[^>]*><a[^>]*>(?<version>.*?)<\/a><\/td>\s*<td[^>]*>.*?<\/td>\s*<td[^>]*><a[^>]*href="(?<downloadUrl>[^"]*cdn\.inedo\.com[^"]*)".*?<\/a>.*?<\/td>'
    $null = $rows -match $regex

    $Version = $Matches.version
    $downloadUrl = $Matches.downloadUrl

    [PSCustomObject]@{
        Version     = $version.Trim()
        DownloadUrl = $downloadUrl.Trim()
    }
}

function global:au_GetLatest {
    $LatestRelease = Get-ProGetMetadata

    @{
        Version      = $LatestRelease.version
    }
}

function global:au_SearchReplace {
    @{
        "proget.nuspec" = @{
            "(\<version\>).*?(\</version\>)" = "`$1$($Latest.version)`$2"
        }
    }
}

#Execution
Write-Host "Updating: $nuspec" -ForegroundColor Yellow
update -ChecksumFor none -NoReadme