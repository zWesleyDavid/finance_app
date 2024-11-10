import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../service/api_service.dart';

class CarteiraScreen extends StatefulWidget {
  @override
  _CarteiraScreenState createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  final ApiService apiService = ApiService(Client());
  double saldoCarteira = 0.0;
  bool isLoading = true;
  List<Map<String, dynamic>> extrato = []; // Lista de transações

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
  }

  Future<void> _fetchSaldo() async {
    try {
      final saldo = await apiService.getSaldoCarteira();
      final extratoData = await apiService.getExtrato();

      setState(() {
        saldoCarteira = saldo;
        extrato = extratoData;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao buscar saldo: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _adicionarReceita(double valor) async {
    final novoSaldo = saldoCarteira + valor;
    final transacao = {
      'titulo': 'Receita',
      'descricao': 'Receita adicionada sobre valor em conta',
      'valor': valor,
      'data': DateTime.now().toIso8601String(),
      'tipo': 'entrada',
    };

    try {
      await apiService.updateSaldoCarteira(novoSaldo);
      setState(() {
        saldoCarteira = novoSaldo;
        extrato.insert(0, transacao);
      });
      await apiService.addExtrato(transacao);
    } catch (e) {
      print('Erro ao adicionar saldo: $e');
    }
  }

  void _mostrarDialogoAdicionarSaldo() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Saldo'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(hintText: 'Digite o valor a ser adicionado'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final valor = double.tryParse(controller.text) ?? 0;
                if (valor > 0) {
                  _adicionarReceita(valor);
                }
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExtratoTab(String filtro) {
    List<Map<String, dynamic>> filteredExtrato = [...extrato];
    
    if (filtro == 'Entradas') {
      filteredExtrato = extrato.where((item) => item['tipo'] == 'entrada').toList();
    } else if (filtro == 'Saídas') {
      filteredExtrato = extrato.where((item) => item['tipo'] == 'saida').toList();
    }

    filteredExtrato.sort((a, b) => DateTime.parse(b['data']).compareTo(DateTime.parse(a['data'])));

    return ListView.builder(
      itemCount: filteredExtrato.length,
      itemBuilder: (context, index) {
        final item = filteredExtrato[index];
        final valorFormatado = item['valor'] >= 0
            ? '+R\$ ${item['valor'].toStringAsFixed(2).replaceAll(".",",")}'
            : '-R\$ ${item['valor'].abs().toStringAsFixed(2).replaceAll(".",",")}';
        return ListTile(
          title: Text(item['titulo']),
          subtitle: Text(item['descricao']),
          trailing: Text(valorFormatado,
              style: TextStyle(
                  color: item['valor'] >= 0 ? Colors.green : Colors.red)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carteira'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saldo em Conta:',
                                style: TextStyle(fontSize: 18)),
                            Text('R\$ ${saldoCarteira.toStringAsFixed(2).replaceAll(".",",")}',
                                style: const TextStyle(fontSize: 24)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _mostrarDialogoAdicionarSaldo,
                          child: const Text('Adicionar Saldo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Extrato',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Tudo'),
                        Tab(text: 'Entradas'),
                        Tab(text: 'Saídas'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildExtratoTab('Tudo'),
                          _buildExtratoTab('Entradas'),
                          _buildExtratoTab('Saídas'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
