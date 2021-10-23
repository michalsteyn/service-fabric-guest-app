#
# Deploy
# -OverrideUpgradeBehavior ForceUpgrade 
. .\Deploy-FabricApplication.ps1 -ApplicationPackagePath '..\pkg\Release\' -PublishProfileFile '..\PublishProfiles\TestServer.xml' -OverwriteBehavior Always -UnregisterUnusedApplicationVersionsAfterUpgrade $True