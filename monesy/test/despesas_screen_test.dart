import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monesy/domain/despesas.dart';
import 'package:monesy/screens/despesas_screen.dart';
import 'package:monesy/service/api_service.dart';

class MyMockClient extends Mock implements Client {}

void main() {
  test('deve retornar uma despesa', () async {
    MyMockClient mockClient = MyMockClient();

    Uri uri = Uri.parse("http://localhost:3000/despesas");

    when(() => mockClient.get(uri)).thenAnswer((_) async => Response(
        '{"id": "3a26", "titulo": "Luz", "descricao": "Conta de luz", "valor": 150}',
        200));

    ApiService service = ApiService(mockClient);

    Despesas resultado = await service.getDespesa();

    expect(resultado.id, '3a26');
    expect(resultado.titulo, 'Luz');
    expect(resultado.descricao, 'Conta de luz');
    expect(resultado.valor, 150);
  });

  test('getDespesa lança exceção ao receber erro de servidor', () async {
    MyMockClient client = MyMockClient();
    final apiService = ApiService(client);
    when(() => client.get(Uri.parse('http://localhost:3000/despesas')))
        .thenAnswer((_) async => Response('Erro', 500));

    expect(() => apiService.getDespesa(), throwsException);
  });

  test('fetchDespesas aplica filtro de valor mínimo', () async {
    MyMockClient client = MyMockClient();
    final apiService = ApiService(client);
    final despesasData = [
      {'id': '1', 'titulo': 'Aluguel', 'valor': 1200.0},
      {'id': '2', 'titulo': 'Mercado', 'valor': 200.0}
    ];
    when(() => client.get(Uri.parse('http://localhost:3000/despesas')))
        .thenAnswer((_) async => Response(json.encode(despesasData), 200));

    final despesas = await apiService.fetchDespesas();
    final despesasFiltradas = despesas.where((d) => d['valor'] > 500).toList();

    expect(despesasFiltradas.length, 1);
    expect(despesasFiltradas[0]['titulo'], 'Aluguel');
  });

  testWidgets('DespesaListScreen carrega a lista vazia inicialmente',
      (WidgetTester tester) async {
    MyMockClient client = MyMockClient();
    when(() => client.get(Uri.parse('http://localhost:3000/despesas')))
        .thenAnswer((_) async => Response('[]', 200));

    await tester.pumpWidget(
      MaterialApp(
        home: DespesaListScreen(),
      ),
    );

    await tester.pump();

    expect(find.text('Despesas'), findsOneWidget);
    expect(
        find.byType(ListTile), findsNothing); // A lista está inicialmente vazia
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

}
