param(
    [Parameter(Mandatory = $true)][string]$Godot,
    [Parameter(Mandatory = $true)][string]$Output,
    [switch]$Import,
    [string]$Script = 'res://tools/sim.gd',
    [switch]$RawScriptArgs,
    [int]$TimeoutSeconds = 600,
    [string[]]$SimArgs
)
# Restrict the measurement process, not the editor or other Godot instances.
$ErrorActionPreference = 'Stop'
$arguments = @('--headless', '--single-threaded-scene', '--path', 'godot')
if ($Import) { $arguments += @('--import', '--editor', '--quit') }
else {
    $arguments += @('-s', $Script)
    if (-not $RawScriptArgs) { $arguments += '--' }
    $arguments += $SimArgs
}
$p = Start-Process -FilePath $Godot -ArgumentList $arguments -NoNewWindow -PassThru -RedirectStandardOutput $Output -RedirectStandardError ($Output + '.stderr')
# Retain the handle before waiting so Windows PowerShell preserves ExitCode.
$null = $p.Handle
$p.PriorityClass = 'Idle'
$p.ProcessorAffinity = [IntPtr]12
if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
    $p.Kill()
    throw "Godot exceeded $TimeoutSeconds seconds; measurement aborted."
}
$p.WaitForExit()
if ((Get-Content ($Output + '.stderr') -Raw) -match 'SCRIPT ERROR|Parse Error') {
    throw "Godot script errors; inspect $Output.stderr"
}
$p.Refresh()
if ($null -eq $p.ExitCode) { throw 'Godot exit code unavailable.' }
exit $p.ExitCode
