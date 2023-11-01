import os, re

if __name__ == '__main__':
    for file in os.listdir():
        if file.endswith(".ttslua"):
            file_name = os.path.basename(file)
            os.rename(file_name, re.sub("\.ttslua", ".lua", file_name))