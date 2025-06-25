import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapaInputPage extends StatefulWidget {
  const MapaInputPage({super.key});

  @override
  State<MapaInputPage> createState() => _MapaInputPageState();
}

class _MapaInputPageState extends State<MapaInputPage> {
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  LatLng? punto;        // Punto manual
  LatLng? miUbicacion;  // Punto de ubicación actual

  final mapController = MapController(); // Controlador para mover el mapa

  Future<void> obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio está activo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa los servicios de ubicación')),
      );
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de ubicación denegado permanentemente')),
      );
      return;
    }

    // Obtener posición
    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      miUbicacion = LatLng(position.latitude, position.longitude);
      mapController.move(miUbicacion!, 17);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa con OpenStreetMap'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final lat = double.tryParse(latController.text);
                    final lng = double.tryParse(lngController.text);
                    if (lat != null && lng != null) {
                      setState(() {
                        punto = LatLng(lat, lng);
                        mapController.move(punto!, 15);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coordenadas no válidas')),
                      );
                    }
                  },
                  child: const Text('Mostrar'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: obtenerUbicacionActual,
            child: const Text('Ubicación actual'),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(0, 0),
                initialZoom: 3,
                maxZoom: 18,
                minZoom: 3,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (punto != null)
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: punto!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    if (miUbicacion != null)
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: miUbicacion!,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
