import 'package:flutter/material.dart';
import 'package:attendance_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/check_type.dart';
import '../widgets/attendance_verification_modal.dart';
import '../core/theme.dart';

/// Pantalla que muestra el historial de asistencia (últimos 7 días)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final history = StorageService.getAttendanceHistory();

    return Scaffold(
      backgroundColor: JasuTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.history),
        backgroundColor: JasuTheme.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noHistoryRecords,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Subtítulo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: JasuTheme.lightGreen.withOpacity(0.1),
                  child: Text(
                    l10n.last7Days,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: JasuTheme.darkGreen,
                    ),
                  ),
                ),
                // Lista de registros
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      final checkType = CheckType.fromString(record.checkType);
                      final dateFormat = DateFormat('MMM dd, yyyy', locale);
                      final timeFormat = DateFormat('HH:mm', locale);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // Abrir modal de verificación al hacer clic
                            showDialog(
                              context: context,
                              builder: (context) => AttendanceVerificationModal(
                                latitude: record.latitude,
                                longitude: record.longitude,
                                attendance: record.attendance,
                                nearestGeofenceId: record.nearestGeofenceId,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fecha y hora
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: JasuTheme.darkGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateFormat.format(record.timestamp),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: JasuTheme.darkGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeFormat.format(record.timestamp),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Tipo de checada
                              Row(
                                children: [
                                  Icon(
                                    Icons.label,
                                    size: 16,
                                    color: JasuTheme.lightGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.type,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: JasuTheme.lightGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      checkType?.getLabel(locale) ?? record.checkType,
                                      style: TextStyle(
                                        color: JasuTheme.darkGreen,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Estado de asistencia
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: JasuTheme.lightGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.attendanceStatus,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (record.attendance == 'yes'
                                              ? Colors.green
                                              : Colors.red)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: record.attendance == 'yes'
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          record.attendance == 'yes'
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 14,
                                          color: record.attendance == 'yes'
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          record.attendance == 'yes'
                                              ? l10n.validAttendance
                                              : l10n.outsideZone,
                                          style: TextStyle(
                                            color: record.attendance == 'yes'
                                                ? Colors.green.shade900
                                                : Colors.red.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Comentario (si existe)
                              if (record.comment != null &&
                                  record.comment!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.comment,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record.comment!,
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
