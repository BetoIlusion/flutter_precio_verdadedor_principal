import 'package:flutter/material.dart';

class ManualUsuarioPage extends StatelessWidget {
  const ManualUsuarioPage({super.key});

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required List<String> bulletPoints,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: Colors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ...bulletPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(point, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1.2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📘 Manual del Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.search,
              title: '1️⃣ Búsqueda de Producto',
              description:
                  'Puedes elegir o escribir el producto que deseas buscar. El sistema validará la información y mostrará tiendas cercanas con el mejor precio.',
              bulletPoints: [
                'Selecciona o escribe un producto.',
                'El sistema buscará automáticamente en tiendas cercanas.',
                'Se priorizan resultados por precio y ubicación.',
              ],
            ),
            _buildSection(
              icon: Icons.map,
              title: '2️⃣ Uso del Mapa',
              description:
                  'Esta sección incluye tres botones que permiten interactuar con el mapa y calcular rutas.',
              bulletPoints: [
                '📍 Mostrar tu ubicación actual.',
                '🧭 Calcular la ruta desde tu ubicación hasta la tienda.',
                '🚶 Mostrar el tiempo estimado en auto, a pie o en bicicleta.',
              ],
            ),
            _buildSection(
              icon: Icons.restaurant_menu,
              title: '3️⃣ Platillos',
              description:
                  'Escribe ingredientes como "arroz", "carne", etc. y la IA sugerirá platillos con su descripción y preparación.',
              bulletPoints: [
                'Escribe uno o más ingredientes.',
                'Presiona el botón "Generar platillos".',
                'La IA mostrará platillos posibles con preparación detallada.',
              ],
            ),
            _buildSection(
              icon: Icons.health_and_safety,
              title: '4️⃣ Recetas Saludables',
              description:
                  'Indica tu condición (diabetes, perder peso, hipertensión, etc.) y obtendrás recetas saludables personalizadas.',
              bulletPoints: [
                'Escribe tu condición de salud.',
                'Presiona el botón "Generar recetas saludables".',
                'Verás una lista de platillos con ingredientes y preparación saludable.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
