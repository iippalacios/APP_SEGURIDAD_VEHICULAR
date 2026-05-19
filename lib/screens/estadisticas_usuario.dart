import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EstadisticasUsuario extends StatefulWidget {
  const EstadisticasUsuario({super.key});

  @override
  State<EstadisticasUsuario> createState() => _EstadisticasUsuarioState();
}

class _EstadisticasUsuarioState extends State<EstadisticasUsuario> {
  bool loading = true;
  String? error;

  Map<String, int> localidadesRobos = {};
  Map<String, int> reportesPorMes = {};

  String localidadesFiltro = '5';
  String reportesFiltro = '12';

  String filtroYear = '';
  String filtroMonth = '';

  List<String> anosDisponibles = [];
  final List<String> mesesNombre = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final snapshotLocalidades = await firestore
          .collection('estadisticas_localidades')
          .orderBy('count', descending: true)
          .get();

      Map<String, int> conteosLocalidades = {};
      for (final doc in snapshotLocalidades.docs) {
        final nombre = doc.id;
        final count = doc.get('count') as int? ?? 0;
        conteosLocalidades[nombre] = count;
      }

      final snapshotFechas = await firestore
          .collection('estadistica_fecha')
          .orderBy(FieldPath.documentId)
          .get();

      Map<String, int> conteoPorMes = {};
      Set<String> anosSet = {};
      for (final doc in snapshotFechas.docs) {
        final id = doc.id; // formato "YYYY-MM"
        final count = doc.get('count') as int? ?? 0;
        conteoPorMes[id] = count;

        if (id.length >= 4) {
          anosSet.add(id.substring(0, 4));
        }
      }

      setState(() {
        localidadesRobos = conteosLocalidades;
        reportesPorMes = conteoPorMes;
        anosDisponibles = anosSet.toList()..sort((a, b) => b.compareTo(a));
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error Al Cargar Estadísticas: $e';
        loading = false;
      });
    }
  }

  Map<String, int> get reportesFiltrados {
    var data = reportesPorMes.entries.toList();

    if (filtroYear.isNotEmpty) {
      data = data.where((e) => e.key.startsWith(filtroYear)).toList();
      if (filtroMonth.isNotEmpty) {
        data = data.where((e) => e.key.substring(5, 7) == filtroMonth).toList();
      }
    }

    data.sort((a, b) => a.key.compareTo(b.key));

    if (data.length > int.parse(reportesFiltro)) {
      data = data.sublist(data.length - int.parse(reportesFiltro));
    }

    return Map.fromEntries(data);
  }

  Widget buildBarChart(Map<String, int> data, String titulo) {
    final entries = data.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    return SizedBox(
      height: 250,
      child: SfCartesianChart(
        title: ChartTitle(text: titulo),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<MapEntry<String, int>, String>>[
          ColumnSeries<MapEntry<String, int>, String>(
            dataSource: entries,
            xValueMapper: (entry, _) => entry.key,
            yValueMapper: (entry, _) => entry.value,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            color: Colors.blue,
          )
        ],
      ),
    );
  }

  void _onLocalidadesFiltroChanged(String? val) {
    if (val == null) return;
    setState(() {
      localidadesFiltro = val;
    });
  }

  void _onReportesFiltroChanged(String? val) {
    if (val == null) return;
    setState(() {
      reportesFiltro = val;
    });
  }

  void _onFiltroYearChanged(String? val) {
    if (val == null) return;
    setState(() {
      filtroYear = val;
      filtroMonth = '';
    });
  }

  void _onFiltroMonthChanged(String? val) {
    if (val == null) return;
    setState(() {
      filtroMonth = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'ESTADÍSTICAS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HISTÓRICO DE LOCALIDADES',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Mostrar: '),
                              DropdownButton<String>(
                                value: localidadesFiltro,
                                items: ['5', '10', '15', '20']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _onLocalidadesFiltroChanged,
                              ),
                            ],
                          ),
                          buildBarChart(
                              Map.fromEntries(localidadesRobos.entries
                                  .take(int.parse(localidadesFiltro))),
                              'ROBOS'),
                          const SizedBox(height: 32),
                          const Text(
                            'MEDIA REPORTES POR MES',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          // Aquí se envuelve la fila de filtros en un scroll horizontal
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Año: '),
                                DropdownButton<String>(
                                  value: filtroYear.isEmpty ? null : filtroYear,
                                  hint: const Text('Todos'),
                                  items: [
                                    const DropdownMenuItem(
                                      value: '',
                                      child: Text('Todos'),
                                    ),
                                    ...anosDisponibles.map((year) =>
                                        DropdownMenuItem(
                                          value: year,
                                          child: Text(year),
                                        )),
                                  ],
                                  onChanged: _onFiltroYearChanged,
                                ),
                                const SizedBox(width: 20),
                                const Text('Mes: '),
                                DropdownButton<String>(
                                  value: filtroMonth.isEmpty ? null : filtroMonth,
                                  hint: const Text('Todos'),
                                  items: [
                                    const DropdownMenuItem(
                                      value: '',
                                      child: Text('Todos'),
                                    ),
                                    ...List.generate(
                                      mesesNombre.length,
                                      (i) => DropdownMenuItem(
                                        value: (i + 1).toString().padLeft(2, '0'),
                                        child: Text(mesesNombre[i]),
                                      ),
                                    ),
                                  ],
                                  onChanged: filtroYear.isEmpty
                                      ? null
                                      : _onFiltroMonthChanged,
                                ),
                                const SizedBox(width: 20),
                                const Text('Últimos: '),
                                DropdownButton<String>(
                                  value: reportesFiltro,
                                  items: ['6', '12', '18', '24']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _onReportesFiltroChanged,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildBarChart(reportesFiltrados, 'REPORTES'),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
