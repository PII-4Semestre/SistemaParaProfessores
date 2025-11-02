class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String? senhaHash;
  final String tipo; // 'professor' ou 'aluno'
  final String? ra;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    this.senhaHash,
    required this.tipo,
    this.ra,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senhaHash: json['senha_hash'],
      tipo: json['tipo'],
      ra: json['ra'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      if (ra != null) 'ra': ra,
      if (criadoEm != null) 'criado_em': criadoEm!.toIso8601String(),
      if (atualizadoEm != null)
        'atualizado_em': atualizadoEm!.toIso8601String(),
    };
  }
}

class Disciplina {
  final int? id;
  final String nome;
  final String? descricao;
  final int professorId;
  final String cor;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Disciplina({
    this.id,
    required this.nome,
    this.descricao,
    required this.professorId,
    this.cor = '#FF9800',
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      professorId: json['professor_id'],
      cor: json['cor'] ?? '#FF9800',
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      if (descricao != null) 'descricao': descricao,
      'professor_id': professorId,
      'cor': cor,
      if (criadoEm != null) 'criado_em': criadoEm!.toIso8601String(),
      if (atualizadoEm != null)
        'atualizado_em': atualizadoEm!.toIso8601String(),
    };
  }
}

class Atividade {
  final int? id;
  final int disciplinaId;
  final String titulo;
  final String? descricao;
  final double peso;
  final DateTime? dataEntrega;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Atividade({
    this.id,
    required this.disciplinaId,
    required this.titulo,
    this.descricao,
    this.peso = 1.0,
    this.dataEntrega,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      disciplinaId: json['disciplina_id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      peso: (json['peso'] as num).toDouble(),
      dataEntrega: json['data_entrega'] != null
          ? DateTime.parse(json['data_entrega'])
          : null,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'disciplina_id': disciplinaId,
      'titulo': titulo,
      if (descricao != null) 'descricao': descricao,
      'peso': peso,
      if (dataEntrega != null) 'data_entrega': dataEntrega!.toIso8601String(),
      if (criadoEm != null) 'criado_em': criadoEm!.toIso8601String(),
      if (atualizadoEm != null)
        'atualizado_em': atualizadoEm!.toIso8601String(),
    };
  }
}

class Nota {
  final int? id;
  final int atividadeId;
  final int alunoId;
  final double nota;
  final String? comentario;
  final DateTime? atribuidaEm;
  final DateTime? atualizadaEm;

  Nota({
    this.id,
    required this.atividadeId,
    required this.alunoId,
    required this.nota,
    this.comentario,
    this.atribuidaEm,
    this.atualizadaEm,
  });

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: json['id'],
      atividadeId: json['atividade_id'],
      alunoId: json['aluno_id'],
      nota: (json['nota'] as num).toDouble(),
      comentario: json['comentario'],
      atribuidaEm: json['atribuida_em'] != null
          ? DateTime.parse(json['atribuida_em'])
          : null,
      atualizadaEm: json['atualizada_em'] != null
          ? DateTime.parse(json['atualizada_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'atividade_id': atividadeId,
      'aluno_id': alunoId,
      'nota': nota,
      if (comentario != null) 'comentario': comentario,
      if (atribuidaEm != null) 'atribuida_em': atribuidaEm!.toIso8601String(),
      if (atualizadaEm != null)
        'atualizada_em': atualizadaEm!.toIso8601String(),
    };
  }
}
