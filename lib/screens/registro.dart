import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _localidadController = TextEditingController();
  final TextEditingController _provinciaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> registrarUsuario() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
        'dni': _dniController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'fechaNacimiento': _fechaNacimientoController.text.trim(),
        'email': _emailController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'localidad': _localidadController.text.trim(),
        'provincia': _provinciaController.text.trim(),
        'creadoEn': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado correctamente')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar usuario';
      if (e.code == 'email-already-in-use') {
        mensaje = 'El correo ya está en uso';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'REGISTRO USUARIO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildEditableField('DNI:', _dniController),
              const SizedBox(height: 16),
              _buildEditableField('NOMBRE:', _nombreController),
              const SizedBox(height: 16),
              _buildEditableField('APELLIDOS:', _apellidosController),
              const SizedBox(height: 16),
              _buildEditableField('FECHA DE NACIMIENTO:', _fechaNacimientoController, isDate: true),
              const SizedBox(height: 16),
              _buildEditableField('EMAIL:', _emailController),
              const SizedBox(height: 16),
              _buildEditableField('TELÉFONO:', _telefonoController),
              const SizedBox(height: 16),
              _buildEditableField('DIRECCIÓN:', _direccionController),
              const SizedBox(height: 16),
              _buildEditableField('LOCALIDAD:', _localidadController),
              const SizedBox(height: 16),
              _buildEditableField('PROVINCIA:', _provinciaController),
              const SizedBox(height: 16),
              _buildEditableField('CONTRASEÑA:', _passwordController, isPassword: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : registrarUsuario,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Registrar Usuario',
                            style: TextStyle(fontSize: 16),
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

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isPassword = false, bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isDate
              ? () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().add(const Duration(days: 1))
                  );
                  if (pickedDate != null) {
                    controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                }
              : null,
          child: AbsorbPointer(
            absorbing: isDate,
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
