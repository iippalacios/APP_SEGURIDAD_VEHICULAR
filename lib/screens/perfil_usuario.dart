import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seguridad_vehicular/screens/modificar_perfil_usuario.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  late Future<Map<String, dynamic>> _datosUsuario;

  @override
  void initState() {
    super.initState();
    _datosUsuario = _obtenerDatosUsuario();
  }

  Future<Map<String, dynamic>> _obtenerDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    if (!docSnapshot.exists) {
      throw Exception('El perfil del usuario no existe en Firestore');
    }

    return docSnapshot.data()!;
  }

  void _actualizarDatos(Map<String, String> nuevosDatos) {
    setState(() {
      _datosUsuario = Future.value(nuevosDatos);
    });
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
            'PERFIL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _datosUsuario,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final datos = snapshot.data!;
            final nombre = datos['nombre'] ?? '';
            final apellidos = datos['apellidos'] ?? '';
            final fechaNacimiento = datos['fechaNacimiento'] ?? '';
            final dni = datos['dni'] ?? '';
            final email = datos['email'] ?? '';
            final direccion = datos['direccion'] ?? '';
            final localidad = datos['localidad'] ?? '';
            final telefono = datos['telefono'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildLabelValue('NOMBRE:', nombre),
                    const SizedBox(height: 16),
                    _buildLabelValue('APELLIDOS:', apellidos),
                    const SizedBox(height: 16),
                    _buildLabelValue('FECHA DE NACIMIENTO:', fechaNacimiento),
                    const SizedBox(height: 16),
                    _buildLabelValue('DNI:', dni),
                    const SizedBox(height: 16),
                    _buildLabelValue('CORREO ELECTRÓNICO:', email),
                    const SizedBox(height: 16),
                    _buildLabelValue('DIRECCIÓN:', direccion),
                    const SizedBox(height: 16),
                    _buildLabelValue('LOCALIDAD:', localidad),
                    const SizedBox(height: 16),
                    _buildLabelValue('TELÉFONO:', telefono),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final resultado = await Navigator.push<Map<String, String>>(
              context,
              MaterialPageRoute(
                builder: (context) => const ModificarPerfilUsuario(),
              ),
            );

            if (resultado != null) {
              _actualizarDatos(resultado);
            }
          },
          label: const Text('Modificar'),
          icon: const Icon(Icons.edit),
          tooltip: 'Editar Perfil',
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
