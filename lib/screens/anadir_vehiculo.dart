import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnadirVehiculoScreen extends StatefulWidget {
  const AnadirVehiculoScreen({super.key});

  @override
  State<AnadirVehiculoScreen> createState() => _AnadirVehiculoScreenState();
}

class _AnadirVehiculoScreenState extends State<AnadirVehiculoScreen> {
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  String _tipoVehiculo = 'Coche';
  String _estadoVehiculo = 'En Posesión';

  String? _errorText;
  bool _isLoading = false;

  Future<bool> _existeMatriculaEnUsuarios(String matricula) async {
    final usuariosSnapshot = await FirebaseFirestore.instance.collection('usuarios').get();

    for (final usuarioDoc in usuariosSnapshot.docs) {
      final vehiculoDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioDoc.id)
          .collection('vehiculos')
          .doc(matricula)
          .get();

      if (vehiculoDoc.exists) {
        return true;
      }
    }
    return false;
  }

  Future<void> _onAddPressed() async {
    final matricula = _matriculaController.text.trim().toUpperCase();
    final marca = _marcaController.text.trim();
    final modelo = _modeloController.text.trim();
    final color = _colorController.text.trim();

    if (matricula.isEmpty || marca.isEmpty || modelo.isEmpty) {
      setState(() {
        _errorText = 'Por Favor, Rellena Matrícula, Marca Y Modelo';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorText = 'Usuario No Autenticado.';
          _isLoading = false;
        });
        return;
      }

      final existe = await _existeMatriculaEnUsuarios(matricula);
      if (existe) {
        setState(() {
          _errorText = 'Ya Existe Un Vehículo Con Esa Matrícula';
          _isLoading = false;
        });
        return;
      }

      final nuevoVehiculo = {
        'matricula': matricula,
        'marca': marca,
        'modelo': modelo,
        'color': color,
        'tipo': _tipoVehiculo,
        'estado': _estadoVehiculo,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('vehiculos')
          .doc(matricula)
          .set(nuevoVehiculo, SetOptions(merge: true));

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo Añadido Correctamente')),
      );

      Navigator.pop(context, nuevoVehiculo);
    } catch (e) {
      setState(() {
        _errorText = 'Error Al Añadir Vehículo: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _matriculaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'AÑADIR VEHÍCULO',
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
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _buildEditableField('Matrícula:', _matriculaController),
              const SizedBox(height: 16),
              _buildEditableField('Marca:', _marcaController),
              const SizedBox(height: 16),
              _buildEditableField('Modelo:', _modeloController),
              const SizedBox(height: 16),
              _buildEditableField('Color:', _colorController),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tipo de Vehículo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _tipoBoton('Coche'),
                  const SizedBox(width: 12),
                  _tipoBoton('Moto'),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Estado del Vehículo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _estadoBoton('En Posesión', Colors.blue),
                  const SizedBox(width: 12),
                  _estadoBoton('Robado', Colors.redAccent),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onAddPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Añadir Vehículo',
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

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _tipoBoton(String tipo) {
    final bool seleccionado = _tipoVehiculo == tipo;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoVehiculo = tipo;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tipo,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _estadoBoton(String estado, Color color) {
    final bool seleccionado = _estadoVehiculo == estado;
    return GestureDetector(
      onTap: () {
        setState(() {
          _estadoVehiculo = estado;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          estado,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
