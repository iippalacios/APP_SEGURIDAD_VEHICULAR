import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ver_reporte.dart';

class VehiculosRobadosEmpleado extends StatefulWidget {
  const VehiculosRobadosEmpleado({super.key});

  @override
  State<VehiculosRobadosEmpleado> createState() => _VehiculosRobadosEmpleadoState();
}

class _VehiculosRobadosEmpleadoState extends State<VehiculosRobadosEmpleado> {
  final TextEditingController _filtroController = TextEditingController();

  List<Map<String, dynamic>> _vehiculos = [];
  Map<String, Map<String, dynamic>?> _reportesPorVehiculoId = {}; // mapa vehiculoId -> reporte (o null)
  String filtro = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarVehiculosRobados();
  }

  Future<void> _cargarVehiculosRobados() async {
    setState(() {
      _loading = true;
      _error = null;
      _vehiculos = [];
      _reportesPorVehiculoId = {};
    });

    try {
      final usuariosSnapshot = await FirebaseFirestore.instance.collection('usuarios').get();

      List<Map<String, dynamic>> vehiculosRobados = [];
      Map<String, Map<String, dynamic>?> reportesMap = {};

      for (final usuarioDoc in usuariosSnapshot.docs) {
        final uid = usuarioDoc.id;

        final vehiculosSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('vehiculos')
            .where('estado', isEqualTo: 'Robado')
            .get();

        for (final vehiculoDoc in vehiculosSnapshot.docs) {
          final data = vehiculoDoc.data();
          data['id'] = vehiculoDoc.id;
          data['usuarioId'] = uid;

          vehiculosRobados.add(data);

          final reportesSnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .collection('vehiculos')
              .doc(vehiculoDoc.id)
              .collection('reportes')
              .orderBy('fecha', descending: true)
              .limit(1)
              .get();

          if (reportesSnapshot.docs.isNotEmpty) {
            reportesMap[vehiculoDoc.id] = reportesSnapshot.docs.first.data();
          } else {
            reportesMap[vehiculoDoc.id] = null;
          }
        }
      }

      setState(() {
        _vehiculos = vehiculosRobados;
        _reportesPorVehiculoId = reportesMap;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get vehiculosFiltrados {
    if (filtro.isEmpty) return _vehiculos;
    return _vehiculos.where((v) {
      final marca = (v['marca'] ?? '').toString().toLowerCase();
      return marca.contains(filtro.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'VEHÍCULOS ROBADOS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarVehiculosRobados,
              tooltip: 'Actualizar Lista',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : Column(
                      children: [
                        TextField(
                          controller: _filtroController,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar Por Marca...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filtro = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: vehiculosFiltrados.isEmpty
                              ? const Center(child: Text('No Hay Vehículos Robados'))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('MATRÍCULA')),
                                        DataColumn(label: Text('MARCA')),
                                        DataColumn(label: Text('MODELO')),
                                        DataColumn(label: Text('COLOR')),
                                        DataColumn(label: Text('REPORTE')),
                                      ],
                                      rows: vehiculosFiltrados.map((vehiculo) {
                                        final reporte = _reportesPorVehiculoId[vehiculo['id']];

                                        return DataRow(cells: [
                                          DataCell(Text(vehiculo['matricula'] ?? '')),
                                          DataCell(Text(vehiculo['marca'] ?? '')),
                                          DataCell(Text(vehiculo['modelo'] ?? '')),
                                          DataCell(Text(vehiculo['color'] ?? '')),
                                          DataCell(
                                            reporte != null
                                                ? GestureDetector(
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
                                                      'Ver Reporte',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'No Hay Reporte',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
