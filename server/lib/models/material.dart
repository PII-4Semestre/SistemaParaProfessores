import 'package:mongo_dart/mongo_dart.dart';

/// Modelo para materiais didáticos armazenados no MongoDB
class Material {
  final ObjectId? id;
  final int disciplinaId;
  final int professorId;
  final String titulo;
  final String? descricao;
  final String tipo; // 'apostila', 'slide', 'video', 'link', 'documento'
  final List<String> tags;
  final List<Arquivo> arquivos;
  final String? linkExterno;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final bool ativo;

  Material({
    this.id,
    required this.disciplinaId,
    required this.professorId,
    required this.titulo,
    this.descricao,
    required this.tipo,
    this.tags = const [],
    this.arquivos = const [],
    this.linkExterno,
    DateTime? criadoEm,
    this.atualizadoEm,
    this.ativo = true,
  }) : criadoEm = criadoEm ?? DateTime.now();

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['_id'] as ObjectId?,
      disciplinaId: json['disciplina_id'] as int,
      professorId: json['professor_id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      tipo: json['tipo'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      arquivos: (json['arquivos'] as List<dynamic>?)
              ?.map((a) => Arquivo.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      linkExterno: json['link_externo'] as String?,
      criadoEm: (json['criado_em'] as DateTime?) ?? DateTime.now(),
      atualizadoEm: json['atualizado_em'] as DateTime?,
      ativo: json['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'disciplina_id': disciplinaId,
      'professor_id': professorId,
      'titulo': titulo,
      if (descricao != null) 'descricao': descricao,
      'tipo': tipo,
      'tags': tags,
      'arquivos': arquivos.map((a) => a.toJson()).toList(),
      if (linkExterno != null) 'link_externo': linkExterno,
      'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      'ativo': ativo,
    };
  }

  Material copyWith({
    ObjectId? id,
    int? disciplinaId,
    int? professorId,
    String? titulo,
    String? descricao,
    String? tipo,
    List<String>? tags,
    List<Arquivo>? arquivos,
    String? linkExterno,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    bool? ativo,
  }) {
    return Material(
      id: id ?? this.id,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      professorId: professorId ?? this.professorId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      tags: tags ?? this.tags,
      arquivos: arquivos ?? this.arquivos,
      linkExterno: linkExterno ?? this.linkExterno,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      ativo: ativo ?? this.ativo,
    );
  }
}

/// Modelo para metadados de arquivos (usados com GridFS)
class Arquivo {
  final ObjectId? gridFsId; // ID do arquivo no GridFS
  final String nomeOriginal;
  final String? nomeArmazenado;
  final String mimeType;
  final int tamanhoBytes;
  final DateTime uploadEm;

  Arquivo({
    this.gridFsId,
    required this.nomeOriginal,
    this.nomeArmazenado,
    required this.mimeType,
    required this.tamanhoBytes,
    DateTime? uploadEm,
  }) : uploadEm = uploadEm ?? DateTime.now();

  factory Arquivo.fromJson(Map<String, dynamic> json) {
    return Arquivo(
      gridFsId: json['gridfs_id'] as ObjectId?,
      nomeOriginal: json['nome_original'] as String,
      nomeArmazenado: json['nome_armazenado'] as String?,
      mimeType: json['mime_type'] as String,
      tamanhoBytes: json['tamanho_bytes'] as int,
      uploadEm: (json['upload_em'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (gridFsId != null) 'gridfs_id': gridFsId,
      'nome_original': nomeOriginal,
      if (nomeArmazenado != null) 'nome_armazenado': nomeArmazenado,
      'mime_type': mimeType,
      'tamanho_bytes': tamanhoBytes,
      'upload_em': uploadEm,
    };
  }

  /// Retorna o tamanho formatado (KB, MB, GB)
  String get tamanhoFormatado {
    if (tamanhoBytes < 1024) return '$tamanhoBytes B';
    if (tamanhoBytes < 1024 * 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(2)} KB';
    }
    if (tamanhoBytes < 1024 * 1024 * 1024) {
      return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(tamanhoBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
