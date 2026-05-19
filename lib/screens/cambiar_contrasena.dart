import 'package:flutter/material.dart';
import 'recuperar_contrasena.dart';

class CambiarContrasena extends StatefulWidget {
  const CambiarContrasena({super.key});

  @override
  State<CambiarContrasena> createState() => _CambiarContrasenaState();
}

class _CambiarContrasenaState extends State<CambiarContrasena> {
  final TextEditingController _nuevaContrasenaController = TextEditingController();
  final TextEditingController _repetirContrasenaController = TextEditingController();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RecuperarContrasenaScreen()),
              );
            },
          ),
          title: const Text(
            'CAMBIAR CONTRASEÑA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildEditableField('Nueva Contraseña:', _nuevaContrasenaController, obscureText: true),
              const SizedBox(height: 16),
              _buildEditableField('Repetir Contraseña:', _repetirContrasenaController, obscureText: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final nuevaContrasena = _nuevaContrasenaController.text.trim();
                    final repetirContrasena = _repetirContrasenaController.text.trim();

                    if (nuevaContrasena.isEmpty || repetirContrasena.isEmpty) {
                      _showSnackbar('Por Favor, Rellena Ambos Campos.');
                      return;
                    }

                    if (nuevaContrasena != repetirContrasena) {
                      _showSnackbar('Las Contraseñas No Coinciden.');
                      return;
                    }

                    _showSnackbar('Contraseña Cambiada Con Éxito.');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Confirmar Nueva Contraseña',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
