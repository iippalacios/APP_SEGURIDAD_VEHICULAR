import 'package:flutter/material.dart';

class ModificarVehiculoScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculo;

  const ModificarVehiculoScreen({
    super.key,
    required this.vehiculo,
  });

  @override
  State<ModificarVehiculoScreen> createState() => _ModificarVehiculoScreenState();
}

class _ModificarVehiculoScreenState extends State<ModificarVehiculoScreen> {
  late TextEditingController _matriculaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _colorController;

  late String _tipoVehiculo;
  late String _estadoVehiculo;

  @override
  void initState() {
    super.initState();
    final vehiculo = widget.vehiculo;
    _matriculaController = TextEditingController(text: vehiculo['matricula'] ?? '');
    _marcaController = TextEditingController(text: vehiculo['marca'] ?? '');
    _modeloController = TextEditingController(text: vehiculo['modelo'] ?? '');
    _colorController = TextEditingController(text: vehiculo['color'] ?? '');
    _tipoVehiculo = vehiculo['tipo'] ?? 'Coche';
    _estadoVehiculo = vehiculo['estado'] ?? 'En Posesión';
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
            'MODIFICAR VEHÍCULO',
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildEditableField('MATRÍCULA', _matriculaController),
              const SizedBox(height: 16),
              _buildEditableField('MARCA', _marcaController),
              const SizedBox(height: 16),
              _buildEditableField('MODELO', _modeloController),
              const SizedBox(height: 16),
              _buildEditableField('COLOR', _colorController),
              const SizedBox(height: 24),
              const Text(
                'TIPO DE VEHÍCULO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _tipoBoton('Coche'),
                  const SizedBox(width: 16),
                  _tipoBoton('Moto'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ESTADO DEL VEHÍCULO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _estadoBoton('En Posesión', Colors.blue),
                  const SizedBox(width: 16),
                  _estadoBoton('Robado', Colors.redAccent),
                ],
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final vehiculoModificado = {
                'matricula': _matriculaController.text.trim(),
                'marca': _marcaController.text.trim(),
                'modelo': _modeloController.text.trim(),
                'color': _colorController.text.trim(),
                'tipo': _tipoVehiculo,
                'estado': _estadoVehiculo,
              };
              Navigator.pop(context, vehiculoModificado);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Guardar Cambios',
                style: TextStyle(fontSize: 16),
              ),
            ),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tipoVehiculo = tipo;
          });
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: seleccionado ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tipo,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoBoton(String estado, Color color) {
    final bool seleccionado = _estadoVehiculo == estado;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _estadoVehiculo = estado;
          });
        },
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: seleccionado ? color : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            estado,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
