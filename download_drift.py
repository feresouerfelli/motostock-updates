import urllib.request
import os

print("Downloading sqlite3.wasm...")
url_wasm = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.5.0/sqlite3.wasm"
try:
    urllib.request.urlretrieve(url_wasm, "web/sqlite3.wasm")
    print("sqlite3.wasm downloaded.")
except Exception as e:
    print(f"Failed to download sqlite3.wasm: {e}")

print("Downloading drift_worker.js...")
# drift_worker.js is not officially released as a standalone file in recent versions, 
# but we can grab a known working version from an older release or compile it.
# Let's write a dummy worker or use a known URL.
url_worker = "https://raw.githubusercontent.com/simolus3/drift/main/drift/lib/web/worker.dart.js"
try:
    urllib.request.urlretrieve(url_worker, "web/drift_worker.js")
    print("drift_worker.js downloaded.")
except Exception as e:
    print(f"Failed to download drift_worker.js: {e}")
