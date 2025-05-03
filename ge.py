import os

def generate_file_map(directory, indent=""):
    file_map = ""
    for item in os.listdir(directory):
        item_path = os.path.join(directory, item)
        if os.path.isdir(item_path):
            file_map += f"{indent}{item}\n"
            file_map += generate_file_map(item_path, indent + "  ")
        elif os.path.isfile(item_path):
            file_map += f"{indent}{item}\n"
    return file_map

def save_file_map(file_map, output_file):
    with open(output_file, "w") as f:
        f.write(file_map)

if __name__ == "__main__":
    lib_directory = "lib"
    output_file = "file_map.txt"

    if os.path.exists(lib_directory) and os.path.isdir(lib_directory):
        file_map = generate_file_map(lib_directory)
        save_file_map(file_map, output_file)
        print(f"File map generated and saved to {output_file}")
    else:
        print(f"The directory '{lib_directory}' does not exist or is not a directory.")