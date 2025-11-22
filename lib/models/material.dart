class MaterialDidatico {
  final String id;
  final String titulo;
  final String descricao;
  final String disciplinaId;
  final TipoMaterial tipo;
  final String url; // URL ou caminho do arquivo
  final double tamanho; // Tamanho em MB
  final DateTime dataUpload;

  MaterialDidatico({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.disciplinaId,
    required this.tipo,
    required this.url,
    required this.tamanho,
    required this.dataUpload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'disciplinaId': disciplinaId,
      'tipo': tipo.toString(),
      'url': url,
      'tamanho': tamanho,
      'dataUpload': dataUpload.toIso8601String(),
    };
  }

  factory MaterialDidatico.fromJson(Map<String, dynamic> json) {
    return MaterialDidatico(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      disciplinaId: json['disciplinaId'],
      tipo: TipoMaterial.values.firstWhere((e) => e.toString() == json['tipo']),
      url: json['url'],
      tamanho: json['tamanho'].toDouble(),
      dataUpload: DateTime.parse(json['dataUpload']),
    );
  }

  MaterialDidatico copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? disciplinaId,
    TipoMaterial? tipo,
    String? url,
    double? tamanho,
    DateTime? dataUpload,
  }) {
    return MaterialDidatico(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      tamanho: tamanho ?? this.tamanho,
      dataUpload: dataUpload ?? this.dataUpload,
    );
  }
}

enum TipoMaterial { pdf, imagem, video, documento, link }
