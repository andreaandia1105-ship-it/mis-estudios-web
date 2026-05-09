# 1. Configuración de nombres e iconos
$basePath = Get-Location
$exclude = @(".git", "index.html", "lecturas.json", "actualizar_repo.ps1", "OTROS")

# Definimos los iconos (uno por línea para evitar errores de sintaxis)
$iconos = @{ 
    "ITALIANO"                 = "🇮🇹"
    "INGLES"                   = "🇬🇧"
    "DERECHO"                  = "⚖️"
    "TECNOLOGIA"               = "🤖"
    "CIENCIAS DE LA ATMOSFERA" = "🌍"
    "CULTURA GENERAL"          = "🤔"
    "SALUD"                    = "💪"
    "INVESTIGACION"            = "🔬"
    "ENERGIA RENOVABLE"        = "🌱"
    "CONTAMINACION ATMOSFERICA"= "☁️"
    "MECANIZACION AGRICOLA"    = "🚜"
    "RECURSOS NATURALES DEL PERU" = "🇵🇪"
}

$jsonFinal = @()

# 2. Empezar el escaneo de carpetas
$cursos = Get-ChildItem -Directory | Where-Object { $exclude -notcontains $_.Name }

foreach ($cursoDir in $cursos) {
    $subDirs = Get-ChildItem -Path $cursoDir.FullName -Directory
    $todasLasLecturas = @()
    
    foreach ($catDir in $subDirs) {
        $archivos = Get-ChildItem -Path $catDir.FullName -Filter "*.html"
        foreach ($file in $archivos) {
            
            # Lógica para el nombre
            $partes = $file.BaseName -split " - "
            $num = if ($partes.Count -gt 1) { $partes[0] } else { $catDir.Name }
            $tit = if ($partes.Count -gt 1) { $partes[1] } else { $file.BaseName }

            # Forzamos la barra diagonal / para que GitHub la lea bien
            $rutaWeb = "$($cursoDir.Name)/$($catDir.Name)/$($file.Name)"

            $todasLasLecturas += @{
                numero = $num.Trim()
                titulo = $tit.Trim()
                archivo = $rutaWeb
            }
        }
    }

    $jsonFinal += @{
        curso = $cursoDir.Name
        icono = if ($iconos.ContainsKey($cursoDir.Name.ToUpper())) { $iconos[$cursoDir.Name.ToUpper()] } else { "📂" }
        categorias = $subDirs.Name
        lecturas = $todasLasLecturas
    }
}

# 3. Guardar el archivo JSON en formato UTF8 para la web
$jsonFinal | ConvertTo-Json -Depth 10 | Out-File -Encoding utf8 "lecturas.json"

Write-Host "--- Escaneo completado: lecturas.json actualizado ---" -ForegroundColor Cyan