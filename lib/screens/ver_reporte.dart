import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerReporte extends StatefulWidget {
  final Map<String, dynamic> vehiculo;
  final Map<String, dynamic>? reporte;

  const VerReporte({
    super.key,
    required this.vehiculo,
    this.reporte,
  });

  @override
  State<VerReporte> createState() => _VerReporteState();
}

class _VerReporteState extends State<VerReporte> {
  Map<String, dynamic>? reporte;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.reporte != null) {
      reporte = widget.reporte;
      isLoading = false;
    } else {
      _cargarReporte();
    }
  }

  Future<void> _cargarReporte() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = 'Usuario No Autenticado.';
          isLoading = false;
        });
        return;
      }

      final vehiculoId = widget.vehiculo['id'] ?? widget.vehiculo['matricula'];
      if (vehiculoId == null) {
        setState(() {
          error = 'Vehículo Inválido.';
          isLoading = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('vehiculos')
          .doc(vehiculoId)
          .collection('reportes')
          .orderBy('fecha', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          error = 'No Hay Reportes Para Este Vehículo';
          isLoading = false;
        });
        return;
      }

      setState(() {
        reporte = querySnapshot.docs.first.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error Al Cargar El Reporte: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiculo = widget.vehiculo;
    final tituloVehiculo =
        '${vehiculo['marca'] ?? ''} ${vehiculo['modelo'] ?? ''} - ${vehiculo['matricula'] ?? ''}';

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'REPORTE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: Text(error!, style: const TextStyle(fontSize: 18)),
        ),
      );
    }

    final fecha = reporte?['fecha'] ?? 'No disponible';
    final direccion = reporte?['direccion'] ?? 'No disponible';
    final localidad = reporte?['localidad'] ?? 'No disponible';
    final descripcion = reporte?['descripcion'] ?? 'No disponible';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'REPORTE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    tituloVehiculo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      const TextSpan(
                          text: 'FECHA: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: fecha),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      const TextSpan(
                          text: 'DIRECCIÓN: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: direccion),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      const TextSpan(
                          text: 'LOCALIDAD: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: localidad),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('DESCRIPCIÓN: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(descripcion, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                /*const Text('FOTO: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Center(
                  child: fotoUrl != null
                      ? Image.network(
                          fotoUrl,
                          width: 400,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('No Hay Imagen Disponible');
                          },
                        )
                      : const Text('No Hay Imagen Disponible'),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
