import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://kxsyodhgknxtygxzlmsm.supabase.co';
  const anonKey = 'sb_publishable_UvbgD8Qv9oiURc2gHU1Wpw_Sm7YauHn';

  final headers = {
    'apikey': anonKey,
    'Content-Type': 'application/json',
  };

  print('--- PERFILES ---');
  final perfilesRes = await http.get(Uri.parse('$url/rest/v1/perfiles?select=*'), headers: headers);
  print('Status code: ${perfilesRes.statusCode}');
  print('Body: ${perfilesRes.body}');

  print('\n--- CUENTAS ---');
  final cuentasRes = await http.get(Uri.parse('$url/rest/v1/cuentas?select=*'), headers: headers);
  print('Status code: ${cuentasRes.statusCode}');
  print('Body: ${cuentasRes.body}');
}
