import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seguridad_vehicular/screens/empleado.dart';
import 'package:seguridad_vehicular/screens/usuario.dart';
import 'package:seguridad_vehicular/screens/recuperar_contrasena.dart';
import 'package:seguridad_vehicular/screens/registro.dart';

class InicioSesionScreen extends StatefulWidget {
  const InicioSesionScreen({super.key});

  @override
  State<InicioSesionScreen> createState() => _InicioSesionScreenState();
}

class _InicioSesionScreenState extends State<InicioSesionScreen> {
  final TextEditingController dniController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  Future<void> signIn() async {
    final dni = dniController.text.trim();
    final password = passwordController.text.trim();

    if (dni.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Por Favor, Ingresa DNI Y Contraseña.';
      });
      return;
    }

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      String? email;
      String? tipoUsuario;

      QuerySnapshot usuariosQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('dni', isEqualTo: dni)
          .limit(1)
          .get();

      if (usuariosQuery.docs.isNotEmpty) {
        email = usuariosQuery.docs.first.get('email');
        tipoUsuario = 'usuario';
      } else {
        QuerySnapshot empleadosQuery = await FirebaseFirestore.instance
            .collection('empleados')
            .where('dni', isEqualTo: dni)
            .limit(1)
            .get();

        if (empleadosQuery.docs.isNotEmpty) {
          email = empleadosQuery.docs.first.get('email');
          tipoUsuario = 'empleado';
        }
      }

      if (email == null) {
        setState(() {
          errorMessage = 'No Se Encontró Un Usuario Con Ese DNI.';
          isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      if (tipoUsuario == 'usuario') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UsuarioScreen()),
        );
      } else if (tipoUsuario == 'empleado') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmpleadoScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = _firebaseErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error Inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario No Encontrado.';
      case 'wrong-password':
        return 'Contraseña Incorrecta.';
      case 'invalid-email':
        return 'Formato De DNI Inválido.';
      case 'user-disabled':
        return 'Usuario Deshabilitado.';
      default:
        return 'Error: ${e.message}';
    }
  }

  @override
  void dispose() {
    dniController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('INICIO SESIÓN'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              TextField(
                controller: dniController,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'CONTRASEÑA',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecuperarContrasenaScreen(),
                    ),
                  );
                },
                child: const Text(
                  '¿Olvidaste Tu Contraseña?',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Iniciar Sesión'),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Aún No Está Registrado?',
                    style: TextStyle(fontSize: 10),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegistroUsuarioScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
                      child: Text(
                        ' Registrarse',
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
