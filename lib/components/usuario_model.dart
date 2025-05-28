class UsuarioModel {
  final String id;
  final String usuario;
  final String nome;
  String? conexao;

  UsuarioModel({
    required this.id,
    required this.usuario,
    required this.nome,
    this.conexao,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['_id'] ?? json['id'],
      usuario: json['usuario'],
      nome: json['nome'],
      conexao: json['conexao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'usuario': usuario,
      'nome': nome,
      'conexao': conexao,
    };
  }
}