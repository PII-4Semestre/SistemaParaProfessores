class Mensagem {
  final String id;
  final String remetenteId;
  final String destinatarioId;
  final String conteudo;
  final DateTime dataEnvio;
  final bool lida;
  final List<String> reacoes;
  final String? replyToId;
  final String? replyToContent;
  final bool editada;
  final DateTime? dataEdicao;

  Mensagem({
    required this.id,
    required this.remetenteId,
    required this.destinatarioId,
    required this.conteudo,
    required this.dataEnvio,
    this.lida = false,
    this.reacoes = const [],
    this.replyToId,
    this.replyToContent,
    this.editada = false,
    this.dataEdicao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remetenteId': remetenteId,
      'destinatarioId': destinatarioId,
      'conteudo': conteudo,
      'dataEnvio': dataEnvio.toIso8601String(),
      'lida': lida,
      'reacoes': reacoes,
      if (replyToId != null) 'replyToId': replyToId,
      if (replyToContent != null) 'replyToContent': replyToContent,
      'editada': editada,
      if (dataEdicao != null) 'dataEdicao': dataEdicao!.toIso8601String(),
    };
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id']?.toString() ?? '',
      remetenteId: json['remetenteId']?.toString() ?? '',
      destinatarioId: json['destinatarioId']?.toString() ?? '',
      conteudo: json['conteudo']?.toString() ?? '',
      dataEnvio: DateTime.parse(json['dataEnvio'] ?? DateTime.now().toIso8601String()),
      lida: json['lida'] ?? false,
      reacoes: (json['reacoes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      replyToId: json['replyToId']?.toString(),
      replyToContent: json['replyToContent']?.toString(),
      editada: json['editada'] ?? false,
      dataEdicao: json['dataEdicao'] != null ? DateTime.parse(json['dataEdicao']) : null,
    );
  }

  Mensagem copyWith({
    String? id,
    String? remetenteId,
    String? destinatarioId,
    String? conteudo,
    DateTime? dataEnvio,
    bool? lida,
    List<String>? reacoes,
    String? replyToId,
    String? replyToContent,
    bool? editada,
    DateTime? dataEdicao,
  }) {
    return Mensagem(
      id: id ?? this.id,
      remetenteId: remetenteId ?? this.remetenteId,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      conteudo: conteudo ?? this.conteudo,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      lida: lida ?? this.lida,
      reacoes: reacoes ?? this.reacoes,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      editada: editada ?? this.editada,
      dataEdicao: dataEdicao ?? this.dataEdicao,
    );
  }
}
