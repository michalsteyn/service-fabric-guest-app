# Step 1: Build the App
#dotnet publish .\ApiService\ApiService.csproj -o Release\ApiService

# Step 2: Package the SF App
#dotnet publish .\WSBApplication\WSBApplication.sfproj

# Step 3: Copy the SF Artifacts to a Release Folder
$sfApp = ".\WSBApplication";
$sfRelease = ".\Release\SF"
Remove-Item -Path $sfRelease -Recurse -Force
Copy-Item -Path "$sfApp\pkg\Debug" -Destination $sfRelease -Recurse
Copy-Item -Path "$sfApp\PublishProfiles" -Destination $sfRelease -Recurse
Copy-Item -Path "$sfApp\ApplicationParameters" -Destination $sfRelease -Recurse -Force
Copy-Item -Path "$sfApp\Scripts" -Destination $sfRelease -Recurse

# Step 4: Create a NuGet Package
# Simply Package the Content of ".\Release\SF" into a NuGet Package (This can then be deployed using Octopus or On Prem Scripts)
