class Cerva {
  String id;
  String nome;
  int votos;

  Cerva({this.id, this.nome, this.votos});

  factory Cerva.fromMap(Map<String, dynamic> obj) => Cerva(
        id: obj['id'],
        nome: obj['nome'],
        votos: obj['votos'],
      );
}
