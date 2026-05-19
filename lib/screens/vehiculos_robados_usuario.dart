import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seguridad_vehicular/screens/crear_reporte.dart';
import 'package:seguridad_vehicular/screens/ver_reporte.dart';

class VehiculosRobadosUsuario extends StatefulWidget {
  const VehiculosRobadosUsuario({super.key});

  @override
  State<VehiculosRobadosUsuario> createState() => _VehiculosRobadosUsuarioState();
}

class _VehiculosRobadosUsuarioState extends State<VehiculosRobadosUsuario> {
  final Map<String, bool> reporteCreado = {};

  late Future<List<Map<String, dynamic>>> _vehiculosRobados;

  @override
  void initState() {
    super.initState();
    _vehiculosRobados = _obtenerVehiculosRobadosDelUsuario();
  }

  Future<List<Map<String, dynamic>>> _obtenerVehiculosRobadosDelUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No Hay Usuario Autenticado');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('vehiculos')
        .where('estado', isEqualTo: 'Robado')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
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
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _vehiculosRobados,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final vehiculosRobados = snapshot.data ?? [];

            if (vehiculosRobados.isEmpty) {
              return const Center(
                child: Text(
                  'No Hay Vehículos Robados',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: vehiculosRobados.length,
                itemBuilder: (context, index) {
                  final vehiculo = vehiculosRobados[index];
                  final matricula = vehiculo['matricula'] ?? '';
                  final creado = reporteCreado[matricula] ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehiculo['marca']} ${vehiculo['modelo']} ${vehiculo['color']} - ${vehiculo['matricula']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: creado
                                    ? null
                                    : () async {
                                        final resultado = await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CrearReporteScreen(vehiculo: vehiculo),
                                          ),
                                        );

                                        if (resultado == true) {
                                          setState(() {
                                            reporteCreado[matricula] = true;
                                          });
                                        }
                                      },
                                child: const Text('Crear Reporte'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerReporte(vehiculo: vehiculo),
                                    ),
                                  );
                                },
                                child: const Text('Ver Reporte'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
