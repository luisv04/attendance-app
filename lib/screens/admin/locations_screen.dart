import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import '../../models/geofence.dart';
import '../../services/storage_service.dart';
import '../../core/geofence_config.dart';
import '../../core/theme.dart';
import '../../widgets/location_form_dialog.dart';

/// Pantalla de administración para gestionar ubicaciones (geofences)
/// Solo accesible para administradores
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  List<Geofence> _geofences = [];

  @override
  void initState() {
    super.initState();
    _loadGeofences();
  }

  void _loadGeofences() {
    setState(() {
      _geofences = GeofenceConfig.geofences;
    });
  }

  Future<void> _saveGeofences() async {
    await StorageService.saveGeofences(_geofences);
    _loadGeofences();
  }

  Future<void> _addLocation() async {
    final result = await showDialog<Geofence>(
      context: context,
      builder: (context) => const LocationFormDialog(),
    );

    if (result != null) {
      setState(() {
        _geofences.add(result);
      });
      await _saveGeofences();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.addLocation),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editLocation(Geofence geofence) async {
    final result = await showDialog<Geofence>(
      context: context,
      builder: (context) => LocationFormDialog(geofence: geofence),
    );

    if (result != null) {
      setState(() {
        final index = _geofences.indexWhere((g) => g.id == geofence.id);
        if (index != -1) {
          _geofences[index] = result;
        }
      });
      await _saveGeofences();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.editLocation),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteLocation(Geofence geofence) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteLocationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _geofences.removeWhere((g) => g.id == geofence.id);
      });
      await _saveGeofences();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.delete),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: JasuTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.locations),
        backgroundColor: JasuTheme.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Información
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: JasuTheme.lightGreen.withOpacity(0.1),
            child: Text(
              l10n.manageLocations,
              style: TextStyle(
                fontSize: 14,
                color: JasuTheme.darkGreen,
              ),
            ),
          ),
          // Lista de ubicaciones
          Expanded(
            child: _geofences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noHistoryRecords, // Reutilizar mensaje
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _geofences.length,
                    itemBuilder: (context, index) {
                      final geofence = _geofences[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: JasuTheme.lightGreen,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            geofence.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${geofence.latitude.toStringAsFixed(6)}, ${geofence.longitude.toStringAsFixed(6)}\n'
                            '${geofence.radiusInMeters.toStringAsFixed(0)} m',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: JasuTheme.darkGreen,
                                onPressed: () => _editLocation(geofence),
                                tooltip: l10n.edit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deleteLocation(geofence),
                                tooltip: l10n.delete,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLocation,
        backgroundColor: JasuTheme.darkGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addLocation),
      ),
    );
  }
}
