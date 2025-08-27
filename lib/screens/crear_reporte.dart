import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CrearReporteScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculo;
  const CrearReporteScreen({super.key, required this.vehiculo});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _localidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  File? _fotoFile;

  bool _isSaving = false;
  bool _reporteRobadoActivo = false;
  bool _isLoadingReporte = true;

  bool get _formularioCompleto {
    return _fechaController.text.isNotEmpty &&
        _direccionController.text.isNotEmpty &&
        _localidadController.text.isNotEmpty &&
        _descripcionController.text.isNotEmpty;
  }

  void _actualizarEstado() => setState(() {});

  @override
  void initState() {
    super.initState();
    _fechaController.addListener(_actualizarEstado);
    _direccionController.addListener(_actualizarEstado);
    _localidadController.addListener(_actualizarEstado);
    _descripcionController.addListener(_actualizarEstado);
    _chequearReporteRobadoActivo();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _direccionController.dispose();
    _localidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _chequearReporteRobadoActivo() async {
    final user = FirebaseAuth.instance.currentUser;
    final vehiculoId = widget.vehiculo['id'];
    if (user == null || vehiculoId == null) {
      setState(() {
        _reporteRobadoActivo = false;
        _isLoadingReporte = false;
      });
      return;
    }

    try {
      final reportesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('vehiculos')
          .doc(vehiculoId)
          .collection('reportes');

      final querySnapshot = await reportesRef.orderBy('fechaCreacion', descending: true).get();

      Timestamp? ultimoRobado;
      Timestamp? ultimaRecuperacion;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final estado = (data['estadoVehiculo'] ?? '').toString().toLowerCase();
        final fecha = data['fechaCreacion'] as Timestamp?;
        if (fecha == null) continue;

        if (estado == 'robado') {
          if (ultimoRobado == null || fecha.compareTo(ultimoRobado) > 0) {
            ultimoRobado = fecha;
          }
        } else if (estado == 'en posesión' || estado == 'en posesion') {
          if (ultimaRecuperacion == null || fecha.compareTo(ultimaRecuperacion) > 0) {
            ultimaRecuperacion = fecha;
          }
        }
      }

      final bool roboActivo = ultimoRobado != null &&
          (ultimaRecuperacion == null || ultimoRobado.compareTo(ultimaRecuperacion) > 0);

      setState(() {
        _reporteRobadoActivo = roboActivo;
        _isLoadingReporte = false;
      });
    } catch (e) {
      setState(() {
        _reporteRobadoActivo = false;
        _isLoadingReporte = false;
      });
    }
  }

  Future<void> _eliminarReportesAntiguos() async {
    final user = FirebaseAuth.instance.currentUser;
    final vehiculoId = widget.vehiculo['id'];
    if (user == null || vehiculoId == null) return;

    try {
      final reportesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('vehiculos')
          .doc(vehiculoId)
          .collection('reportes');

      final querySnapshot = await reportesRef.where('estadoVehiculo', isEqualTo: 'robado').get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Al Eliminar Reportes: $e')),
      );
    }
  }

  /*
  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _fotoFile = File(pickedFile.path);
      });
    }
  }
  */
  Future<void> _guardarReporte() async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final vehiculoId = widget.vehiculo['id'];
      final estadoVehiculoActual = widget.vehiculo['estado'] ?? 'desconocido';

      if (user == null || vehiculoId == null) throw Exception('Error de autenticación o ID');
      if (estadoVehiculoActual.toString().toLowerCase() != 'robado') {
        throw Exception('Solo Se Puede Crear Reporte Si El Vehículo Está Robado');
      }
      if (_reporteRobadoActivo) {
        throw Exception('Ya Hay Un Reporte Activo De Robo');
      }

      await _eliminarReportesAntiguos();

      final nuevaLocalidad = _localidadController.text.trim();
      final fechaTexto = _fechaController.text.trim();

      String anioMes = 'desconocido';
      try {
        final fechaDate = DateTime.parse(fechaTexto);
        final anio = fechaDate.year.toString();
        final mes = fechaDate.month.toString().padLeft(2, '0');
        anioMes = '$anio-$mes';
      } catch (_) {}

      final nuevoReporte = {
        'fecha': fechaTexto,
        'direccion': _direccionController.text,
        'localidad': nuevaLocalidad,
        'descripcion': _descripcionController.text,
        'foto': _fotoFile?.path,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'timestamp': Timestamp.now(),
        'estadoVehiculo': estadoVehiculoActual,
      };

      final reportesRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('vehiculos')
          .doc(vehiculoId)
          .collection('reportes');

      final estadisticaLocalidadRef =
          FirebaseFirestore.instance.collection('estadisticas_localidades').doc(nuevaLocalidad);

      final estadisticaFechaRef =
          FirebaseFirestore.instance.collection('estadistica_fecha').doc(anioMes);

      final batch = FirebaseFirestore.instance.batch();

      batch.set(reportesRef.doc(), nuevoReporte);
      batch.set(
        estadisticaLocalidadRef,
        {
          'nombre': nuevaLocalidad,
          'count': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
      batch.set(
        estadisticaFechaRef,
        {
          'anioMes': anioMes,
          'count': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehiculo;
    final estadoActual = (v['estado'] ?? '').toString().toLowerCase();
    final descripcionVehiculo = '${v['marca']} ${v['modelo']} ${v['color']} - ${v['matricula']}';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text('CREAR REPORTE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoadingReporte
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(descripcionVehiculo,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 16),
                          if (estadoActual == 'robado') ...[
                            _buildEditableField('Fecha:', _fechaController, isDate: true),
                            const SizedBox(height: 16),
                            _buildEditableField('Dirección:', _direccionController),
                            const SizedBox(height: 16),
                            _buildEditableField('Localidad:', _localidadController),
                            const SizedBox(height: 16),
                            const Text('Descripción del Suceso:',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _descripcionController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                            ),
                            /*const SizedBox(height: 24),
                            const Text('Subir Foto:',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(_fotoFile != null
                                        ? 'Foto: ${_fotoFile!.path.split('/').last}'
                                        : 'Ningún Archivo Seleccionado'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                /*ElevatedButton(
                                  onPressed: _seleccionarFoto,
                                  child: const Text('Buscar...'),
                                ),
                                */
                              ],
                            ),*/
                          ] else ...[
                            const Text(
                              'No Se Puede Crear Un Reporte Si El Vehículo No Está Marcado Como "Robado".',
                              style:
                                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (estadoActual == 'robado')
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _formularioCompleto && !_isSaving && !_reporteRobadoActivo
                              ? _guardarReporte
                              : null,
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Crear Reporte', style: TextStyle(fontSize: 16)),
                                ),
                        ),
                      ),
                    ),
                  if (_reporteRobadoActivo)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Ya Existe Un Reporte Activo De Robo',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isDate = false}) {
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
                    firstDate: DateTime(2000),
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