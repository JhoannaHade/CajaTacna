import os
import re

dirs_to_process = [
    r"C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp",
    r"C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp-para asesores"
]

replacements = [
    (re.compile(r'Banco BCP', re.IGNORECASE), 'Caja Tacna'),
    (re.compile(r'banco bcp', re.IGNORECASE), 'caja tacna'),
    (re.compile(r'bancobcp', re.IGNORECASE), 'cajatacna'),
    (re.compile(r'BancoBcp'), 'CajaTacna'),
    (re.compile(r'\bBCP\b'), 'CAJATACNA'),
    (re.compile(r'\bbcp\b'), 'cajatacna'),
]

exclude_dirs = {'.git', 'build', '.dart_tool', 'Pods'}

def process_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        return False # Skip non-text or binary files

    original_content = content
    for pattern, repl in replacements:
        content = pattern.sub(repl, content)

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    modified_count = 0
    for d in dirs_to_process:
        for root, dirs, files in os.walk(d):
            # modify dirs in-place to skip excluded directories
            dirs[:] = [dir_name for dir_name in dirs if dir_name not in exclude_dirs]
            
            for file in files:
                # skip some known binaries just in case
                if file.endswith(('.png', '.jpg', '.jpeg', '.zip', '.exe', '.dll', '.so', '.dylib', '.ico')):
                    continue
                
                filepath = os.path.join(root, file)
                if process_file(filepath):
                    print(f"Modified: {filepath}")
                    modified_count += 1
                    
    print(f"Total files modified: {modified_count}")

if __name__ == "__main__":
    main()
