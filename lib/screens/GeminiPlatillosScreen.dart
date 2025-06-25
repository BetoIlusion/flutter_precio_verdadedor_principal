import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiPlatillosScreen extends StatefulWidget {
  const GeminiPlatillosScreen({super.key});

  @override
  State<GeminiPlatillosScreen> createState() => _GeminiPlatillosScreenState();
}

class _GeminiPlatillosScreenState extends State<GeminiPlatillosScreen> {
  final TextEditingController _ingredientesController = TextEditingController();
  String _respuesta = '';
  bool _loading = false;

  // 🔑 API Key válida para pruebas (reemplaza con la tuya si deseas)
  final String apiKey = 'AIzaSyA1kCqmQjFvlVDRqGXCZzx0uinKiJjh8wM';

  Future<void> consultarIA() async {
    final ingredientes = _ingredientesController.text.trim();

    // Validación para evitar inputs vacíos o solo comas
    if (ingredientes.isEmpty || ingredientes.split(',').every((i) => i.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingresa ingredientes válidos.')),
      );
      return;
    }

    setState(() => _loading = true);

    final prompt = """
Eres un chef profesional y creativo.
Con estos ingredientes: $ingredientes.Genera 5 recetas de platillos de comida. Para cada receta, incluye:
– Nombre del platillo  
– Lista de ingredientes con cantidades aproximadas  
– Pasos de preparación breves  
""";
 
final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'
);



    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                { "text": prompt }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;

        final texto = candidates != null && candidates.isNotEmpty
            ? candidates[0]['content']['parts'][0]['text']
            : 'No se pudo generar respuesta.';

        setState(() => _respuesta = texto);
      } else {
        print('BODY: ${response.body}');
        setState(() => _respuesta = 'Error al llamar a la IA: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _respuesta = 'Error inesperado: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sugerencias de Platillos'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Escribe los ingredientes que tienes:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _ingredientesController,
              decoration: InputDecoration(
                hintText: 'Ej: arroz, carne, tomate',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : consultarIA,
              icon: Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Consultando...' : 'Sugerir Platillos'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _respuesta,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
