import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'mapa.dart';
import 'BajoPrecioScrenn.dart';
import 'package:flutter_precio_verdadedor_principal/providers/auth_providers.dart';
import 'cambiar_contrasena_screen.dart';
import 'login_screen.dart';
import 'GeminiPlatillosScreen.dart'; // 👈 Importación agregada

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> productos = [];
  List<dynamic> productosFiltrados = [];
  bool mostrarLista = false;
  int? idProductoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token no disponible. Inicia sesión de nuevo.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.11:8000/api/producto'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productos = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _filtrarProductos(String query) {
    if (query.isEmpty) {
      setState(() {
        productosFiltrados = [];
        mostrarLista = false;
      });
      return;
    }

    final resultados = productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      return nombre.contains(query.toLowerCase());
    }).toList();

    setState(() {
      productosFiltrados = resultados;
      mostrarLista = resultados.isNotEmpty;
    });
  }

  void _buscarBajoPrecio() {
    if (idProductoSeleccionado != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BajoPrecioScreen(idProducto: idProductoSeleccionado!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un producto')),
      );
    }
  }

  void _cerrarSesion() {
    Provider.of<AuthProvider>(context, listen: false).clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Editar perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CambiarContrasenaScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu), // 👈 Ícono de platillo
              title: const Text('Ver platillos recomendados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GeminiPlatillosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                _cerrarSesion();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.shopping_cart,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Qué producto deseas buscar hoy?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Ingrese nombre del producto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _filtrarProductos,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _buscarBajoPrecio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Buscar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (mostrarLista)
              Expanded(
                child: ListView.builder(
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = productosFiltrados[index];
                    return ListTile(
                      title: Text(producto['nombre']),
                      onTap: () {
                        searchController.text = producto['nombre'];
                        setState(() {
                          idProductoSeleccionado = producto['id'];
                          mostrarLista = false;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            if (productos.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          searchController.text = producto['nombre'];
                          setState(() {
                            idProductoSeleccionado = producto['id'];
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_bag,
                              size: 40,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              producto['nombre'],
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
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
