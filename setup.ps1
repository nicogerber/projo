if (-Not (Test-Path -Path "W:\" -PathType Container)) {
    Write-Error "The drive W: does not exist and is required to setup projo."
}

$projo = "W:\projo.ps1"

if (-Not (Test-Path -Path $projo -PathType Leaf)) {
    Invoke-RestMethod https://github.com/nicogerber/projo/raw/main/projo.ps1 -o $projo
    Write-Host "The file @ [$projo] has been created."
}
else {
    Move-Item -Path $projo -Destination "W:\oldprojo.ps1"
    Invoke-RestMethod https://github.com/nicogerber/projo/raw/main/projo.ps1 -o $projo
    Write-Host "The file @ [$projo] has been created and old projo renamed to [W:\oldprojo.ps1]."
}
