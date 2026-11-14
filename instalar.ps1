<#
Instala el kit MetodoDeTrabajo en un repo:
  1. Copia plantilla\ al repo sin pisar nada: si el repo ya tiene CLAUDE.md o ROADMAP.md, deja la
     version del metodo al lado (CLAUDE.metodo.md, ROADMAP.metodo.md); cualquier otro archivo que ya
     exista se omite.
  2. Reemplaza {{PROYECTO}}, {{REPO}}, {{RUTA}} y {{FECHA}}.
  3. Agrega audits/ al .gitignore y, si hace falta, *.sh text eol=lf al .gitattributes.
  4. Siembra la memoria del proyecto en %USERPROFILE%\.claude\projects\<slug>\memory\ (solo los
     archivos que no existen) y suma sus lineas a MEMORY.md.
Despues: abrir Claude Code en el repo y correr /adoptar-metodo.

Uso:
  powershell -ExecutionPolicy Bypass -File instalar.ps1 -Destino "C:\ruta\al\repo" `
    [-Proyecto Nombre] [-SinMemoria] [-Simular]

-Simular: muestra lo que haria sin escribir nada.
-RaizMemoria: carpeta de proyectos de Claude Code (por defecto %USERPROFILE%\.claude\projects).
Este archivo va en ASCII: PowerShell 5.1 lee los .ps1 sin BOM como ANSI.
#>
param(
  [Parameter(Mandatory = $true)][string]$Destino,
  [string]$Proyecto,
  [switch]$SinMemoria,
  [switch]$Simular,
  [string]$RaizMemoria = (Join-Path $HOME '.claude\projects')
)
$ErrorActionPreference = 'Stop'

$kit = $PSScriptRoot
$plantilla = Join-Path $kit 'plantilla'
$utf8 = New-Object Text.UTF8Encoding($false)
$textos = @('.md', '.json', '.sh', '.ps1', '.pasos', '.yml', '.yaml', '.txt')

if (-not (Test-Path $Destino -PathType Container)) { throw "No existe la carpeta $Destino" }
# Get-Item expande los nombres cortos (USUARI~1): Claude Code arma la carpeta de memoria con la ruta larga.
$Destino = (Get-Item -LiteralPath (Resolve-Path $Destino).Path).FullName.TrimEnd('\')
if (-not $Proyecto) { $Proyecto = Split-Path $Destino -Leaf }
$fecha = Get-Date -Format 'yyyy-MM-dd'

$repo = ''
$url = ''
try { $url = (& git -C $Destino remote get-url origin 2>$null) } catch { $url = '' }
if ($url -match 'github\.com[:/]([^/]+/[^/]+?)(\.git)?$') { $repo = $Matches[1] }
if (-not $repo) {
  $repo = 'OWNER/REPO'
  Write-Warning 'El repo no tiene un remote origin de GitHub: {{REPO}} queda como OWNER/REPO (corregirlo en CLAUDE.md).'
}

$reemplazos = [ordered]@{
  '{{PROYECTO}}' = $Proyecto
  '{{REPO}}'     = $repo
  '{{RUTA}}'     = $Destino
  '{{FECHA}}'    = $fecha
}

function Copiar-Archivo([string]$origen, [string]$destino) {
  if ($Simular) { return }
  $carpeta = Split-Path $destino -Parent
  if (-not (Test-Path $carpeta)) { New-Item -ItemType Directory -Force $carpeta | Out-Null }
  $ext = [IO.Path]::GetExtension($origen).ToLower()
  if ($textos -contains $ext) {
    $texto = [IO.File]::ReadAllText($origen, $utf8)
    foreach ($k in $reemplazos.Keys) { $texto = $texto.Replace($k, $reemplazos[$k]) }
    if ($ext -eq '.ps1') {
      [IO.File]::WriteAllText($destino, $texto, (New-Object Text.UTF8Encoding($true)))
    } else {
      [IO.File]::WriteAllText($destino, $texto, $utf8)
    }
  } else {
    Copy-Item $origen $destino
  }
}

# --- 1 y 2: plantilla -------------------------------------------------------------------------------
$creados = New-Object System.Collections.ArrayList
$alLado = New-Object System.Collections.ArrayList
$omitidos = New-Object System.Collections.ArrayList
# Si el metodo ya estaba instalado, su CLAUDE.md y su ROADMAP.md son los del metodo: no se duplican.
$yaInstalado = (Test-Path (Join-Path $Destino '.claude\skills\compuerta\SKILL.md')) -or
  (Test-Path (Join-Path $Destino '.claude\skills\organizar-proyecto\SKILL.md'))
foreach ($f in (Get-ChildItem $plantilla -Recurse -File -Force)) {
  $rel = $f.FullName.Substring($plantilla.Length + 1)
  $dst = Join-Path $Destino $rel
  if (Test-Path $dst) {
    if (-not $yaInstalado -and (@('CLAUDE.md', 'ROADMAP.md') -contains $rel)) {
      $dst = $dst -replace '\.md$', '.metodo.md'
      if (Test-Path $dst) { [void]$omitidos.Add($rel); continue }
      [void]$alLado.Add($rel)
    } else {
      [void]$omitidos.Add($rel)
      continue
    }
  } else {
    [void]$creados.Add($rel)
  }
  Copiar-Archivo $f.FullName $dst
}

# --- 3: .gitignore ----------------------------------------------------------------------------------
$gitignore = Join-Path $Destino '.gitignore'
$tieneAudits = (Test-Path $gitignore) -and (Select-String -Path $gitignore -Pattern '^/?audits/?\s*$' -Quiet)
if (-not $tieneAudits) {
  if (-not $Simular) {
    $bloque = "`n# Informes de auditoria (citan vulnerabilidades con rutas concretas)`n/audits/`n"
    if (Test-Path $gitignore) {
      [IO.File]::AppendAllText($gitignore, $bloque, $utf8)
    } else {
      [IO.File]::WriteAllText($gitignore, $bloque.TrimStart(), $utf8)
    }
  }
  Write-Output '.gitignore: se agrega /audits/'
}

# --- 3b: .gitattributes: los .sh con LF tambien en los clones de Windows -----------------------------
$gitattributes = Join-Path $Destino '.gitattributes'
$cubreSh = (Test-Path $gitattributes) -and (Select-String -Path $gitattributes -Pattern '^\*(\.sh)?\s.*eol=lf' -Quiet)
if (-not $cubreSh) {
  if (-not $Simular) {
    $bloque = "`n# Scripts de bash del metodo: LF tambien en Windows`n*.sh text eol=lf`n"
    if (Test-Path $gitattributes) {
      [IO.File]::AppendAllText($gitattributes, $bloque, $utf8)
    } else {
      [IO.File]::WriteAllText($gitattributes, $bloque.TrimStart(), $utf8)
    }
  }
  Write-Output '.gitattributes: se agrega *.sh text eol=lf'
}

# --- 4: memoria del proyecto ------------------------------------------------------------------------
$memCreados = New-Object System.Collections.ArrayList
$mem = ''
if (-not $SinMemoria) {
  $slug = $Destino -replace '[^A-Za-z0-9]', '-'
  $mem = Join-Path (Join-Path $RaizMemoria $slug) 'memory'
  if (-not $Simular -and -not (Test-Path $mem)) { New-Item -ItemType Directory -Force $mem | Out-Null }
  foreach ($f in (Get-ChildItem (Join-Path $kit 'memoria') -File)) {
    if ($f.Name -eq 'MEMORY.md') { continue }
    $dst = Join-Path $mem $f.Name
    if (Test-Path $dst) { continue }
    Copiar-Archivo $f.FullName $dst
    [void]$memCreados.Add($f.Name)
  }
  # Indice: solo las lineas de los archivos recien creados.
  $lineas = [IO.File]::ReadAllLines((Join-Path $kit 'memoria\MEMORY.md'), $utf8) | Where-Object {
    $_ -match '\]\(([^)]+)\)' -and $memCreados -contains $Matches[1]
  } | ForEach-Object {
    $l = $_
    foreach ($k in $reemplazos.Keys) { $l = $l.Replace($k, $reemplazos[$k]) }
    $l
  }
  if ($lineas -and -not $Simular) {
    $indice = Join-Path $mem 'MEMORY.md'
    $texto = ($lineas -join "`n") + "`n"
    if (Test-Path $indice) {
      $actual = [IO.File]::ReadAllText($indice, $utf8)
      if ($actual.Length -gt 0 -and -not $actual.EndsWith("`n")) { $texto = "`n" + $texto }
      [IO.File]::AppendAllText($indice, $texto, $utf8)
    } else {
      [IO.File]::WriteAllText($indice, $texto, $utf8)
    }
  }
}

# --- Resumen ----------------------------------------------------------------------------------------
if ($Simular) { Write-Output '(simulacion: no se escribio nada)' }
Write-Output "Proyecto: $Proyecto  Repo: $repo  Carpeta: $Destino"
Write-Output ("Creados en el repo: {0}" -f $creados.Count)
$creados | ForEach-Object { Write-Output "  + $_" }
if ($alLado.Count) {
  Write-Output 'Ya existian; la version del metodo queda al lado como *.metodo.md (la fusiona /adoptar-metodo):'
  $alLado | ForEach-Object { Write-Output "  ~ $_" }
}
if ($omitidos.Count) {
  Write-Output 'Ya existian y no se tocaron:'
  $omitidos | ForEach-Object { Write-Output "  = $_" }
}
if (-not $SinMemoria) {
  Write-Output "Memoria: $mem"
  $memCreados | ForEach-Object { Write-Output "  + $_" }
}
Write-Output ''
Write-Output 'Siguiente paso: abrir Claude Code en el repo y escribir /adoptar-metodo'
