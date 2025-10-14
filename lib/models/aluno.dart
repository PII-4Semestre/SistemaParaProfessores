class Aluno {
  final String id;
  final String nome;
  final String ra;
  final String email;
  final List<String> disciplinaIds; // IDs das disciplinas em que está matriculado

  Aluno({
    required this.id,
    required this.nome,
    required this.ra,
    required this.email,
    this.disciplinaIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'ra': ra,
      'email': email,
      'disciplinaIds': disciplinaIds,
    };
  }

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      ra: json['ra'],
      email: json['email'],
      disciplinaIds: List<String>.from(json['disciplinaIds'] ?? []),
    );
  }

  Aluno copyWith({
    String? id,
    String? nome,
    String? ra,
    String? email,
    List<String>? disciplinaIds,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ra: ra ?? this.ra,
      email: email ?? this.email,
      disciplinaIds: disciplinaIds ?? this.disciplinaIds,
    );
  }
}
