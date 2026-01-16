import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../models/geofence.dart';
import '../core/geofence_config.dart';
import '../core/theme.dart';

/// Modal de verificación visual de asistencia
/// Muestra mapa con pin de ubicación y geocerca visual (verde/rojo)
class AttendanceVerificationModal extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String attendance; // 'yes' o 'no'
  final String? nearestGeofenceId; // ID de la geocerca más cercana (opcional)

  const AttendanceVerificationModal({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.attendance,
    this.nearestGeofenceId,
  });

  /// Genera puntos para dibujar un círculo en el mapa
  /// [center] Centro del círculo
  /// [radiusMeters] Radio en metros
  /// [points] Número de puntos para el círculo (más puntos = más suave)
  static List<LatLng> _generateCirclePoints(
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWithinZone = attendance == 'yes';

    // Obtener geocerca para mostrar
    Geofence? geofence;
    final allGeofences = GeofenceConfig.geofences;
    
    if (allGeofences.isNotEmpty) {
      if (nearestGeofenceId != null) {
        // Buscar geocerca por ID
        try {
          geofence = allGeofences.firstWhere(
            (g) => g.id == nearestGeofenceId,
          );
        } catch (e) {
          // Si no se encuentra por ID, obtener la más cercana
          geofence = GeofenceConfig.getNearestGeofence(latitude, longitude);
        }
      } else {
        // Obtener geocerca más cercana
        geofence = GeofenceConfig.getNearestGeofence(latitude, longitude);
      }
    }

    final checkPosition = LatLng(latitude, longitude);
    final mapController = MapController();

    // Calcular zoom apropiado para mostrar pin y geocerca
    double initialZoom = 15.0;
    LatLng mapCenter = checkPosition;
    
    if (geofence != null) {
      final geofenceCenter = LatLng(geofence.latitude, geofence.longitude);
      
      // Calcular distancia entre el pin y el centro de la geocerca
      final distance = Geolocator.distanceBetween(
        checkPosition.latitude,
        checkPosition.longitude,
        geofenceCenter.latitude,
        geofenceCenter.longitude,
      );
      
      // Calcular el radio total necesario para mostrar todo (geocerca + distancia al pin)
      final totalRadius = geofence.radiusInMeters + distance;
      
      // Ajustar zoom basado en el radio total necesario
      if (totalRadius > 1000) {
        initialZoom = 12.0;
      } else if (totalRadius > 500) {
        initialZoom = 13.0;
      } else if (totalRadius > 200) {
        initialZoom = 14.0;
      } else if (totalRadius > 100) {
        initialZoom = 15.0;
      } else {
        initialZoom = 16.0;
      }
      
      // Centrar el mapa para mostrar tanto el pin como la geocerca completa
      // Usar un punto intermedio entre el pin y el centro de la geocerca
      mapCenter = LatLng(
        (checkPosition.latitude + geofenceCenter.latitude) / 2,
        (checkPosition.longitude + geofenceCenter.longitude) / 2,
      );
    }

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                    l10n.attendanceVerification,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: JasuTheme.darkGreen,
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
            // Estado de asistencia
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              color: isWithinZone
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWithinZone ? Icons.check_circle : Icons.cancel,
                    color: isWithinZone ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isWithinZone ? l10n.validAttendance : l10n.outsideZone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isWithinZone ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
            // Mapa
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: JasuTheme.lightGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: initialZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.attendance_app',
                      ),
                      // Círculo de geocerca (si existe)
                      if (geofence != null) ...[
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _generateCirclePoints(
                                LatLng(geofence.latitude, geofence.longitude),
                                geofence.radiusInMeters,
                                64, // Número de puntos para círculo suave
                              ),
                              color: isWithinZone
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              borderColor: isWithinZone
                                  ? Colors.green
                                  : Colors.red,
                              borderStrokeWidth: 3.0,
                              isFilled: true,
                            ),
                          ],
                        ),
                        // Marcador en el centro de la geocerca (opcional, para debug)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(geofence.latitude, geofence.longitude),
                              width: 20,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isWithinZone ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Pin de ubicación de la checada
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: checkPosition,
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
                  ),
                ),
              ),
            ),
            // Botón OK
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JasuTheme.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.ok,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
