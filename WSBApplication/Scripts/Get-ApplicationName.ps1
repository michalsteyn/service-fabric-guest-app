Param
(
    [String]
    $PublishProfileFile    
)

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
    $publishProfileFolder = (Split-Path $PublishProfileFile)
    $publishProfile.ApplicationParameterFile = [System.IO.Path]::Combine($PublishProfileFolder, $publishProfileXml.PublishProfile.ApplicationParameterFile.Path)

    return $publishProfile
}

function Get-ApplicationName
{
    Param (
		[ValidateScript({Test-Path $_ -PathType Leaf})]
		[String]
		$PublishProfileFile = '..\PublishProfiles\Local.1Node.xml'
    )

	$publishProfile = Read-PublishProfile $PublishProfileFile

    $publishProfileXml = [Xml] (Get-Content $publishProfile.ApplicationParameterFile)
    $applicatinoName =  $publishProfileXml.Application.Name
    return $applicatinoName
}

#$appName = Get-ApplicationName $PublishProfileFile
#Write-Host "Application Name: $appName"
