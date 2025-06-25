import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class MapaUbicacionPage extends StatefulWidget {
  final double latitud;
  final double longitud;
  final String nombreTienda;

  const MapaUbicacionPage({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.nombreTienda,
  });

  @override
  State<MapaUbicacionPage> createState() => _MapaUbicacionPageState();
}

class _MapaUbicacionPageState extends State<MapaUbicacionPage> {
  LatLng? miUbicacion;
  List<LatLng> puntosRuta = [];
  final mapController = MapController();
  Stream<Position>? _positionStream;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _obtenerUbicacionUnaVez() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa los servicios de ubicación')),
      );
      return;
    }

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

    final position = await Geolocator.getCurrentPosition();
    final miPos = LatLng(position.latitude, position.longitude);

    setState(() {
      miUbicacion = miPos;
    });

    mapController.move(miPos, 16);
  }

  Future<void> _iniciarSeguimientoConRuta() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa los servicios de ubicación')),
      );
      return;
    }

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

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    _positionStream!.listen((position) {
      final miPos = LatLng(position.latitude, position.longitude);
      setState(() {
        miUbicacion = miPos;
      });
      mapController.move(miPos, mapController.camera.zoom);
      _calcularRuta();
    });
  }

  Future<void> _calcularRuta() async {
    if (miUbicacion == null) {
      return;
    }

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/${miUbicacion!.longitude},${miUbicacion!.latitude};${widget.longitud},${widget.latitud}?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        puntosRuta = coords.map((p) => LatLng(p[1], p[0])).toList();
      });
    }
  }

  Future<void> _mostrarInfoRuta() async {
    if (miUbicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero obtén tu ubicación')),
      );
      return;
    }

    final autoData = await _consultarRutaAuto();

    if (autoData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener datos de la ruta')),
      );
      return;
    }

    final autoTiempo = autoData['tiempo'];
    final autoDistancia = autoData['distancia'];

    final biciTiempo = autoTiempo * 2 + _variacion(30, 60);
    final pieTiempo = autoTiempo * 5 + _variacion(60, 120);

    // Mostrar en un AlertDialog
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Información de la ruta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto - Distancia: ${(autoDistancia / 1000).toStringAsFixed(2)} km, '
                      'Tiempo: ${(autoTiempo / 60).toStringAsFixed(1)} min',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.directions_bike, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bici - Distancia: ${(autoDistancia / 1000).toStringAsFixed(2)} km, '
                      'Tiempo: ${(biciTiempo / 60).toStringAsFixed(1)} min',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.directions_walk, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Caminando - Distancia: ${(autoDistancia / 1000).toStringAsFixed(2)} km, '
                      'Tiempo: ${(pieTiempo / 60).toStringAsFixed(1)} min',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _consultarRutaAuto() async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/${miUbicacion!.longitude},${miUbicacion!.latitude};${widget.longitud},${widget.latitud}?overview=false',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0];
      return {
        'distancia': route['distance'],
        'tiempo': route['duration'],
      };
    } else {
      return null;
    }
  }

  int _variacion(int min, int max) {
    final rand = Random();
    return min + rand.nextInt(max - min + 1);
  }

  @override
  Widget build(BuildContext context) {
    final puntoTienda = LatLng(widget.latitud, widget.longitud);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de ${widget.nombreTienda}'),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: puntoTienda,
          initialZoom: 16,
          maxZoom: 18,
          minZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: puntoTienda,
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
          if (puntosRuta.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: puntosRuta,
                  color: Colors.blue,
                  strokeWidth: 4,
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'posicion',
            onPressed: _obtenerUbicacionUnaVez,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'ruta',
            onPressed: _iniciarSeguimientoConRuta,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.alt_route),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'info',
            onPressed: _mostrarInfoRuta,
            backgroundColor: Colors.green,
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
