import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

void main() async {
  print('Initializing Supabase...');
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  final supabase = Supabase.instance.client;
  
  try {
    print('Deleting all stock rows...');
    await supabase.from('stock').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    print('Stock rows deleted!');
  } catch (e) {
    print('Error deleting stock: $e');
  }

  try {
    print('Deleting all parts rows...');
    await supabase.from('parts').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    print('Parts rows deleted!');
  } catch (e) {
    print('Error deleting parts: $e');
  }

  try {
    print('Deleting all old pieces rows...');
    await supabase.from('pieces').delete().neq('id', 0);
    print('Pieces rows deleted!');
  } catch (e) {
    print('Error deleting pieces: $e');
  }

  print('Clean up complete!');
}
