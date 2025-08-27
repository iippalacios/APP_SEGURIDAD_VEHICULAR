import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ModificarPerfilUsuario extends StatefulWidget {
  const ModificarPerfilUsuario({super.key});

  @override
  State<ModificarPerfilUsuario> createState() => _ModificarPerfilUsuarioState();
}

class _ModificarPerfilUsuarioState extends State<ModificarPerfilUsuario> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _localidadController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No Hay Usuario Autenticado');
      }

      final docSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('El Perfil Del Usuario No Existe En Firestore');
      }

      final data = docSnapshot.data()!;
      _nombreController.text = data['nombre'] ?? '';
      _apellidosController.text = data['apellidos'] ?? '';
      _fechaNacimientoController.text = data['fechaNacimiento'] ?? '';
      _dniController.text = data['dni'] ?? '';
      _correoController.text = data['email'] ?? '';
      _direccionController.text = data['direccion'] ?? '';
      _localidadController.text = data['localidad'] ?? '';
      _telefonoController.text = data['telefono'] ?? '';

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error Al Cargar Datos: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _dniController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _localidadController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final hoy = DateTime.now();
    final fechaInicial = _fechaNacimientoController.text.isNotEmpty
        ? DateTime.tryParse(_fechaNacimientoController.text) ?? hoy
        : hoy;

    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimientoController.text = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'MODIFICAR PERFIL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'MODIFICAR PERFIL',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              _buildEditableField('NOMBRE', _nombreController),
              const SizedBox(height: 16),
              _buildEditableField('APELLIDOS', _apellidosController),
              const SizedBox(height: 16),
              _buildDateField('FECHA DE NACIMIENTO', _fechaNacimientoController, _seleccionarFechaNacimiento),
              const SizedBox(height: 16),
              _buildEditableField('DNI:', _dniController),
              const SizedBox(height: 16),
              _buildEditableField('CORREO ELECTRÓNICO', _correoController),
              const SizedBox(height: 16),
              _buildEditableField('DIRECCIÓN', _direccionController),
              const SizedBox(height: 16),
              _buildEditableField('LOCALIDAD', _localidadController),
              const SizedBox(height: 16),
              _buildEditableField('TELÉFONO', _telefonoController),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    final datosActualizados = {
                      'nombre': _nombreController.text,
                      'apellidos': _apellidosController.text,
                      'fechaNacimiento': _fechaNacimientoController.text,
                      'dni': _dniController.text,
                      'email': _correoController.text,
                      'direccion': _direccionController.text,
                      'localidad': _localidadController.text,
                      'telefono': _telefonoController.text,
                    };
                    Navigator.pop(context, datosActualizados);
                  },
                  label: const Text(
                    'Confirmar Cambios',
                    style: TextStyle(fontSize: 14),
                  ),
                  icon: const Icon(Icons.check, size: 18),
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
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
