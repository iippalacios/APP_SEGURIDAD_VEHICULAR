import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final TextEditingController _dniController = TextEditingController();

  bool isLoading = false;

  Future<void> _enviarEmailRecuperacion() async {
    final dni = _dniController.text.trim();

    if (dni.isEmpty) {
      _showSnackbar('Por Favor, Ingresa Tu DNI.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot usuariosQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('dni', isEqualTo: dni)
          .limit(1)
          .get();

      String? email;

      if (usuariosQuery.docs.isNotEmpty) {
        email = usuariosQuery.docs.first.get('email');
      } else {
        QuerySnapshot empleadosQuery = await FirebaseFirestore.instance
            .collection('empleados')
            .where('dni', isEqualTo: dni)
            .limit(1)
            .get();

        if (empleadosQuery.docs.isNotEmpty) {
          email = empleadosQuery.docs.first.get('email');
        }
      }

      if (email == null) {
        setState(() {
          isLoading = false;
        });
        _showSnackbar('No Se Encontró Un Usuario Con Ese DNI.');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _showSnackbar('Correo De Recuperación Enviado A: $email');
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Error Firebase: ${e.message}');
    } catch (e) {
      _showSnackbar('Error Inesperado: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
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
            'RECUPERAR CONTRASEÑA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Ingresa Tu DNI Para Recibir Un Correo Con Instrucciones Para Recuperar Tu Contraseña.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dniController,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _enviarEmailRecuperacion,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar Correo De Recuperación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
