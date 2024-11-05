import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
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

    ApiService resultado = await service.fetchDespesas();
    
  });

}