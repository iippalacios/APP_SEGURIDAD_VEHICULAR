import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'anadir_vehiculo.dart';
import 'modificar_vehiculo.dart';
import 'eliminar_vehiculo.dart';

class VehiculosUsuarioScreen extends StatefulWidget {
  const VehiculosUsuarioScreen({super.key});

  @override
  State<VehiculosUsuarioScreen> createState() => _VehiculosUsuarioScreenState();
}

class _VehiculosUsuarioScreenState extends State<VehiculosUsuarioScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> _getVehiculosStream() {
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .collection('vehiculos')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _eliminarReportesVehiculo(String vehiculoId) async {
    if (user == null) return;

    try {
      final reportesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('vehiculos')
          .doc(vehiculoId)
          .collection('reportes');

      final querySnapshot = await reportesRef.get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reportes Eliminados Al Poner Vehículo En Posesión')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Eliminando Reportes: $e')),
      );
    }
  }

  Future<void> _actualizarEstadoVehiculo(String id, String nuevoEstado) async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('vehiculos')
          .doc(id)
          .update({'estado': nuevoEstado});

      if (nuevoEstado.toLowerCase() == 'en posesión' || nuevoEstado.toLowerCase() == 'en posesion') {
        await _eliminarReportesVehiculo(id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Al Actualizar Estado: $e')),
      );
    }
  }

  Future<void> _modificarVehiculo(String id, Map<String, dynamic> vehiculoModificado) async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .collection('vehiculos')
          .doc(id)
          .update(vehiculoModificado);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Al Modificar Vehículo: $e')),
      );
    }
  }

  Future<void> _anadirVehiculo() async {
    if (user == null) return;

    final Map<String, dynamic>? nuevoVehiculo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnadirVehiculoScreen(),
      ),
    );

    if (nuevoVehiculo != null) {
      try {
        final String matricula = nuevoVehiculo['matricula'];
        if (matricula.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Matrícula Vacía')),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('vehiculos')
            .doc(matricula)
            .set({
          ...nuevoVehiculo,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Al Añadir Vehículo: $e')),
        );
      }
    }
  }

  Future<void> _eliminarVehiculo() async {
    if (user == null) return;

    final String? idVehiculo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const EliminarVehiculoScreen(),
      ),
    );

    if (idVehiculo != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('vehiculos')
            .doc(idVehiculo)
            .delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Al Eliminar Vehículo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario No Autenticado')),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'VEHÍCULOS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _getVehiculosStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Has Añadido Vehículos Todavía'));
            }

            final vehiculos = snapshot.data!.docs;

            return ListView.builder(
              itemCount: vehiculos.length,
              itemBuilder: (context, index) {
                final vehiculo = vehiculos[index];
                final Map<String, dynamic> data = vehiculo.data()! as Map<String, dynamic>;
                final String estado = data['estado'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['tipo'] != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['tipo'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Text(
                                '${vehiculo['marca']} ${vehiculo['modelo']} ${vehiculo['color']} - ${vehiculo['matricula']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      final Map<String, dynamic>? vehiculoModificado = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ModificarVehiculoScreen(vehiculo: data),
                                        ),
                                      );
                                      if (vehiculoModificado != null) {
                                        await _modificarVehiculo(vehiculo.id, vehiculoModificado);
                                      }
                                    },
                                    child: const Text('MODIFICAR'),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _actualizarEstadoVehiculo(vehiculo.id, 'En Posesión'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: estado == 'En Posesión' ? Colors.blue : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'En Posesión',
                                            style: TextStyle(
                                              color: estado == 'En Posesión' ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _actualizarEstadoVehiculo(vehiculo.id, 'Robado'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: estado == 'Robado' ? Colors.redAccent : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Robado',
                                            style: TextStyle(
                                              color: estado == 'Robado' ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _anadirVehiculo,
                  child: const Text('Añadir Vehículo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _eliminarVehiculo,
                  child: const Text('Eliminar Vehículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
