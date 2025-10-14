class Disciplina {
  final String id;
  final String nome;
  final String descricao;
  final String professorId;
  final String cor; // Cor em hex para identificação visual
  final List<String> alunoIds; // IDs dos alunos matriculados
  final DateTime dataCriacao;

  Disciplina({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.professorId,
    required this.cor,
    this.alunoIds = const [],
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'professorId': professorId,
      'cor': cor,
      'alunoIds': alunoIds,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      professorId: json['professorId'],
      cor: json['cor'],
      alunoIds: List<String>.from(json['alunoIds'] ?? []),
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  Disciplina copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? professorId,
    String? cor,
    List<String>? alunoIds,
    DateTime? dataCriacao,
  }) {
    return Disciplina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      professorId: professorId ?? this.professorId,
      cor: cor ?? this.cor,
      alunoIds: alunoIds ?? this.alunoIds,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
