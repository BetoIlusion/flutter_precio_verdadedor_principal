import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiSaludableScreen extends StatefulWidget {
  const GeminiSaludableScreen({Key? key}) : super(key: key);

  @override
  State<GeminiSaludableScreen> createState() => _GeminiSaludableScreenState();
}

class _GeminiSaludableScreenState extends State<GeminiSaludableScreen> {
  final TextEditingController _condicionesController = TextEditingController();
  bool _loading = false;
  List<String> _recetas = [];

  // Reemplaza con tu API Key válida
  final String apiKey = 'AIzaSyA1kCqmQjFvlVDRqGXCZzx0uinKiJjh8wM';

  Future<void> _generarSaludables() async {
    final condiciones = _condicionesController.text.trim();
    if (condiciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa alguna condición o meta (p. ej. diabetes, perder peso).')),
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
Genera 3 recetas saludables y adecuadas para personas con las siguientes condiciones o metas: $condiciones.
Cada receta debe ser nutritiva, baja en azúcar y calorías, y contener ingredientes accesibles.

Formato para cada receta (texto plano, sin marcadores HTML):
Receta #n:
Nombre: ...
Ingredientes:
- ítem 1
- ítem 2
Pasos:
1. ...
2. ...

Deja una línea en blanco entre cada receta.
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [ { 'parts': [ {'text': prompt} ] } ],
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
    _condicionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teal = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Saludables'),
        backgroundColor: teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _condicionesController,
              decoration: const InputDecoration(
                hintText: 'Ej: diabetes, perder peso, hipertensión',
                labelText: 'Condición o meta',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _generarSaludables(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _generarSaludables,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Generar recetas saludables',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _recetas.isEmpty
                  ? const Center(child: Text('Aquí aparecerán las recetas'))
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
