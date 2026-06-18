import json
import urllib.request
import urllib.error

# Configuración del proyecto Supabase Caja Tacna
SUPABASE_URL = "https://kxsyodhgknxtygxzlmsm.supabase.co"
SUPABASE_ANON_KEY = "sb_publishable_UvbgD8Qv9oiURc2gHU1Wpw_Sm7YauHn"

def inspect_users():
    url = f"{SUPABASE_URL}/rest/v1/perfiles?select=*"
    
    req = urllib.request.Request(url)
    req.add_header("apikey", SUPABASE_ANON_KEY)
    req.add_header("Authorization", f"Bearer {SUPABASE_ANON_KEY}")
    req.add_header("Content-Type", "application/json")
    
    print("=" * 80)
    print(f"Conectando a Supabase: {SUPABASE_URL}...")
    print("Obteniendo perfiles de usuario de 'public.perfiles'...")
    print("=" * 80)
    
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            
            if not data:
                print("\n[!] No se encontraron usuarios creados en la base de datos de perfiles.")
                print("    (Prueba a registrarte desde la app móvil o web).")
                print("=" * 80)
                return
                
            # Cabecera de la tabla
            headers = ["UUID / ID", "Nombre Completo", "Email", "Teléfono", "Es Asesor?"]
            col_widths = [38, 25, 28, 12, 10]
            
            # Dibujar cabecera
            header_line = ""
            for h, w in zip(headers, col_widths):
                header_line += h.ljust(w) + " | "
            print(header_line)
            print("-" * (sum(col_widths) + len(col_widths) * 3))
            
            # Dibujar filas
            for row in data:
                u_id = str(row.get("user_id", "N/A"))
                nombre = str(row.get("nombre_completo", "N/A"))[:23]
                email = str(row.get("email", "N/A"))[:26]
                telefono = str(row.get("telefono", "N/A"))[:11]
                es_asesor = "SÍ" if row.get("es_asesor", False) else "NO"
                
                row_line = (
                    u_id.ljust(col_widths[0]) + " | " +
                    nombre.ljust(col_widths[1]) + " | " +
                    email.ljust(col_widths[2]) + " | " +
                    telefono.ljust(col_widths[3]) + " | " +
                    es_asesor.ljust(col_widths[4]) + " | "
                )
                print(row_line)
                
            print("=" * 80)
            print(f"Total de usuarios registrados: {len(data)}")
            print("=" * 80)
            
    except urllib.error.HTTPError as e:
        print(f"\n[ERROR] Error HTTP ({e.code}): {e.reason}")
        print("Asegúrate de haber ejecutado el script SQL en Supabase para crear las tablas y perfiles.")
        print("=" * 80)
    except urllib.error.URLError as e:
        print(f"\n[ERROR] Error de red / conexión: {e.reason}")
        print("=" * 80)
    except Exception as e:
        print(f"\n[ERROR] Ocurrió un error inesperado: {str(e)}")
        print("=" * 80)

if __name__ == "__main__":
    inspect_users()
