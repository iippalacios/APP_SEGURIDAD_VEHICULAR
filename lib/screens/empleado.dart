import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vehiculos_robados_empleado.dart';
import 'notificaciones_empleado.dart';
import 'inicio_sesion.dart';

class EmpleadoScreen extends StatefulWidget {
  const EmpleadoScreen({super.key});

  @override
  State<EmpleadoScreen> createState() => _EmpleadoScreenState();
}

class _EmpleadoScreenState extends State<EmpleadoScreen> {
  final TextEditingController _matriculaController = TextEditingController();
  String resultado = '';
  bool isChecking = false;
  int nuevosReportes = 0;

  @override
  void initState() {
    super.initState();
    _inicializarCampoNotificacionesSiNoExiste();
    _contarNuevosReportes();
  }

  Future<void> _inicializarCampoNotificacionesSiNoExiste() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('empleados').doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data == null || !data.containsKey('lastSeenNotifications')) {
        await docRef.update({
          'lastSeenNotifications': Timestamp.now(),
        });
      }
    }
  }

  Future<void> _contarNuevosReportes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final empleadoDoc =
        FirebaseFirestore.instance.collection('empleados').doc(user.uid);

    final empleadoSnapshot = await empleadoDoc.get();
    Timestamp? lastSeen;

    if (empleadoSnapshot.exists &&
        empleadoSnapshot.data()!.containsKey('lastSeenNotifications')) {
      lastSeen = empleadoSnapshot['lastSeenNotifications'];
    }

    int nuevos = 0;

    final usuarios =
        await FirebaseFirestore.instance.collection('usuarios').get();

    for (final usuario in usuarios.docs) {
      final vehiculosSnapshot =
          await usuario.reference.collection('vehiculos').get();

      for (final vehiculo in vehiculosSnapshot.docs) {
        Query query = vehiculo.reference.collection('reportes');
        if (lastSeen != null) {
          query = query.where('timestamp', isGreaterThan: lastSeen);
        }

        final reportesSnapshot = await query.get();
        nuevos += reportesSnapshot.size;
      }
    }

    setState(() {
      nuevosReportes = nuevos;
    });
  }

  Future<void> _actualizarUltimaVistaNotificaciones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('empleados')
        .doc(user.uid)
        .update({'lastSeenNotifications': Timestamp.now()});
  }

  Future<void> verificarVehiculo(String matricula) async {
    final texto = matricula.trim().toUpperCase();

    if (texto.isEmpty) return;

    setState(() {
      isChecking = true;
      resultado = '';
    });

    try {
      final usuariosSnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      bool encontrado = false;
      String estadoVehiculo = '';

      for (final usuarioDoc in usuariosSnapshot.docs) {
        final vehiculosSnapshot = await usuarioDoc.reference
            .collection('vehiculos')
            .where('matricula', isEqualTo: texto)
            .get();

        if (vehiculosSnapshot.docs.isNotEmpty) {
          final vehiculoData = vehiculosSnapshot.docs.first.data();

          estadoVehiculo = vehiculoData['estado']?.toString().toLowerCase() ??
              'sin estado definido';
          encontrado = true;
          break;
        }
      }

      if (encontrado) {
        if (estadoVehiculo == 'robado') {
          resultado = '🚨 VEHÍCULO ROBADO';
        } else if (estadoVehiculo == 'sin estado definido') {
          resultado = '⚠️ VEHÍCULO SIN ESTADO DEFINIDO';
        } else {
          resultado = '✅ VEHÍCULO NO ROBADO';
        }
      } else {
        resultado = '❓ VEHÍCULO NO REGISTRADO';
      }
    } catch (e) {
      resultado = '⚠️ Error al verificar: ${e.toString()}';
    }

    setState(() {
      isChecking = false;
      _matriculaController.clear();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          resultado = '';
        });
      }
    });
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double messageHeight = 30;
    const double topPadding = 80;

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(200, 48),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'EMPLEADO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              left: 24,
              right: 24,
              top: topPadding,
              child: Column(
                children: [
                  TextField(
                    controller: _matriculaController,
                    onSubmitted: verificarVehiculo,
                    decoration: const InputDecoration(
                      labelText: 'INTRODUCIR MATRÍCULA',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isChecking)
                    const CircularProgressIndicator()
                  else
                    Container(
                      height: messageHeight,
                      alignment: Alignment.center,
                      child: Text(
                        resultado,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VehiculosRobadosEmpleado(),
                          ),
                        );
                      },
                      child: const Text('VEHÍCULOS ROBADOS'),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        ElevatedButton(
                          style: buttonStyle,
                          onPressed: () async {
                            await _actualizarUltimaVistaNotificaciones();
                            setState(() {
                              nuevosReportes = 0;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotificacionesEmpleado()),
                            );
                          },
                          child: const Text('NOTIFICACIONES'),
                        ),
                        if (nuevosReportes > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              child: Text(
                                '$nuevosReportes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                onPressed: _cerrarSesion,
                child: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
