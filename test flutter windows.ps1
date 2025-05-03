# Set the Flutter project folder
$PROJECT_PATH = "path\to\nimbus"

Set-Location -Path $PROJECT_PATH

Write-Output "Generating file map with Python script..."
$pythonScriptResult = python ge.py 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "Failed to generate file map: $pythonScriptResult"
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Output "File map generated successfully."
}

Write-Output "Cleaning Flutter project..."
$flutterCleanResult = flutter clean 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "Flutter clean failed: $flutterCleanResult"
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Output "Flutter project cleaned successfully."
}

Write-Output "Cleaning build runner files..."
$flutterCleanRunnerResult = flutter pub run build_runner clean 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "build runner clean failed: $flutterCleanRunnerResult"
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Output "build runner cleaned successfully."
}

Write-Output "Running build_runner..."
$flutterBuildResult = flutter pub run build_runner build --delete-conflicting-outputs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Output "Flutter build_runner failed: $flutterBuildResult"
    Read-Host "Press Enter to exit"
    exit 1
} else {
    Write-Output $flutterBuildResult
}

Write-Output "Starting Flutter for windows..."
Start-Process -NoNewWindow -FilePath "flutter" -ArgumentList "run -d windows" -Wait