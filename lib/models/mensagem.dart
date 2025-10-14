class Mensagem {
  final String id;
  final String remetenteId;
  final String destinatarioId;
  final String conteudo;
  final DateTime dataEnvio;
  final bool lida;

  Mensagem({
    required this.id,
    required this.remetenteId,
    required this.destinatarioId,
    required this.conteudo,
    required this.dataEnvio,
    this.lida = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remetenteId': remetenteId,
      'destinatarioId': destinatarioId,
      'conteudo': conteudo,
      'dataEnvio': dataEnvio.toIso8601String(),
      'lida': lida,
    };
  }

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'],
      remetenteId: json['remetenteId'],
      destinatarioId: json['destinatarioId'],
      conteudo: json['conteudo'],
      dataEnvio: DateTime.parse(json['dataEnvio']),
      lida: json['lida'] ?? false,
    );
  }

  Mensagem copyWith({
    String? id,
    String? remetenteId,
    String? destinatarioId,
    String? conteudo,
    DateTime? dataEnvio,
    bool? lida,
  }) {
    return Mensagem(
      id: id ?? this.id,
      remetenteId: remetenteId ?? this.remetenteId,
      destinatarioId: destinatarioId ?? this.destinatarioId,
      conteudo: conteudo ?? this.conteudo,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      lida: lida ?? this.lida,
    );
  }
}
