import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../models/geofence.dart';
import '../core/theme.dart';

/// Dialog para crear o editar una ubicación (geofence)
class LocationFormDialog extends StatefulWidget {
  final Geofence? geofence; // Si es null, es creación; si no, es edición

  const LocationFormDialog({
    super.key,
    this.geofence,
  });

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _radiusController;
  
  LatLng? _currentPosition;
  bool _isUpdatingFromMap = false;
  bool _isUpdatingFromFields = false;
  
  /// Genera puntos para dibujar un círculo en el mapa
  /// [center] Centro del círculo
  /// [radiusMeters] Radio en metros
  /// [points] Número de puntos para el círculo (más puntos = más suave)
  List<LatLng> _generateCirclePoints(
    LatLng center,
    double radiusMeters,
    int points,
  ) {
    final circlePoints = <LatLng>[];
    // Aproximación: 1 grado de latitud ≈ 111,320 metros
    // 1 grado de longitud ≈ 111,320 * cos(latitud) metros
    final latRadius = radiusMeters / 111320.0;
    final lonRadius = radiusMeters / (111320.0 * math.cos(center.latitude * math.pi / 180.0));

    for (int i = 0; i <= points; i++) {
      final angle = (2 * math.pi * i) / points;
      final lat = center.latitude + latRadius * math.sin(angle);
      final lon = center.longitude + lonRadius * math.cos(angle);
      circlePoints.add(LatLng(lat, lon));
    }

    return circlePoints;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.geofence?.name ?? '');
    
    // Inicializar coordenadas con valores por defecto o del geofence
    final initialLat = widget.geofence?.latitude ?? 19.4326; // Ciudad de México por defecto
    final initialLon = widget.geofence?.longitude ?? -99.1332;
    _currentPosition = LatLng(initialLat, initialLon);
    
    _latitudeController = TextEditingController(
      text: initialLat.toString(),
    );
    _longitudeController = TextEditingController(
      text: initialLon.toString(),
    );
    _radiusController = TextEditingController(
      text: widget.geofence?.radiusInMeters.toString() ?? '',
    );
    
    // Agregar listeners a los campos para sincronizar con el mapa
    _latitudeController.addListener(_onLatitudeChanged);
    _longitudeController.addListener(_onLongitudeChanged);
    _radiusController.addListener(_onRadiusChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.removeListener(_onLatitudeChanged);
    _longitudeController.removeListener(_onLongitudeChanged);
    _radiusController.removeListener(_onRadiusChanged);
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _mapController.dispose();
    super.dispose();
  }
  
  void _onRadiusChanged() {
    // Actualizar el círculo cuando cambia el radio
    setState(() {});
  }

  void _onLatitudeChanged() {
    if (_isUpdatingFromMap) return;
    final latText = _latitudeController.text.trim();
    if (latText.isNotEmpty) {
      final lat = double.tryParse(latText);
      if (lat != null && lat >= -90 && lat <= 90 && _currentPosition != null) {
        _isUpdatingFromFields = true;
        _currentPosition = LatLng(lat, _currentPosition!.longitude);
        // Obtener zoom actual o usar 15.0 por defecto
        final currentZoom = _mapController.camera.zoom;
        _mapController.move(_currentPosition!, currentZoom);
        setState(() {}); // Actualizar círculo
        _isUpdatingFromFields = false;
      }
    }
  }

  void _onLongitudeChanged() {
    if (_isUpdatingFromMap) return;
    final lonText = _longitudeController.text.trim();
    if (lonText.isNotEmpty) {
      final lon = double.tryParse(lonText);
      if (lon != null && lon >= -180 && lon <= 180 && _currentPosition != null) {
        _isUpdatingFromFields = true;
        _currentPosition = LatLng(_currentPosition!.latitude, lon);
        // Obtener zoom actual o usar 15.0 por defecto
        final currentZoom = _mapController.camera.zoom;
        _mapController.move(_currentPosition!, currentZoom);
        setState(() {}); // Actualizar círculo
        _isUpdatingFromFields = false;
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_isUpdatingFromFields) return;
    _updatePositionFromMap(point);
  }

  void _updatePositionFromMap(LatLng position) {
    _isUpdatingFromMap = true;
    setState(() {
      _currentPosition = position;
    });
    _latitudeController.text = position.latitude.toStringAsFixed(6);
    _longitudeController.text = position.longitude.toStringAsFixed(6);
    _isUpdatingFromMap = false;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final geofence = Geofence(
        id: widget.geofence?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        radiusInMeters: double.parse(_radiusController.text.trim()),
      );
      Navigator.of(context).pop(geofence);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.geofence != null;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? l10n.editLocation : l10n.addLocation,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenido scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.locationName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Latitud
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: l10n.latitude,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                  helperText: '-90 to 90',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.invalidLatitude;
                  }
                  final lat = double.tryParse(value.trim());
                  if (lat == null || lat < -90 || lat > 90) {
                    return l10n.invalidLatitude;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Longitud
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: l10n.longitude,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.map),
                  helperText: '-180 to 180',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.invalidLongitude;
                  }
                  final lon = double.tryParse(value.trim());
                  if (lon == null || lon < -180 || lon > 180) {
                    return l10n.invalidLongitude;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Radio
              TextFormField(
                controller: _radiusController,
                decoration: InputDecoration(
                  labelText: l10n.radiusMeters,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.radio_button_checked),
                  helperText: 'Meters',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.invalidRadius;
                  }
                  final radius = double.tryParse(value.trim());
                  if (radius == null || radius <= 0) {
                    return l10n.invalidRadius;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mapa interactivo
              if (_currentPosition != null)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: JasuTheme.lightGreen),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Builder(
                      builder: (context) {
                        // Calcular zoom apropiado basado en el radio
                        double initialZoom = 15.0;
                        final radiusText = _radiusController.text.trim();
                        final radius = double.tryParse(radiusText);
                        if (radius != null && radius > 0) {
                          // Ajustar zoom basado en el radio
                          if (radius > 1000) {
                            initialZoom = 12.0;
                          } else if (radius > 500) {
                            initialZoom = 13.0;
                          } else if (radius > 200) {
                            initialZoom = 14.0;
                          } else if (radius > 100) {
                            initialZoom = 15.0;
                          } else {
                            initialZoom = 16.0;
                          }
                        }
                        
                        return FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition!,
                            initialZoom: initialZoom,
                            onTap: _onMapTap,
                          ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.attendance_app',
                        ),
                        // Círculo de geocerca (si hay radio configurado)
                        if (_currentPosition != null && _radiusController.text.trim().isNotEmpty)
                          Builder(
                            builder: (context) {
                              final radiusText = _radiusController.text.trim();
                              final radius = double.tryParse(radiusText);
                              if (radius != null && radius > 0) {
                                return PolygonLayer(
                                  polygons: [
                                    Polygon(
                                      points: _generateCirclePoints(
                                        _currentPosition!,
                                        radius,
                                        64, // Número de puntos para círculo suave
                                      ),
                                      color: Colors.blue.withOpacity(0.2), // Color neutro azul translúcido
                                      borderColor: Colors.blue,
                                      borderStrokeWidth: 2.0,
                                      isFilled: true,
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: JasuTheme.darkGreen,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Instrucciones del mapa
              if (_currentPosition != null)
                Text(
                  'Toca el mapa para mover el pin',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ),
            // Botones de acción
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JasuTheme.darkGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
