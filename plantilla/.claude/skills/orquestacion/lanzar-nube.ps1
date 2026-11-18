<#
Genera el lanzador de una sesion de Claude Code en la nube para una ficha y lo abre en una ventana
propia: `claude --cloud` exige una terminal interactiva y falla si se corre desde un proceso sin ella.

El prompt se escribe en ASCII (sin tildes) y el lanzador con BOM, para que PowerShell 5.1 lo lea bien.

Uso:
  powershell -ExecutionPolicy Bypass -File lanzar-nube.ps1 -Repo C:\ruta\repo -Id P.28 `
    -Tema "que ningun listado traiga todo" -RamaFicha docs/ficha-p28 `
    -ArchivoFicha .docs/tareas/P28-paginacion.md -Modelo claude-opus-5-5 `
    [-Base claude/p28-paginacion-abc123] [-Salida C:\carpeta] [-SoloGenerar]

-Base: para una ronda de revision, la rama de la PR revisada (sin origin/).
-SoloGenerar: escribe el lanzador y no lo abre.
#>
param(
  [Parameter(Mandatory = $true)][string]$Repo,
  [Parameter(Mandatory = $true)][string]$Id,
  [Parameter(Mandatory = $true)][string]$Tema,
  [Parameter(Mandatory = $true)][string]$RamaFicha,
  [Parameter(Mandatory = $true)][string]$ArchivoFicha,
  [ValidateSet('claude-sonnet-5-5', 'claude-opus-5-5', 'claude-fable-5-2')]
  [string]$Modelo = 'claude-opus-5-5',
  [string]$Base = '',
  [string]$Salida = $env:TEMP,
  [switch]$SoloGenerar
)
$ErrorActionPreference = 'Stop'

function ConvertTo-Ascii([string]$texto) {
  $descompuesto = $texto.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object Text.StringBuilder
  foreach ($c in $descompuesto.ToCharArray()) {
    $cat = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
    if ($cat -eq [Globalization.UnicodeCategory]::NonSpacingMark) { continue }
    if ([int]$c -lt 128) { [void]$sb.Append($c) }
  }
  return $sb.ToString()
}

$Repo = (Resolve-Path $Repo).Path
# Rama principal del repo (main o master): la que origin dice hoy, si no la que quedo registrada, y
# si no main. Sin red o sin git en el PATH de PowerShell, cae en lo siguiente en vez de cortar.
$principal = 'main'
try { git -C $Repo remote set-head origin -a *> $null } catch { }
try {
  $cabeza = git -C $Repo symbolic-ref -q --short refs/remotes/origin/HEAD
  if ($LASTEXITCODE -eq 0 -and $cabeza) { $principal = $cabeza -replace '^origin/', '' }
} catch { }
if ($Base) {
  $origen = "tu rama sale de origin/$Base (no de $principal), la PR va con base $Base, y no pusheas a esa rama ni le mergeas $principal"
} else {
  $origen = "tu rama sale de origin/$principal y la PR va contra $principal"
}
$prompt = "Ejecuta la tarea $Id ($Tema). La ficha NO esta en ${principal}: esta en la rama $RamaFicha. " +
  "Traela con: git fetch origin $RamaFicha y luego git checkout origin/$RamaFicha -- $ArchivoFicha, " +
  "y metela en tu primer commit. La ficha es el pedido completo: $origen. No toques ROADMAP.md. " +
  "Hace commits chicos y pushea despues de cada uno. Segui CLAUDE.md para la entrega en la nube."
$prompt = ConvertTo-Ascii $prompt

$nombre = 'nube-' + (($Id -replace '[^A-Za-z0-9]', '').ToLower()) + '.ps1'
$archivo = Join-Path $Salida $nombre
$linea1 = "Set-Location '" + ($Repo -replace "'", "''") + "'"
$linea2 = "claude --model $Modelo --cloud '" + ($prompt -replace "'", "''") + "'"
$contenido = $linea1 + "`r`n" + $linea2 + "`r`n"
[IO.File]::WriteAllText($archivo, $contenido, (New-Object Text.UTF8Encoding($true)))
Write-Output "Lanzador: $archivo"
Write-Output "Modelo: $Modelo"
Write-Output "Prompt: $prompt"

if (-not $SoloGenerar) {
  Start-Process powershell -ArgumentList '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $archivo + '"')
  Write-Output 'Abierto en una ventana propia.'
}
