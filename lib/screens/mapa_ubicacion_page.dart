// Código modificado para incluir el botón "Comenzar viaje" y cronómetro

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';

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

  bool viajeIniciado = false;
  int tiempoTranscurrido = 0;
  Timer? cronometro;
  String? modoViaje;
  double? tiempoEstimado;

 
  @override
  void dispose() {
    cronometro?.cancel();
    super.dispose();
  }

  Future<void> _obtenerUbicacionUnaVez() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activa los servicios de ubicación')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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
    await _obtenerUbicacionUnaVez();

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
    if (miUbicacion == null) return;

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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Información de la ruta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car),
                const SizedBox(width: 8),
                Expanded(child: Text('Auto - ${(autoTiempo / 60).toStringAsFixed(1)} min')),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.directions_bike),
                const SizedBox(width: 8),
                Expanded(child: Text('Bici - ${(biciTiempo / 60).toStringAsFixed(1)} min')),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.directions_walk),
                const SizedBox(width: 8),
                Expanded(child: Text('Pie - ${(pieTiempo / 60).toStringAsFixed(1)} min')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
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
      return {'distancia': route['distance'], 'tiempo': route['duration']};
    }
    return null;
  }

  int _variacion(int min, int max) => min + Random().nextInt(max - min + 1);

  void _iniciarViaje() async {
    if (miUbicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero obtén tu ubicación')),
      );
      return;
    }

    final autoData = await _consultarRutaAuto();
    if (autoData == null) return;

    final autoTiempo = autoData['tiempo'];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Auto'),
              onTap: () {
                Navigator.pop(context);
                _comenzarCronometro(autoTiempo);
                modoViaje = 'Auto';
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_bike),
              title: const Text('Bici'),
              onTap: () {
                Navigator.pop(context);
                _comenzarCronometro(autoTiempo * 2 + _variacion(30, 60));
                modoViaje = 'Bici';
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk),
              title: const Text('Caminando'),
              onTap: () {
                Navigator.pop(context);
                _comenzarCronometro(autoTiempo * 5 + _variacion(60, 120));
                modoViaje = 'Caminando';
              },
            ),
          ],
        );
      },
    );
  }

  void _comenzarCronometro(double segundosEstimados) {
    setState(() {
      viajeIniciado = true;
      tiempoTranscurrido = 0;
      tiempoEstimado = segundosEstimados;
    });
    cronometro?.cancel();
    cronometro = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tiempoTranscurrido++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final puntoTienda = LatLng(widget.latitud, widget.longitud);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación de ${widget.nombreTienda}'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
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
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                  if (miUbicacion != null)
                    Marker(
                      width: 60.0,
                      height: 60.0,
                      point: miUbicacion!,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
                    ),
                ],
              ),
              if (puntosRuta.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: puntosRuta, color: Colors.blue, strokeWidth: 4),
                  ],
                ),
            ],
          ),
          if (viajeIniciado)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modo: $modoViaje'),
                    Text('Tiempo estimado: ${(tiempoEstimado! / 60).toStringAsFixed(1)} min'),
                    Text('Transcurrido: ${(tiempoTranscurrido / 60).toStringAsFixed(1)} min'),
                  ],
                ),
              ),
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
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'viaje',
            onPressed: _iniciarViaje,
            backgroundColor: Colors.teal,
            child: const Icon(Icons.directions_run),
          ),
        ],
      ),
    );
  }
}
