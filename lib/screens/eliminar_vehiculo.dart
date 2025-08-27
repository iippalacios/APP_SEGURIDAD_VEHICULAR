import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EliminarVehiculoScreen extends StatefulWidget {
  const EliminarVehiculoScreen({super.key});

  @override
  State<EliminarVehiculoScreen> createState() => _EliminarVehiculoScreenState();
}

class _EliminarVehiculoScreenState extends State<EliminarVehiculoScreen> {
  final TextEditingController matriculaController = TextEditingController();
  String? errorText;
  bool _isLoading = false;

  Future<void> eliminarVehiculoPorMatricula() async {
    final matriculaBuscada = matriculaController.text.trim().toUpperCase();

    if (matriculaBuscada.isEmpty) {
      setState(() {
        errorText = 'Introduce Una Matrícula';
      });
      return;
    }

    setState(() {
      errorText = null;
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorText = 'Usuario No Autenticado';
          _isLoading = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')       
          .doc(user.uid)
          .collection('vehiculos')   
          .where('matricula', isEqualTo: matriculaBuscada)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorText = 'Vehículo No Encontrado';
          _isLoading = false;
        });
        return;
      }

      final doc = querySnapshot.docs.first;

      await doc.reference.delete();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo Eliminado Correctamente')),
      );

      Navigator.pop(context, doc.id);
    } catch (e) {
      setState(() {
        errorText = 'Error Al Buscar O Eliminar El Vehículo: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    matriculaController.dispose();
    super.dispose();
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
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'ELIMINAR VEHÍCULO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : eliminarVehiculoPorMatricula,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Eliminar Vehículo',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
