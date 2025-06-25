import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://precioverdadero.superficct.com/api/auth'; // Cambia esto por tu URL real

  Future<String?> login(String email, String password) async {
    try {
      // Preparar el cuerpo de la solicitud
      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      // Hacer la solicitud POST al endpoint de login
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Verificar el estado de la respuesta
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        if (token != null) {
          return token; // Devolver el token si existe
        } else {
          throw Exception('La respuesta no contiene un token');
        }
      } else {
        // Manejar errores según el código de estado
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Error desconocido';
        throw Exception('Error de autenticación: $errorMessage');
      }
    } catch (e) {
      // Manejar errores de red o excepciones
      throw Exception('Error al conectar con la API: $e');
    }
  }
  
}