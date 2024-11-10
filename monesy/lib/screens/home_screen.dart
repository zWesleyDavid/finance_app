import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'despesas_screen.dart';
import 'carteira_screen.dart';
import '../service/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService(Client());
  double saldoCarteira = 0.0;
  double receitas = 0.0;
  double despesas = 0.0;
  List<Map<String, dynamic>> listaDespesas = [];

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _fetchDespesas();
    _fetchExtrato(); // Fetch data from extrato
  }

  Future<void> _fetchSaldo() async {
    try {
      final saldo = await apiService.getSaldoCarteira();
      setState(() {
        saldoCarteira = saldo;
      });
      _updateBalanco(); // Update balance whenever saldo is fetched
    } catch (e) {
      print('Erro ao buscar saldo: $e');
    }
  }

  Future<void> _fetchDespesas() async {
    try {
      final despesas = await apiService.fetchDespesas();
      setState(() {
        listaDespesas = List<Map<String, dynamic>>.from(despesas);
      });
    } catch (e) {
      print('Erro ao buscar despesas: $e');
    }
  }

  Future<void> _fetchExtrato() async {
    try {
      final extrato = await apiService.getExtrato();
      double totalReceitas = 0.0;
      double totalDespesas = 0.0;

      for (var item in extrato) {
        if (item['tipo'] == 'entrada') {
          totalReceitas += item['valor'];
        } else if (item['tipo'] == 'saida') {
          totalDespesas += item['valor'].abs(); // Convert to positive
        }
      }

      setState(() {
        receitas = totalReceitas;
        despesas = totalDespesas;
      });
      _updateBalanco(); // Update balance whenever extrato is fetched
    } catch (e) {
      print('Erro ao buscar extrato: $e');
    }
  }

  void _updateBalanco() {
    // This will recalculate and update the UI when called
    setState(() {
      // Balance is just saldoCarteira, but you can adjust logic if needed
    });
  }

  Future<void> _pagarDespesa(Map<String, dynamic> despesa) async {
    final double valorDespesa = despesa['valor'];

    if (saldoCarteira < valorDespesa) {
      _showDialog(
        'Saldo Insuficiente',
        'Você não tem saldo suficiente para pagar esta conta. Por favor, adicione saldo à sua conta.',
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      'Deseja pagar essa conta?',
      'Valor: R\$ ${valorDespesa.toStringAsFixed(2).replaceAll(".", ",")}',
    );

    if (confirm) {
      try {
        final novoSaldo = saldoCarteira - valorDespesa;
        await apiService.updateSaldoCarteira(novoSaldo);

        final transacao = {
          'titulo': despesa['titulo'],
          'descricao': 'Conta paga',
          'valor': -valorDespesa,
          'data': DateTime.now().toIso8601String(),
          'tipo': 'saida',
        };

        await apiService.addExtrato(transacao);

        await apiService.deleteDespesa(despesa['id']);

        setState(() {
          saldoCarteira = novoSaldo;
          listaDespesas.remove(despesa);
        });
        _fetchExtrato(); // Update extrato after payment
        _showDialog('Pagamento realizado com sucesso', 'A despesa foi paga.');
        _fetchDespesas();
      } catch (e) {
        _showDialog('Erro', 'Erro ao realizar o pagamento da despesa.');
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title, style: TextStyle(fontFamily: 'Lufga')),
              content: Text(content, style: TextStyle(fontFamily: 'Lufga')),
              actions: [
                TextButton(
                  child:
                      Text('Cancelar', style: TextStyle(fontFamily: 'Lufga')),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child:
                      Text('Confirmar', style: TextStyle(fontFamily: 'Lufga')),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontFamily: 'Lufga')),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(fontFamily: 'Lufga')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Lufga',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSaldoAtual(),
            SizedBox(height: 16),
            _buildBalancoReceitasDespesas(),
            _buildProjecaoGeral(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarListaDespesas,
        child: Icon(Icons.payment),
        tooltip: 'Pagar contas',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Carteira'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Despesas'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarteiraScreen()),
            ).then((_) => _fetchSaldo());
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DespesaListScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildSaldoAtual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saldo atual',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Lufga',
            color: Color(0xFF202020),
          ),
        ),
        Text(
          'R\$ ${saldoCarteira.toStringAsFixed(2).replaceAll(".", ",")}',
          style: TextStyle(
            fontSize: 32,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.bold,
            color: Color(0xFF202020),
          ),
        ),
      ],
    );
  }

  Widget _buildBalancoReceitasDespesas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Balanço',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF202020),
                fontFamily: 'Lufga',
              )),
        ),
        Text(
          'R\$ ${(saldoCarteira).toStringAsFixed(2).replaceAll(".", ",")}',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Lufga',
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Despesas',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lufga',
                        color: Color(0xFF202020))),
                Text(
                  'R\$ ${despesas.toStringAsFixed(2).replaceAll(".", ",")}',
                  style: TextStyle(
                      fontSize: 18, fontFamily: 'Lufga', color: Colors.red),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receitas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202020),
                      fontFamily: 'Lufga',
                    )),
                Text(
                  'R\$ ${receitas.toStringAsFixed(2).replaceAll(".", ",")}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontFamily: 'Lufga',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjecaoGeral() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Projeção Geral',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lufga',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202020))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Despesas',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Lufga',
                  )),
              Text('Receitas',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Lufga',
                  )),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: (receitas + despesas) > 0
                ? despesas / (receitas + despesas)
                : 0,
            backgroundColor: Colors.green.withOpacity(0.3),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildGastosPorCategoria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Gastos por categoria',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lufga',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202020))),
        ),
        Center(
            child:
                Placeholder(fallbackHeight: 200)), // Placeholder para gráfico
      ],
    );
  }

  void _mostrarListaDespesas() async {
    await _fetchDespesas();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (listaDespesas.isEmpty) {
          return Center(
              child: Text(
            'Nenhuma despesa encontrada.',
            style: TextStyle(
              fontFamily: 'Lufga',
            ),
          ));
        }
        return ListView.builder(
          itemCount: listaDespesas.length,
          itemBuilder: (BuildContext context, int index) {
            final despesa = listaDespesas[index];
            return ListTile(
              title: Text(
                despesa['titulo'],
                style: TextStyle(
                  fontFamily: 'Lufga',
                ),
              ),
              subtitle: Text(
                'R\$ ${despesa['valor'].toStringAsFixed(2).replaceAll(".", ",")}',
                style: TextStyle(
                  fontFamily: 'Lufga',
                ),
              ),
              onTap: () => _pagarDespesa(despesa),
            );
          },
        );
      },
    );
  }
}
