import math
import os
from PIL import Image

def process_image(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: {input_path} no existe.")
        return False
        
    img = Image.open(input_path)
    img = img.convert("RGBA")
    datas = img.getdata()

    newData = []
    for item in datas:
        r, g, b, a = item
        
        # En una imagen con fondo rojo (G y B bajos) y letras blancas (G y B altos),
        # el promedio de los canales verde y azul nos indica qué tan "blanco" es el pixel.
        val = (g + b) / 2.0
        
        if val < 60:
            # Fondo rojo puro -> totalmente transparente
            newData.append((0, 0, 0, 0))
        elif val > 190:
            # Letras blancas puras -> blanco opaco
            newData.append((255, 255, 255, 255))
        else:
            # Píxeles de transición (anti-aliasing)
            # Mapeamos val en el rango [60, 190] a un alpha [0, 255]
            alpha = int((val - 60) * (255.0 / (190.0 - 60.0)))
            alpha = max(0, min(255, alpha))
            
            # Pintamos de blanco con el alpha suavizado
            newData.append((255, 255, 255, alpha))

    img.putdata(newData)
    img.save(output_path, "PNG")
    print(f"Procesado con éxito (fondo rojo eliminado): {output_path}")
    return True

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(current_dir, "images.png")
    
    # Procesar y copiar a las rutas destino
    destinations = [
        os.path.join(current_dir, r"bancobcp\assets\images\bcp.png"),
        os.path.join(current_dir, r"bancobcp\assets\images\bcp_splash.png"),
        os.path.join(current_dir, r"bancobcp-para asesores\assets\images\bcp.png"),
        os.path.join(current_dir, r"bancobcp-para asesores\assets\images\bcp_splash.png")
    ]
    
    temp_output = os.path.join(current_dir, "temp_processed.png")
    if process_image(input_file, temp_output):
        for dest in destinations:
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            img_processed = Image.open(temp_output)
            img_processed.save(dest, "PNG")
            print(f"Copiado a: {dest}")
        if os.path.exists(temp_output):
            os.remove(temp_output)
