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
    try {
      // Converter peso - pode vir como String, int ou double
      double pesoValue;
      if (json['peso'] == null) {
        pesoValue = 0.0;
      } else if (json['peso'] is String) {
        pesoValue = double.parse(json['peso']);
      } else if (json['peso'] is int) {
        pesoValue = (json['peso'] as int).toDouble();
      } else {
        pesoValue = (json['peso'] as num).toDouble();
      }
      
      // Suportar tanto camelCase quanto snake_case
      final disciplinaId = json['disciplinaId']?.toString() ?? 
                          json['disciplina_id']?.toString() ?? '';
      final dataEntrega = json['dataEntrega'] ?? json['data_entrega'];
      final dataCriacao = json['dataCriacao'] ?? json['data_criacao'] ?? json['criado_em'];
      
      return Atividade(
        id: json['id']?.toString() ?? '',
        titulo: json['titulo']?.toString() ?? '',
        descricao: json['descricao']?.toString() ?? '',
        disciplinaId: disciplinaId,
        peso: pesoValue,
        dataEntrega: DateTime.parse(dataEntrega),
        dataCriacao: DateTime.parse(dataCriacao),
      );
    } catch (e) {
      print('[Atividade.fromJson] ERRO: $e');
      print('[Atividade.fromJson] JSON recebido: $json');
      rethrow;
    }
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

// Modelo para submissão de atividade pelo aluno
class SubmissaoAtividade {
  final String? id;
  final String atividadeId;
  final String alunoId;
  final String alunoNome;
  final List<ArquivoSubmissao> arquivos;
  final DateTime dataSubmissao;
  final String? comentario;
  final double? nota;
  final String? feedback;
  final DateTime? dataAvaliacao;

  SubmissaoAtividade({
    this.id,
    required this.atividadeId,
    required this.alunoId,
    required this.alunoNome,
    required this.arquivos,
    required this.dataSubmissao,
    this.comentario,
    this.nota,
    this.feedback,
    this.dataAvaliacao,
  });

  bool get foiAvaliada => nota != null;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'atividadeId': atividadeId,
      'alunoId': alunoId,
      'alunoNome': alunoNome,
      'arquivos': arquivos.map((a) => a.toJson()).toList(),
      'dataSubmissao': dataSubmissao.toIso8601String(),
      if (comentario != null) 'comentario': comentario,
      if (nota != null) 'nota': nota,
      if (feedback != null) 'feedback': feedback,
      if (dataAvaliacao != null) 'dataAvaliacao': dataAvaliacao!.toIso8601String(),
    };
  }

  factory SubmissaoAtividade.fromJson(Map<String, dynamic> json) {
    return SubmissaoAtividade(
      id: json['id']?.toString(),
      atividadeId: (json['atividadeId'] ?? json['atividade_id']).toString(),
      alunoId: (json['alunoId'] ?? json['aluno_id']).toString(),
      alunoNome: json['alunoNome'] ?? json['aluno_nome'] ?? '',
      arquivos: (json['arquivos'] as List)
          .map((a) => ArquivoSubmissao.fromJson(a))
          .toList(),
      dataSubmissao: DateTime.parse(json['dataSubmissao'] ?? json['data_submissao']),
      comentario: json['comentario'],
      nota: json['nota'] != null 
          ? ((json['nota'] is int) ? (json['nota'] as int).toDouble() : json['nota'].toDouble())
          : null,
      feedback: json['feedback'],
      dataAvaliacao: (json['dataAvaliacao'] ?? json['data_avaliacao']) != null
          ? DateTime.parse(json['dataAvaliacao'] ?? json['data_avaliacao'])
          : null,
    );
  }
}

// Modelo para arquivo enviado pelo aluno
class ArquivoSubmissao {
  final String? id;
  final String nomeOriginal;
  final String? arquivoId; // GridFS file ID
  final int tamanho;
  final String mimeType;
  final DateTime dataUpload;

  ArquivoSubmissao({
    this.id,
    required this.nomeOriginal,
    this.arquivoId,
    required this.tamanho,
    required this.mimeType,
    required this.dataUpload,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomeOriginal': nomeOriginal,
      if (arquivoId != null) 'arquivoId': arquivoId,
      'tamanho': tamanho,
      'mimeType': mimeType,
      'dataUpload': dataUpload.toIso8601String(),
    };
  }

  factory ArquivoSubmissao.fromJson(Map<String, dynamic> json) {
    return ArquivoSubmissao(
      id: json['id']?.toString(),
      nomeOriginal: json['nomeOriginal'] ?? json['nome_original'] ?? '',
      arquivoId: json['arquivoId'] ?? json['grid_fs_id']?.toString(),
      tamanho: json['tamanho'] is int ? json['tamanho'] : int.parse(json['tamanho'].toString()),
      mimeType: json['mimeType'] ?? json['mime_type'] ?? 'application/octet-stream',
      dataUpload: DateTime.parse(json['dataUpload'] ?? json['data_upload']),
    );
  }
}
