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

    if(response.statusCode == 200){
      return Despesas.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro');
  }

  Future<List<dynamic>> fetchDespesas() async {
    final response = await http.get(Uri.parse('$baseUrl/despesas'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
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
}
