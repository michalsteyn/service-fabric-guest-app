
<#
.SYNOPSIS 
Deploys a Service Fabric application type to a cluster.

.DESCRIPTION
This script deploys a Service Fabric application type to a cluster.  It is invoked by Visual Studio when deploying a Service Fabric Application project.

.NOTES
WARNING: This script file is invoked by Visual Studio.  Its parameters must not be altered but its logic can be customized as necessary.

.PARAMETER PublishProfileFile
Path to the file containing the publish profile.

.PARAMETER $ApplicationName
The Service Fabric application name.

.PARAMETER UseExistingClusterConnection
Indicates that the script should make use of an existing cluster connection that has already been established in the PowerShell session.  The cluster connection parameters configured in the publish profile are ignored.

.PARAMETER SecurityToken
A security token for authentication to cluster management endpoints. Used for silent authentication to clusters that are protected by Azure Active Directory.

.EXAMPLE
. Scripts\Remove-FabricApplication.ps1 -$ApplicationName 'fabric:/FrequentFlyer' -PublishProfileFile '..\PublishProfiles\Local.1Node.xml'

Removed the Service Fabric Application
#>

Param
(
    [String]
    $PublishProfileFile,

    [String]
    $ApplicationName,
   

    [Switch]
    $UseExistingClusterConnection,

    [String]
    $SecurityToken
)

Write-Host $PublishProfileFile

. .\Get-ApplicationName.ps1 -PublishProfileFile $PublishProfileFile


function Read-XmlElementAsHashtable
{
    Param (
        [System.Xml.XmlElement]
        $Element
    )

    $hashtable = @{}
    if ($Element.Attributes)
    {
        $Element.Attributes | 
            ForEach-Object {
                $boolVal = $null
                if ([bool]::TryParse($_.Value, [ref]$boolVal)) {
                    $hashtable[$_.Name] = $boolVal
                }
                else {
                    $hashtable[$_.Name] = $_.Value
                }
            }
    }

    return $hashtable
}

function Read-PublishProfile
{
    Param (
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [String]
        $PublishProfileFile
    )

    $publishProfileXml = [Xml] (Get-Content $PublishProfileFile)
    $publishProfile = @{}

    $publishProfile.ClusterConnectionParameters = Read-XmlElementAsHashtable $publishProfileXml.PublishProfile.Item("ClusterConnectionParameters")
    $publishProfile.UpgradeDeployment = Read-XmlElementAsHashtable $publishProfileXml.PublishProfile.Item("UpgradeDeployment")

    if ($publishProfileXml.PublishProfile.Item("UpgradeDeployment"))
    {
        $publishProfile.UpgradeDeployment.Parameters = Read-XmlElementAsHashtable $publishProfileXml.PublishProfile.Item("UpgradeDeployment").Item("Parameters")
        if ($publishProfile.UpgradeDeployment["Mode"])
        {
            $publishProfile.UpgradeDeployment.Parameters[$publishProfile.UpgradeDeployment["Mode"]] = $true
        }
    }

    $publishProfileFolder = (Split-Path $PublishProfileFile)
    $publishProfile.ApplicationParameterFile = [System.IO.Path]::Combine($PublishProfileFolder, $publishProfileXml.PublishProfile.ApplicationParameterFile.Path)

    return $publishProfile
}
$ApplicationName = Get-ApplicationName $PublishProfileFile

$LocalFolder = (Split-Path $MyInvocation.MyCommand.Path)

if (!$PublishProfileFile)
{
    $PublishProfileFile = "$LocalFolder\..\PublishProfiles\Local.xml"
}

$publishProfile = Read-PublishProfile $PublishProfileFile

if (-not $UseExistingClusterConnection)
{
    $ClusterConnectionParameters = $publishProfile.ClusterConnectionParameters
    if ($SecurityToken)
    {
        $ClusterConnectionParameters["SecurityToken"] = $SecurityToken
    }

    try
    {
        Write-Host "Connecting to: "
        $ClusterConnectionParameters

        [void](Connect-ServiceFabricCluster @ClusterConnectionParameters)
        $global:clusterConnection = $clusterConnection 
    }
    catch [System.Fabric.FabricObjectClosedException]
    {
        Write-Warning "Service Fabric cluster may not be connected."
        throw
    }
}

$RegKey = "HKLM:\SOFTWARE\Microsoft\Service Fabric SDK"
$ModuleFolderPath = (Get-ItemProperty -Path $RegKey -Name FabricSDKPSModulePath).FabricSDKPSModulePath
Import-Module "$ModuleFolderPath\ServiceFabricSDK.psm1"

Remove-ServiceFabricApplication -ApplicationName $ApplicationName -Force
#Remove-ServiceFabricApplicationType -ApplicationTypeName FrequentFlyerType