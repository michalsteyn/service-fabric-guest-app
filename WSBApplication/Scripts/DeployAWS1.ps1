#
# Deploy
# -OverrideUpgradeBehavior ForceUpgrade 
. .\Deploy-FabricApplication.ps1 -ApplicationPackagePath '..\' -PublishProfileFile '..\PublishProfiles\AWS1.xml' -OverwriteBehavior Always