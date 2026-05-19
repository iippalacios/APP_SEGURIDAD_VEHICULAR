import 'package:flutter/material.dart';
import 'perfil_usuario.dart';
import 'vehiculos_usuario.dart';
import 'vehiculos_robados_usuario.dart';
import 'estadisticas_usuario.dart';
import 'inicio_sesion.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(200, 48),
  );

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const InicioSesionScreen()),
      (route) => false,
    );
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
            'USUARIO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Stack(
          children: [
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
                          MaterialPageRoute(builder: (context) => const PerfilUsuario()),
                        );
                      },
                      child: const Text('PERFIL'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VehiculosUsuarioScreen()),
                        );
                      },
                      child: const Text('VEHÍCULOS'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VehiculosRobadosUsuario()),
                        );
                      },
                      child: const Text('VEHÍCULOS ROBADOS'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EstadisticasUsuario()),
                        );
                      },
                      child: const Text('ESTADÍSTICAS'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
