import json
import os

def inspeccionar_repositorio():
    archivo_json = 'lecturas.json'
    
    # 1. Verificar si el archivo existe
    if not os.path.exists(archivo_json):
        print(f"❌ Error: No se encuentra el archivo {archivo_json}")
        return

    # 2. Cargar datos
    with open(archivo_json, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print("=" * 50)
    print("📊 RESUMEN ESTRATÉGICO DEL REPOSITORIO")
    print("=" * 50)

    total_archivos = 0
    
    # 3. Analizar por grupos
    for curso in data:
        nombre = curso.get('curso', 'Sin nombre')
        icono = curso.get('icono', '📂')
        grupo = curso.get('grupo', 'OTROS')
        lecturas = curso.get('lecturas', [])
        
        print(f"\n{icono} {nombre} [{grupo}]")
        print(f"   └── {len(lecturas)} archivos encontrados")
        
        total_archivos += len(lecturas)

        # Verificar si los archivos existen físicamente
        for lect in lecturas:
            ruta_relativa = lect.get('archivo')
            if not os.path.exists(ruta_relativa):
                print(f"   ⚠️  ¡AVISO! No se encuentra: {ruta_relativa}")

    print("\n" + "=" * 50)
    print(f"✅ Total de Cursos: {len(data)}")
    print(f"📚 Total de Archivos: {total_archivos}")
    print("=" * 50)

if __name__ == "__main__":
    inspeccionar_repositorio()