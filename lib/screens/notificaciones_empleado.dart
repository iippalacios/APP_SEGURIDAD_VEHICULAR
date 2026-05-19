import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ver_reporte.dart';

class NotificacionesEmpleado extends StatefulWidget {
  const NotificacionesEmpleado({Key? key}) : super(key: key);

  @override
  State<NotificacionesEmpleado> createState() =>
      _NotificacionesEmpleadoState();
}

class _NotificacionesEmpleadoState extends State<NotificacionesEmpleado> {
  Future<List<Map<String, dynamic>>> obtenerReportes() async {
    List<Map<String, dynamic>> reportes = [];

    try {
      QuerySnapshot usuariosSnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      for (var usuarioDoc in usuariosSnapshot.docs) {
        QuerySnapshot vehiculosSnapshot = await usuarioDoc.reference
            .collection('vehiculos')
            .where('estado', isEqualTo: 'Robado')
            .get();

        for (var vehiculoDoc in vehiculosSnapshot.docs) {
          final vehiculoData = vehiculoDoc.data() as Map<String, dynamic>;

          QuerySnapshot reportesSnapshot =
              await vehiculoDoc.reference.collection('reportes').get();

          for (var reporteDoc in reportesSnapshot.docs) {
            final reporteData = reporteDoc.data() as Map<String, dynamic>;

            reportes.add({
              'vehiculo': vehiculoData,
              'reporte': reporteData,
              'reporteId': reporteDoc.id,
            });
          }
        }
      }
    } catch (e) {
      print('Error Al Obtener Los Reportes: $e');
    }

    return reportes;
  }

  Widget buildCenteredHeader(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  DataCell buildCenteredCell(String text, double width) {
    return DataCell(
      Container(
        width: width,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell buildCenteredLinkCell(
      double width, Map<String, dynamic> vehiculo, Map<String, dynamic> reporte) {
    return DataCell(
      Container(
        width: width,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerReporte(
                  vehiculo: vehiculo,
                  reporte: reporte,
                ),
              ),
            );
          },
          child: const Text(
            'Ver',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double columnaAncho = 160;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'NOTIFICACIONES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: obtenerReportes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No Hay Reportes Disponibles.');
              }

              List<Map<String, dynamic>> reportes = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(label: buildCenteredHeader('MATRÍCULA', columnaAncho)),
                    DataColumn(label: buildCenteredHeader('REPORTE', columnaAncho)),
                  ],
                  rows: reportes.map((reporteMap) {
                    final vehiculo =
                        reporteMap['vehiculo'] as Map<String, dynamic>;
                    final reporte =
                        reporteMap['reporte'] as Map<String, dynamic>;

                    return DataRow(
                      cells: [
                        buildCenteredCell(
                            vehiculo['matricula'] ?? '', columnaAncho),
                        buildCenteredLinkCell(columnaAncho, vehiculo, reporte),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
