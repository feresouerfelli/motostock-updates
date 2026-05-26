import os

path = "web/sqlite3.wasm"
with open(path, "rb") as f:
    data = f.read()

idx = data.find(b'\x00asm')
if idx != -1:
    print(f"Found magic word at index {idx}")
    with open(path, "wb") as f:
        f.write(data[idx:])
    print("Fixed sqlite3.wasm")
else:
    print("Magic word not found")
