import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_precio_verdadedor_principal/providers/auth_providers.dart';
import 'mapa_ubicacion_page.dart';

class BajoPrecioScreen extends StatefulWidget {
  final int idProducto;

  const BajoPrecioScreen({super.key, required this.idProducto});

  @override
  State<BajoPrecioScreen> createState() => _BajoPrecioScreenState();
}

class _BajoPrecioScreenState extends State<BajoPrecioScreen> {
  List<dynamic> resultados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    const miLatitud = -17.783329;
    const miLongitud = -63.182140;

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token no disponible. Inicia sesión nuevamente.')),
      );
      Navigator.of(context).pop();
      return;
    }

    final url = Uri.parse(
      'http://192.168.0.11:8000/api/tienda/productos/bajo-precio?mi_latitud=$miLatitud&mi_longitud=$miLongitud&id_producto=${widget.idProducto}'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          resultados = data;
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas con el producto seleccionado'),
        backgroundColor: Colors.green,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : resultados.isEmpty
              ? const Center(child: Text('No se encontraron resultados.'))
              : ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final item = resultados[index];
                    final ubicacion = item['ubicacion'];

                    // Determinar color y etiqueta
                    Color colorCard;
                    String etiqueta;

                    if (index == 0) {
                      colorCard = Colors.green.shade100;
                      etiqueta = 'El más barato';
                    } else if (index == 1) {
                      colorCard = Colors.orange.shade100;
                      etiqueta = 'Precio accesible';
                    } else {
                      colorCard = Colors.red.shade100;
                      etiqueta = 'Puedes conseguirlo más barato';
                    }

                    return Card(
                      color: colorCard,
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              etiqueta,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre: ${item['nombre_tienda']}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Precio: ${item['precio']} Bs',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Dirección: ${ubicacion['direccion']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Distancia: ${item['distancia'].toStringAsFixed(2)} km',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapaUbicacionPage(
                                          latitud: double.parse(ubicacion['latitud']),
                                          longitud: double.parse(ubicacion['longitud']),
                                          nombreTienda: item['nombre_tienda'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Ver ubicación'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
