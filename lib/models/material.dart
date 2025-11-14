/// Modelo de Material Didático compatível com MongoDB
class Material {
  final String? id; // ObjectId do MongoDB (opcional para criação)
  final String disciplinaId;
  final String professorId;
  final String titulo;
  final String? descricao;
  final String tipo; // 'documento', 'video', 'apresentacao', 'imagem', 'link'
  final List<String> tags;
  final List<Arquivo> arquivos;
  final String? linkExterno;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final bool ativo;

  Material({
    this.id,
    required this.disciplinaId,
    required this.professorId,
    required this.titulo,
    this.descricao,
    this.tipo = 'documento',
    this.tags = const [],
    this.arquivos = const [],
    this.linkExterno,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    this.ativo = true,
  })  : criadoEm = criadoEm ?? DateTime.now(),
        atualizadoEm = atualizadoEm ?? DateTime.now();

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      disciplinaId: json['disciplina_id']?.toString() ?? '',
      professorId: json['professor_id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      tipo: json['tipo'] ?? 'documento',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      arquivos: json['arquivos'] != null
          ? (json['arquivos'] as List)
              .map((a) => Arquivo.fromJson(a))
              .toList()
          : [],
      linkExterno: json['link_externo'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : DateTime.now(),
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : DateTime.now(),
      ativo: json['ativo'] ?? true,
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
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
      'ativo': ativo,
    };
  }

  Material copyWith({
    String? id,
    String? disciplinaId,
    String? professorId,
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

  // Getter para verificar se tem arquivos
  bool get temArquivos => arquivos.isNotEmpty;

  // Getter para verificar se é um link externo
  bool get isLinkExterno => linkExterno != null && linkExterno!.isNotEmpty;

  // Getter para ícone baseado no tipo
  String get icone {
    switch (tipo) {
      case 'video':
        return '🎥';
      case 'apresentacao':
        return '📊';
      case 'imagem':
        return '🖼️';
      case 'link':
        return '🔗';
      case 'documento':
      default:
        return '📄';
    }
  }
}

/// Modelo de Arquivo armazenado no GridFS
class Arquivo {
  final String gridFsId; // ID do arquivo no GridFS
  final String nomeOriginal;
  final String mimeType;
  final int tamanhoBytes;
  final DateTime uploadEm;

  Arquivo({
    required this.gridFsId,
    required this.nomeOriginal,
    required this.mimeType,
    required this.tamanhoBytes,
    DateTime? uploadEm,
  }) : uploadEm = uploadEm ?? DateTime.now();

  factory Arquivo.fromJson(Map<String, dynamic> json) {
    return Arquivo(
      gridFsId: json['grid_fs_id']?.toString() ?? '',
      nomeOriginal: json['nome_original'] ?? '',
      mimeType: json['mime_type'] ?? 'application/octet-stream',
      tamanhoBytes: json['tamanho_bytes'] ?? 0,
      uploadEm: json['upload_em'] != null
          ? DateTime.parse(json['upload_em'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grid_fs_id': gridFsId,
      'nome_original': nomeOriginal,
      'mime_type': mimeType,
      'tamanho_bytes': tamanhoBytes,
      'upload_em': uploadEm.toIso8601String(),
    };
  }

  // Getter para tamanho formatado
  String get tamanhoFormatado {
    if (tamanhoBytes < 1024) {
      return '$tamanhoBytes B';
    } else if (tamanhoBytes < 1024 * 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(1)} KB';
    } else if (tamanhoBytes < 1024 * 1024 * 1024) {
      return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(tamanhoBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Getter para extensão do arquivo
  String get extensao {
    final partes = nomeOriginal.split('.');
    return partes.length > 1 ? partes.last.toUpperCase() : '';
  }

  // Getter para ícone baseado no tipo MIME
  String get icone {
    if (mimeType.startsWith('image/')) return '🖼️';
    if (mimeType.startsWith('video/')) return '🎥';
    if (mimeType.startsWith('audio/')) return '🎵';
    if (mimeType.contains('pdf')) return '📕';
    if (mimeType.contains('word')) return '📘';
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return '📗';
    }
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) {
      return '📊';
    }
    if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return '📦';
    }
    return '📄';
  }
}
