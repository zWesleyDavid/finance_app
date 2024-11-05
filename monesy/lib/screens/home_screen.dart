import 'package:flutter/material.dart';
import 'despesas_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Ação para perfil
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Geral: R\$ 0,00', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Receitas: R\$ 0,00', style: TextStyle(fontSize: 18)),
            Text('Despesas: R\$ 0,00', style: TextStyle(fontSize: 18)),
            Text('Balanço: R\$ 0,00', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Projeção Geral:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: Center(
                child: Placeholder(
                    fallbackHeight: 200), // Placeholder para o gráfico
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Despesas'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DespesaListScreen()),
            );
          }
        },
      ),
    );
  }
}
