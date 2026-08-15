# Determinism check: run run_all twice from a clean state and compare the SHA256
# of results/matlab_verifikimi.json. Appends after every step so partial progress
# survives an interruption. Run ONE MATLAB instance at a time: under a single-seat
# licence a second instance fails to start and the check reports a spurious mismatch.
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File matlab/determinism_check.ps1
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Split-Path -Parent $here
$res = Join-Path $repo 'results'
$matlab = 'C:\Program Files\MATLAB\R2026a\bin\matlab.exe'
if (-not (Test-Path $matlab)) { $matlab = (Get-Command matlab).Source }
$json = Join-Path $res 'matlab_verifikimi.json'
$out = Join-Path $res 'determinism_check.txt'
if (-not (Test-Path $res)) { New-Item -ItemType Directory -Force $res | Out-Null }
"Determinism check of the MATLAB reproduction package" | Out-File -Encoding utf8 $out
"host: $env:COMPUTERNAME | started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -Encoding utf8 -Append $out
$hashes = @()
foreach ($run in 1, 2) {
    Get-ChildItem $res -Filter 'm0*_rez.mat' -ErrorAction SilentlyContinue | Remove-Item -Force
    if (Test-Path $json) { Remove-Item $json -Force }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    & $matlab -sd $here -batch "run_all" | Out-File -Encoding utf8 (Join-Path $res "run_all_log_run$run.txt")
    $code = $LASTEXITCODE
    $sw.Stop()
    if (-not (Test-Path $json)) {
        "run ${run}: FAILED after $([math]::Round($sw.Elapsed.TotalSeconds)) s, exit $code, no verification file written." |
            Out-File -Encoding utf8 -Append $out
        "RESULT: INCONCLUSIVE. A run did not complete; see run_all_log_run$run.txt." |
            Out-File -Encoding utf8 -Append $out
        Get-Content $out
        exit 1
    }
    $h = (Get-FileHash $json -Algorithm SHA256).Hash
    $hashes += $h
    "run ${run}: wall $([math]::Round($sw.Elapsed.TotalSeconds)) s | exit $code | SHA256(results/matlab_verifikimi.json) = $h" |
        Out-File -Encoding utf8 -Append $out
}
if ($hashes[0] -eq $hashes[1]) {
    "RESULT: identical. The package is deterministic under its fixed seeds." | Out-File -Encoding utf8 -Append $out
} else {
    "RESULT: DIFFERENT. The package is not deterministic; investigate before citing." | Out-File -Encoding utf8 -Append $out
}
Get-Content $out
