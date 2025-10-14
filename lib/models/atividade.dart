class Atividade {
  final String id;
  final String titulo;
  final String descricao;
  final String disciplinaId;
  final double peso;
  final DateTime dataEntrega;
  final DateTime dataCriacao;

  Atividade({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.disciplinaId,
    required this.peso,
    required this.dataEntrega,
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'disciplinaId': disciplinaId,
      'peso': peso,
      'dataEntrega': dataEntrega.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      disciplinaId: json['disciplinaId'],
      peso: json['peso'].toDouble(),
      dataEntrega: DateTime.parse(json['dataEntrega']),
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  Atividade copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? disciplinaId,
    double? peso,
    DateTime? dataEntrega,
    DateTime? dataCriacao,
  }) {
    return Atividade(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      peso: peso ?? this.peso,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
