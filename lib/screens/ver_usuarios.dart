import 'package:flutter/material.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            'EMPLEADO',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(onPressed: () {}, child: const Text('Botón 1')),
                    ElevatedButton(onPressed: () {}, child: const Text('Botón 2')),
                    ElevatedButton(onPressed: () {}, child: const Text('Botón 3')),
                    ElevatedButton(onPressed: () {}, child: const Text('Botón 4')),
                  ],
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('NOMBRE')),
                      DataColumn(label: Text('APELLDIOS')),
                      DataColumn(label: Text('FECHA NAC')),
                      DataColumn(label: Text('TELÉFONO')),
                      DataColumn(label: Text('EMAIL')),
                      DataColumn(label: Text('DIRECCIÓN')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('Juan')),
                        DataCell(Text('Pérez Gómez')),
                        DataCell(Text('12/03/1990')),
                        DataCell(Text('612345678')),
                        DataCell(Text('juan@email.com')),
                        DataCell(Text('Calle Falsa 123')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Ana')),
                        DataCell(Text('López Díaz')),
                        DataCell(Text('05/11/1985')),
                        DataCell(Text('698765432')),
                        DataCell(Text('ana@email.com')),
                        DataCell(Text('Av. Libertad 456')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Carlos')),
                        DataCell(Text('Ruiz Moreno')),
                        DataCell(Text('22/08/1978')),
                        DataCell(Text('654321987')),
                        DataCell(Text('carlos@email.com')),
                        DataCell(Text('C/ Gran Vía 789')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
