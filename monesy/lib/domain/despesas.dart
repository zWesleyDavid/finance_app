class Despesas {

  String id;
  String titulo;
  String descricao;
  int valor;

  Despesas({required this.id, required this.titulo, required this.descricao, required this.valor});

  factory Despesas.fromJson(Map<String, dynamic> objJson) {
    return Despesas(id: objJson["id"], titulo: objJson["titulo"], descricao: objJson["descricao"], valor: objJson["valor"]);
  }

}