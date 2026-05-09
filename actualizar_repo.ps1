# ============================================================
#  actualizar_repo.ps1  —  Generador de lecturas.json
#  Orden de cursos controlado manualmente
# ============================================================

$basePath  = Get-Location
$exclude   = @(".git", "index.html", "lecturas.json", "actualizar_repo.ps1", "OTROS")

# ── 1. Orden explícito de cursos (agrupa y ordena los bloques) ──
$ordenCursos = @(
    # UNALM
    "CONTAMINACION ATMOSFERICA",
    "ENERGIA RENOVABLE",
    "MECANIZACION AGRICOLA",
    "RECURSOS NATURALES DEL PERU",
    # Idiomas
    "ITALIANO",
    "INGLES",
    # Otros personales
    "TECNOLOGIA",
    "DERECHO",
    "INVESTIGACION",
    "SALUD",
    # Ciencias
    "CIENCIAS DE LA ATMOSFERA",
    # General
    "CULTURA GENERAL"
)

# ── 2. Iconos por nombre de curso (MAYÚSCULAS) ──────────────────
$iconos = @{
    "CONTAMINACION ATMOSFERICA"   = "☁️"
    "ENERGIA RENOVABLE"           = "🌱"
    "MECANIZACION AGRICOLA"       = "🚜"
    "RECURSOS NATURALES DEL PERU" = "🇵🇪"
    "ITALIANO"                    = "🇮🇹"
    "INGLES"                      = "🇬🇧"
    "TECNOLOGIA"                  = "🤖"
    "DERECHO"                     = "⚖️"
    "INVESTIGACION"               = "🔬"
    "SALUD"                       = "💪"
    "CIENCIAS DE LA ATMOSFERA"    = "🌍"
    "CULTURA GENERAL"             = "🤔"
}

# ── 3. Grupos visuales (se guarda en el JSON para el index.html) ─
$grupos = @{
    "CONTAMINACION ATMOSFERICA"   = "UNALM"
    "ENERGIA RENOVABLE"           = "UNALM"
    "MECANIZACION AGRICOLA"       = "UNALM"
    "RECURSOS NATURALES DEL PERU" = "UNALM"
    "ITALIANO"                    = "IDIOMAS"
    "INGLES"                      = "IDIOMAS"
    "TECNOLOGIA"                  = "PERSONAL"
    "DERECHO"                     = "PERSONAL"
    "INVESTIGACION"               = "PERSONAL"
    "SALUD"                       = "PERSONAL"
    "CIENCIAS DE LA ATMOSFERA"    = "CIENCIAS"
    "CULTURA GENERAL"             = "GENERAL"
}

# ── 4. Escaneo de carpetas ──────────────────────────────────────
$cursosDisco = Get-ChildItem -Directory |
    Where-Object { $exclude -notcontains $_.Name }

# Indexamos por nombre en mayúsculas para búsqueda rápida
$cursoIndex = @{}
foreach ($d in $cursosDisco) {
    $cursoIndex[$d.Name.ToUpper()] = $d
}

$jsonFinal = @()

foreach ($nombre in $ordenCursos) {
    $nombreUpper = $nombre.ToUpper()

    # Si la carpeta no existe en disco, la creamos vacía en el JSON
    if (-not $cursoIndex.ContainsKey($nombreUpper)) {
        $jsonFinal += [ordered]@{
            curso      = $nombre
            icono      = if ($iconos.ContainsKey($nombreUpper)) { $iconos[$nombreUpper] } else { "📂" }
            grupo      = if ($grupos.ContainsKey($nombreUpper))  { $grupos[$nombreUpper]  } else { "OTROS"  }
            categorias = @()
            lecturas   = @()
        }
        continue
    }

    $cursoDir = $cursoIndex[$nombreUpper]
    $subDirs  = Get-ChildItem -Path $cursoDir.FullName -Directory
    $todasLasLecturas = @()

    foreach ($catDir in $subDirs) {
        $archivos = Get-ChildItem -Path $catDir.FullName -Filter "*.html"
        foreach ($file in $archivos) {
            $partes  = $file.BaseName -split " - ", 2
            $num     = if ($partes.Count -gt 1) { $partes[0].Trim() } else { $catDir.Name }
            $tit     = if ($partes.Count -gt 1) { $partes[1].Trim() } else { $file.BaseName }
            $rutaWeb = "$($cursoDir.Name)/$($catDir.Name)/$($file.Name)"

            $todasLasLecturas += [ordered]@{
                numero  = $num
                titulo  = $tit
                archivo = $rutaWeb
            }
        }
    }

    $jsonFinal += [ordered]@{
        curso      = $cursoDir.Name
        icono      = if ($iconos.ContainsKey($nombreUpper)) { $iconos[$nombreUpper] } else { "📂" }
        grupo      = if ($grupos.ContainsKey($nombreUpper))  { $grupos[$nombreUpper]  } else { "OTROS"  }
        categorias = @($subDirs.Name)
        lecturas   = $todasLasLecturas
    }
}

# ── 5. Guardar JSON ─────────────────────────────────────────────
$jsonFinal | ConvertTo-Json -Depth 10 |
    Out-File -Encoding utf8 "lecturas.json"

Write-Host ""
Write-Host "  ✅  lecturas.json actualizado — $($jsonFinal.Count) cursos" -ForegroundColor Cyan
Write-Host ""
