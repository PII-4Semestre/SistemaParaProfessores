class Usuario {
  final String id;
  final String nome;
  final String email;
  final TipoUsuario tipo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'email': email, 'tipo': tipo.toString()};
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'],
      email: json['email'],
      tipo: TipoUsuario.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoUsuario.aluno,
      ),
    );
  }
}

enum TipoUsuario { professor, aluno, admin }
