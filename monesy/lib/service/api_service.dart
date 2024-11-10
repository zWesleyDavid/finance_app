import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:monesy/domain/despesas.dart';

class ApiService {
  Client client;

  ApiService(this.client);

  final String baseUrl = 'http://localhost:3000';

  Future<Despesas> getDespesa() async {
    Uri uri = Uri.parse("http://localhost:3000/despesas");

    Response response = await client.get(uri);

    if (response.statusCode == 200) {
      return Despesas.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro');
  }

  Future<List<dynamic>> fetchDespesas() async {
    final response = await http.get(Uri.parse('$baseUrl/despesas'));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load despesas');
    }
  }

  Future<void> addDespesa(Map<String, dynamic> despesa) async {
    final response = await http.post(
      Uri.parse('$baseUrl/despesas'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(despesa),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add despesa');
    }
  }

  Future<void> deleteDespesa(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/despesas/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete despesa');
    }
  }

  Future<void> updateDespesa(String id, Map<String, dynamic> despesa) async {
    final response = await http.put(
      Uri.parse('$baseUrl/despesas/$id'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(despesa),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update despesa');
    }
  }

  Future<double> getSaldoCarteira() async {
    final response = await client.get(Uri.parse('$baseUrl/saldoCarteira'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valor'].toDouble();
    } else {
      throw Exception('Erro ao buscar saldo da carteira');
    }
  }

  Future<void> updateSaldoCarteira(double novoSaldo) async {
    final response = await client.put(
      Uri.parse('$baseUrl/saldoCarteira'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"valor": novoSaldo}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar saldo da carteira');
    }
  }

  Future<List<Map<String, dynamic>>> getExtrato() async {
    final response = await client.get(Uri.parse('$baseUrl/extrato'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Erro ao buscar o extrato');
    }
  }

  Future<void> addExtrato(Map<String, dynamic> transacao) async {
    final response = await client.post(
      Uri.parse('$baseUrl/extrato'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(transacao),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao adicionar transação ao extrato');
    }
  }
}
