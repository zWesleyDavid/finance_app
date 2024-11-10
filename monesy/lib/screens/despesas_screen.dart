import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'despesas_form.dart';
import '../service/api_service.dart';

class DespesaListScreen extends StatefulWidget {
  @override
  _DespesaListScreenState createState() => _DespesaListScreenState();
}

class _DespesaListScreenState extends State<DespesaListScreen> {
  final ApiService _apiService = ApiService(Client());
  List<dynamic> _despesas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDespesas();
  }

  Future<void> _fetchDespesas() async {
    setState(() => _isLoading = true);
    try {
      final despesas = await _apiService.fetchDespesas();
      setState(() {
        _despesas = despesas;
        _isLoading = false;
      });
    } catch (e) {
      _handleError('Erro ao buscar despesas: $e');
    }
  }

  Future<void> _deleteDespesa(String id) async {
    try {
      await _apiService.deleteDespesa(id);
      _fetchDespesas(); // Atualiza a lista após a exclusão
    } catch (e) {
      _showSnackBar('Erro ao excluir despesa.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleError(String message) {
    print(message);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Despesas')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildDespesaList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDespesaList() {
    if (_despesas.isEmpty) {
      return Center(child: Text('Nenhuma despesa encontrada.'));
    }
    return ListView.builder(
      itemCount: _despesas.length,
      itemBuilder: (context, index) {
        final despesa = _despesas[index];
        return _buildDespesaTile(despesa);
      },
    );
  }

  Widget _buildDespesaTile(Map<String, dynamic> despesa) {
    return Dismissible(
      key: Key(despesa['id'].toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteDespesa(despesa['id']),
      child: ListTile(
        title: Text(despesa['titulo']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${despesa['descricao']}'),
            Text('Valor: R\$${despesa['valor']}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => _navigateToForm(despesa: despesa),
        ),
      ),
    );
  }

  void _navigateToForm({Map<String, dynamic>? despesa}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DespesaForm(despesa: despesa),
      ),
    ).then((_) => _fetchDespesas());
  }
}
