#
# Deploy
# -OverrideUpgradeBehavior ForceUpgrade 
. .\Deploy-FabricApplication.ps1 -ApplicationPackagePath '..\pkg\Debug\' -PublishProfileFile '..\PublishProfiles\TestServer.xml' -OverwriteBehavior Always -UnregisterUnusedApplicationVersionsAfterUpgrade $True