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
      id: json['_id'] ?? json['id'] ?? '', // Garante que 'id' nunca seja null
      usuario: json['usuario'] ?? '', // Garante que 'usuario' nunca seja null
      nome: json['nome'] ?? '', // Garante que 'nome' nunca seja null
      conexao: json['conexao'], // Permite null para 'conexao'
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