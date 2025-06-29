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
  bool _loading = false;
  List<String> _recetas = [];

  // API Key válida (tal como la usabas antes)
  final String apiKey = 'AIzaSyA1kCqmQjFvlVDRqGXCZzx0uinKiJjh8wM';

  Future<void> consultarIA() async {
    final ingredientes = _ingredientesController.text.trim();
    if (ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa al menos un ingrediente')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _recetas = [];
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'
    );

    final prompt = """
Genera 5 recetas fáciles y rápidas de preparar usando estos ingredientes: $ingredientes.

Cada receta debe aparecer en texto plano, sin asteriscos ni etiquetas HTML, y debe formatearse así:

Receta #1:
Nombre: Nombre del platillo
Ingredientes:
- ingrediente 1
- ingrediente 2
Pasos de la preparacion:
1. Paso uno
2. Paso dos

Deja exactamente una línea en blanco entre cada receta.
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            { 'parts': [ {'text': prompt} ] }
          ],
          'generationConfig': { 'temperature': 0.7, 'maxOutputTokens': 512 }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List<dynamic>?;
        final text = candidates != null && candidates.isNotEmpty
            ? candidates[0]['content']['parts'][0]['text'] as String
            : '';

        final recetas = text
            .split(RegExp(r"\n\s*\n"))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        setState(() => _recetas = recetas);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error ${response.statusCode}: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ingredientesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugerencias de Platillos'),
        backgroundColor: teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ingredientesController,
              decoration: const InputDecoration(
                hintText: 'Ej: arroz, papa, carne',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
              onSubmitted: (_) => consultarIA(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : consultarIA,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Generar platillos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _recetas.isEmpty
                  ? const Center(child: Text('Aquí aparecerán tus recetas'))
                  : ListView.separated(
                      itemCount: _recetas.length,
                      separatorBuilder: (_, __) => Divider(color: teal, thickness: 2),
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _recetas[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
