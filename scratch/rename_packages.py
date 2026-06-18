import os
import shutil

def rename_package(app_dir, old_pkg, new_pkg):
    kotlin_base = os.path.join(app_dir, "android", "app", "src", "main", "kotlin")
    
    # Old path
    old_path = os.path.join(kotlin_base, *old_pkg.split("."))
    old_file = os.path.join(old_path, "MainActivity.kt")
    
    if not os.path.exists(old_file):
        print(f"Error: {old_file} no existe.")
        return False
        
    # New path
    new_path = os.path.join(kotlin_base, *new_pkg.split("."))
    new_file = os.path.join(new_path, "MainActivity.kt")
    
    # Create new directories
    os.makedirs(new_path, exist_ok=True)
    
    # Read and update package name
    with open(old_file, "r", encoding="utf-8") as f:
        content = f.read()
        
    updated_content = content.replace(f"package {old_pkg}", f"package {new_pkg}")
    
    # Write to new file
    with open(new_file, "w", encoding="utf-8") as f:
        f.write(updated_content)
        
    print(f"MainActivity.kt copiado y actualizado a: {new_file}")
    
    # Remove old file
    os.remove(old_file)
    
    # Clean up empty old folders recursively
    current_dir = old_path
    while current_dir != kotlin_base:
        if os.path.exists(current_dir) and not os.listdir(current_dir):
            os.rmdir(current_dir)
            print(f"Directorio vacío eliminado: {current_dir}")
        else:
            break
        current_dir = os.path.dirname(current_dir)
        
    return True

if __name__ == "__main__":
    base_dir = r"D:\DESARROLLO DE APLICACIONES MOVILES\TEORIA\CAJA TACNA"
    
    # Client App
    print("Renombrando paquete de la app de Clientes...")
    rename_package(
        os.path.join(base_dir, "bancobcp"),
        "com.example.bancobcp",
        "pe.com.cmactacna.cajatacna"
    )
    
    # Advisor App
    print("\nRenombrando paquete de la app de Asesores...")
    rename_package(
        os.path.join(base_dir, "bancobcp-para asesores"),
        "com.example.bancobcp",
        "pe.com.cmactacna.asesores"
    )
