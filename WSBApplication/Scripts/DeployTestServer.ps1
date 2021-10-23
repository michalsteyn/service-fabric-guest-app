#
# Deploy
# -OverrideUpgradeBehavior ForceUpgrade 
. .\Deploy-FabricApplication.ps1 -ApplicationPackagePath '..\' -PublishProfileFile '..\PublishProfiles\TestServer.xml' -OverwriteBehavior Always