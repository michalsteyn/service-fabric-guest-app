# Service Fabric Guest Executable Demo

## Build

A sample build script is provided, see `build.ps1`, which will do the following:

1. Build a Demo Asp.Net App and publish it to `Release\ApiService`,
2. Package the SF Application, the output directory is: `WSBDemo\WSBApplication\pkg\Debug` (This 
   cannot be easily changed)
3. Copy the Content of `Step 2` into `Release\SF`
4. Copy the `ApplicationParameters`, `PublishProfiles`, and `Scripts` to `Release\SF`

At this point the Directory `Release\SF` contains everything needed to deploy the SF Application.
In a CI/CD Pipeline the next step would be to package this folder, preferably as a NuGet Package.
The NuGet Package can then be easily uploaded to an artifact repository and integrated with Octopus Deploy.

## Deployment

Simply run the `Release\SF\Scripts\DeployLocal.ps1` to deploy this to a local dev cluster.

## Missing Steps

### Change the Manifest Version Number:

Currently the Manifest Version is 1.0.0. This limits the ability to deploy rolling updates to a prod cluster. For instance when a version 1.2.3 is currently deployed and a new service versioned 1.2.4 
is newly deployed, SF can then systematically deploy the new version.

The version of the current deployment is also displayed in Service Fabric Explorer.

NOTE: I have a script to automatically set the values in the manifest, this will be added next week.

### Reverse Proxy URL Rewriting

The demo app will run on `host:9090`, this endpoint is also visible in Service Fabric Explorer.

Once deployed navigate to: `http://localhost:9090/swagger` to open the Swagger UI.

Or invoke the service directly using: `http://localhost:9090/WeatherForecast`

**Using the SF Reverse Proxy**

In a real deployment other services can access the SF Service either using the native 
SF SDK Service Discovery, which would resolve to `http://node-ip:9090` for the service.
OR: The Service Fabric Reverse Proxy can be used.
It has the following pattern:
`http://node-ip:19081/WSBApplication/WSBService` which will route to
`http://node-ip:9090/WSBApplication/WSBService` (SF will automatically find a node where the service is running)

See: https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-reverseproxy

This clearly produces an issue as the process will not expect the two additional URL Segments: 
`/WSBApplication/WSBService` to be included in the path. Consequently the API Call will fail.

In order to fix this, the Asp.Net App needs to check for these two extra URI segments and then
to strip that out. This can most easily be done using Asp.Net Middleware.

This is probably the most significant drawback of the Reverse Proxy in the case of 
Lift-and-shift applications. 

The current demo does not include this middleware, which I will add next week.