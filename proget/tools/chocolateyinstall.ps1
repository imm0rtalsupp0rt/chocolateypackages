$ErrorActionPreference = 'Stop' # stop on all errors

#Set the location of hub.exe for command execution
$fileLocation = (Get-Command hub.exe).source

#List parameters to be passed to hub.exe during install
$PackageParameters = Get-PackageParameters
$installArgs = @("install","ProGet")


switch ($PackageParameters.Keys) {
    "TargetDirectory" {
        # The root install directory for the Inedo product.
        $installArgs += "--TargetDirectory=$($PackageParameters['TargetDirectory'])"
        # Default value: $PathCombine($SpecialWindowsPath(ProgramFiles), ProductName)
    }
    "ConnectionString" {
        # Connection string used to create and initialize the database schema.
        $installArgs += "--ConnectionString=$($PackageParameters['ConnectionString'])"
        # no default value
    }
    "DbName" {
        # Name of the SQL database to use or create. This overrides any Initial Catalog specified in the connection string.
        $installArgs += "--DbName=$($PackageParameters['DbName'])"
        # default value: ProductName
    }
    "WebServerPrefixes" {
        # Specifies the URL which is used by the integrated web server. Ignored if UseIntegratedWebServer is not true.
        $WebServerPrefixes = if(-not $PackageParameters["WebServerPrefixes"]){
            "8624"
        }
        else {
            $PackageParameters["WebServerPrefixes"]
        }
        $installArgs += "--WebServerPrefixes=$($WebServerPrefixes)"
        # default value: http://*:8624/
    }
    "ExtensionsPath" {
        # Specifies the directory where user-installed product extensions will be stored.
        $installArgs += "--ExtensionsPath=$($PackageParameters['ExtensionsPath'])"
        # default value: $PathCombine($SpecialWindowsPath(CommonApplicationData), ProductName, Extensions)
    }
    "ExtensionsTempPath" {
        # Specifies the directory where extensions are unpacked and loaded from.
        $installArgs += "--ExtensionsTempPath=$($PackageParameters['ExtensionsTempPath'])"
        # default value: $PathCombine($SpecialWindowsPath(CommonApplicationData), ProductName, ExtensionsTemp)
    }
    "LicenseKey" {
        # If specified, this license key will be written to the database instance on installation.
        $installArgs += "--LicenseKey=$($PackageParameters['LicenseKey'])"
        # no default value
    }
    "UserAccount" {
        # The name of the user account which will be used to run your Inedo product's services and/or IIS AppPool. It may be LocalSystem, NetworkService, or any domain/local account.
        $installArgs += "--UserAccount=$($PackageParameters['UserAccount'])"
        # default value: NetworkService
    }
    "UserPassword" {
        # The password of the user account specified with the UserAccount argument. Ignored if using LocalSystem or NetworkService.
        $installArgs += "--UserPassword=$($PackageParameters['UserPassword'])"
        # no default value
    }
}

if($env:IsUpgrade -or $PackageParameters['IsUpgrade']){
    $installArgs += "--IsUpgrade=true"
}

$Statements = $installArgs -Join " "

Start-ChocolateyProcessAsAdmin -Statements $Statements -ExeToRun $fileLocation

#Notify user of ProGet website once everything has been created and configured

$WebsiteRoot = 'http://localhost:{0}' -f $WebServerPrefixes

Write-Host "ProGet package installed successfully. ProGet web interface can be found at $WebsiteRoot."