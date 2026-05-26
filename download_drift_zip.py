import urllib.request
import zipfile
import os

zip_url = "https://github.com/simolus3/drift/releases/download/drift-2.20.2/drift-2.20.2.zip"
zip_path = "drift.zip"

print("Downloading drift zip...")
urllib.request.urlretrieve(zip_url, zip_path)

print("Extracting...")
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall("drift_extracted")

print("Moving files...")
os.rename("drift_extracted/sqlite3.wasm", "web/sqlite3.wasm")
os.rename("drift_extracted/drift_worker.js", "web/drift_worker.js")

print("Done!")
