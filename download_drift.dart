import 'dart:io';

void main() async {
  final client = HttpClient();
  
  // Download sqlite3.wasm
  try {
    final req1 = await client.getUrl(Uri.parse('https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3/assets/sqlite3.wasm'));
    final res1 = await req1.close();
    await res1.pipe(File('web/sqlite3.wasm').openWrite());
    print('sqlite3.wasm downloaded.');
  } catch (e) {
    print('Failed to download sqlite3.wasm: $e');
  }

  // Download drift_worker.js
  try {
    final req2 = await client.getUrl(Uri.parse('https://raw.githubusercontent.com/simolus3/drift/main/drift/lib/web/worker.dart.js'));
    final res2 = await req2.close();
    await res2.pipe(File('web/drift_worker.js').openWrite());
    print('drift_worker.js downloaded.');
  } catch (e) {
    print('Failed to download drift_worker.js: $e');
  }
}
