import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monesy/domain/despesas.dart';
import 'package:monesy/service/api_service.dart';

class MyMockClient extends Mock implements Client {
  
}

void main() {
  
  test('deve retornar uma despesa', () async {

    MyMockClient mockClient = MyMockClient();

    Uri uri = Uri.parse("http://localhost:3000/despesas");

    when(() => mockClient.get(uri))
    .thenAnswer((_) async => Response('{"id": "3a26", "titulo": "Luz", "descricao": "Conta de luz", "valor": 150}', 200));

    ApiService service = ApiService(mockClient);

    Despesas resultado = await service.getDespesa();

    expect(resultado.id, '3a26');
    expect(resultado.titulo, 'Luz');
    expect(resultado.descricao, 'Conta de luz');
    expect(resultado.valor, 150);
    
  });

  test('',() async {

  });

  test('',() async {
    
  });

  test('',() async {
    
  });

}