import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://kxsyodhgknxtygxzlmsm.supabase.co';
  const anonKey = 'sb_publishable_UvbgD8Qv9oiURc2gHU1Wpw_Sm7YauHn';

  // 1. Iniciar sesión como user1@cajatacna.com.pe
  print('Iniciando sesión...');
  final loginRes = await http.post(
    Uri.parse('$url/auth/v1/token?grant_type=password'),
    headers: {
      'apikey': anonKey,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'email': 'user1@cajatacna.com.pe',
      'password': '123456',
    }),
  );

  if (loginRes.statusCode != 200) {
    print('Error al iniciar sesión: ${loginRes.statusCode}');
    print(loginRes.body);
    return;
  }

  final loginData = jsonDecode(loginRes.body);
  final token = loginData['access_token'];
  final userId = loginData['user']['id'];
  print('Sesión iniciada con éxito. User ID: $userId');

  final headers = {
    'apikey': anonKey,
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // 2. Consultar perfil propio
  print('\n--- TU PERFIL (user1) ---');
  final perfilRes = await http.get(Uri.parse('$url/rest/v1/perfiles?select=*'), headers: headers);
  print('Status code: ${perfilRes.statusCode}');
  print('Body: ${perfilRes.body}');

  // 3. Consultar cuentas propias
  print('\n--- TUS CUENTAS (user1) ---');
  final cuentasRes = await http.get(Uri.parse('$url/rest/v1/cuentas?select=*'), headers: headers);
  print('Status code: ${cuentasRes.statusCode}');
  print('Body: ${cuentasRes.body}');
}
