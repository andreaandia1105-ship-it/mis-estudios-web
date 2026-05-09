# ============================================================
#  actualizar_repo.ps1  —  Generador de lecturas.json
# ============================================================

$basePath  = Get-Location
$exclude   = @(".git", "index.html", "lecturas.json", "actualizar_repo.ps1", "OTROS")

# 1. Orden y clasificación de los grupos
$ordenCursos = @(
    "CONTAMINACION ATMOSFERICA", "ENERGIA RENOVABLE", "MECANIZACION AGRICOLA", "RECURSOS NATURALES DEL PERU",
    "ITALIANO", "INGLES",
    "TECNOLOGIA", "DERECHO", "INVESTIGACION", "SALUD",
    "CIENCIAS DE LA ATMOSFERA", "CULTURA GENERAL"
)

$iconos = @{
    "CONTAMINACION ATMOSFERICA"   = "☁️"; "ENERGIA RENOVABLE"           = "🌱"
    "MECANIZACION AGRICOLA"       = "🚜"; "RECURSOS NATURALES DEL PERU" = "🇵🇪"
    "ITALIANO"                    = "🇮🇹"; "INGLES"                     = "🇬🇧"
    "TECNOLOGIA"                  = "🤖"; "DERECHO"                    = "⚖️"
    "INVESTIGACION"               = "🔬"; "SALUD"                      = "💪"
    "CIENCIAS DE LA ATMOSFERA"    = "🌍"; "CULTURA GENERAL"            = "🤔"
}

$gruposMap = @{
    "CONTAMINACION ATMOSFERICA"   = "UNALM"; "ENERGIA RENOVABLE"           = "UNALM"
    "MECANIZACION AGRICOLA"       = "UNALM"; "RECURSOS NATURALES DEL PERU" = "UNALM"
    "ITALIANO"                    = "IDIOMAS"; "INGLES"                    = "IDIOMAS"
    "TECNOLOGIA"                  = "PERSONAL"; "DERECHO"                  = "PERSONAL"
    "INVESTIGACION"               = "PERSONAL"; "SALUD"                    = "PERSONAL"
    "CIENCIAS DE LA ATMOSFERA"    = "CIENCIAS"; "CULTURA GENERAL"          = "GENERAL"
}

# 2. Escaneo
$cursosDisco = Get-ChildItem -Directory | Where-Object { $exclude -notcontains $_.Name }
$cursoIndex = @{}
foreach ($d in $cursosDisco) { $cursoIndex[$d.Name.ToUpper()] = $d }

$jsonFinal = @()
foreach ($nombre in $ordenCursos) {
    $nombreUpper = $nombre.ToUpper()
    if ($cursoIndex.ContainsKey($nombreUpper)) {
        $cursoDir = $cursoIndex[$nombreUpper]
        $subDirs  = Get-ChildItem -Path $cursoDir.FullName -Directory
        $lecturas = @()

        foreach ($catDir in $subDirs) {
            $archivos = Get-ChildItem -Path $catDir.FullName -Filter "*.html"
            foreach ($file in $archivos) {
                $partes = $file.BaseName -split " - ", 2
                $lecturas += [ordered]@{
                    numero  = if ($partes.Count -gt 1) { $partes[0].Trim() } else { $catDir.Name }
                    titulo  = if ($partes.Count -gt 1) { $partes[1].Trim() } else { $file.BaseName }
                    archivo = "$($cursoDir.Name)/$($catDir.Name)/$($file.Name)"
                }
            }
        }

        $jsonFinal += [ordered]@{
            curso      = $cursoDir.Name
            icono      = if ($iconos.ContainsKey($nombreUpper)) { $iconos[$nombreUpper] } else { "📂" }
            grupo      = if ($gruposMap.ContainsKey($nombreUpper)) { $gruposMap[$nombreUpper] } else { "OTROS" }
            categorias = @($subDirs.Name)
            lecturas   = $lecturas
        }
    }
}

# 3. Guardar con codificación correcta
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $basePath "lecturas.json"), ($jsonFinal | ConvertTo-Json -Depth 10), $utf8NoBOM)

Write-Host "✅ lecturas.json actualizado con grupos." -ForegroundColor Cyan