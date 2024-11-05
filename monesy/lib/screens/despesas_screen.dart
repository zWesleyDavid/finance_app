import 'package:flutter/material.dart';
import 'despesas_form.dart';
import '../service/api_service.dart';

class DespesaListScreen extends StatefulWidget {
  @override
  _DespesaListScreenState createState() => _DespesaListScreenState();
}

class _DespesaListScreenState extends State<DespesaListScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> despesas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDespesas();
  }

  void fetchDespesas() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.fetchDespesas();
      setState(() {
        despesas = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching despesas: $e');
      setState(() => isLoading = false);
    }
  }

  void deleteDespesa(String id, int index) async {
    try {
      await apiService.deleteDespesa(id);
      fetchDespesas(); // Atualiza a lista após a exclusão
    } catch (e) {
      print('Failed to delete despesa: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir despesa.')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Despesas'),
    ),
    body: ListView.builder(
      itemCount: despesas.length,
      itemBuilder: (context, index) {
        final despesa = despesas[index];
        return Dismissible(
          key: Key(despesa['id'].toString()),
          background: Container(color: Colors.red, child: Icon(Icons.delete)),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              deleteDespesa(despesa['id'], index);
            }
          },
          child: ListTile(
            title: Text(despesa['titulo']),
            subtitle: Text('Valor: ${despesa['valor']}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DespesaForm(despesa: despesa),
                  ),
                ).then((value) => fetchDespesas());
              },
            ),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DespesaForm()),
        ).then((value) => fetchDespesas());
      },
      child: Icon(Icons.add),
    ),
  );
}

}
