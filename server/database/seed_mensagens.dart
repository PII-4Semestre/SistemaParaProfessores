import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'http://localhost:8080/api/mensagens';

Future<void> enviarMensagem({
  required String remetenteId,
  required String destinatarioId,
  required String conteudo,
  String? replyToId,
}) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'remetenteId': remetenteId,
        'destinatarioId': destinatarioId,
        'conteudo': conteudo,
        if (replyToId != null) 'replyToId': replyToId,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Mensagem enviada: ${conteudo.substring(0, 30)}...');
    } else {
      print('❌ Erro ao enviar mensagem: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}

void main() async {
  print('🚀 Populando mensagens no MongoDB...\n');

  // === Conversas entre Aluno Exemplo (4) e Joao Santos (5) ===
  print('📨 Criando conversa com Joao Santos (RA001)...');
  
  await enviarMensagem(
    remetenteId: '5',
    destinatarioId: '4',
    conteudo: 'Oi! Você está participando do projeto de Flutter também?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '5',
    conteudo: 'Sim! Estou no projeto. Como você está indo com as atividades?',
  );
  
  await enviarMensagem(
    remetenteId: '5',
    destinatarioId: '4',
    conteudo: 'Estou com dificuldade na parte de integração com API. Você conseguiu fazer?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '5',
    conteudo: 'Sim, consegui! É preciso usar o pacote http. Quer que eu te explique melhor?',
  );
  
  await enviarMensagem(
    remetenteId: '5',
    destinatarioId: '4',
    conteudo: 'Seria ótimo! Podemos marcar uma call depois da aula?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '5',
    conteudo: 'Claro! Te mando o link da meet às 15h, pode ser?',
  );

  // === Conversas entre Aluno Exemplo (4) e Ana Costa (6) ===
  print('\n📨 Criando conversa com Ana Costa (RA002)...');
  
  await enviarMensagem(
    remetenteId: '6',
    destinatarioId: '4',
    conteudo: 'Oi! Vi que você tirou nota boa na prova de matemática. Pode me ajudar com derivadas?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '6',
    conteudo: 'Claro! Qual parte específica você está com dúvida?',
  );
  
  await enviarMensagem(
    remetenteId: '6',
    destinatarioId: '4',
    conteudo: 'É sobre a regra da cadeia. Não consigo entender quando aplicar.',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '6',
    conteudo: 'A regra da cadeia é usada quando você tem uma função dentro de outra. Tipo f(g(x)).',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '6',
    conteudo: 'A derivada seria: f\'(g(x)) * g\'(x). Consegue visualizar?',
  );
  
  await enviarMensagem(
    remetenteId: '6',
    destinatarioId: '4',
    conteudo: 'Ahhh, agora fez sentido! Muito obrigada pela ajuda! 😄',
  );
  
  await enviarMensagem(
    remetenteId: '6',
    destinatarioId: '4',
    conteudo: 'Você tem os exercícios da lista 2 resolvidos?',
  );

  // === Conversas entre Aluno Exemplo (4) e Pedro Lima (7) ===
  print('\n📨 Criando conversa com Pedro Lima (RA003)...');
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '7',
    conteudo: 'E aí Pedro! Viu que tem entrega da atividade de física amanhã?',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Nossa, tinha esquecido! Valeu por lembrar!',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Você já terminou o relatório?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '7',
    conteudo: 'Já, terminei ontem. Se quiser posso te passar o modelo que usei.',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Seria perfeito! Pode mandar?',
  );
  
  await enviarMensagem(
    remetenteId: '4',
    destinatarioId: '7',
    conteudo: 'Vou te enviar por email. Mas não copia igual, hein! 😅',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Pode deixar! Só vou usar como referência mesmo.',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Consegui terminar! Muito obrigado pela ajuda! 🎉',
  );
  
  await enviarMensagem(
    remetenteId: '7',
    destinatarioId: '4',
    conteudo: 'Bora almoçar juntos hoje?',
  );

  print('\n✅ Seed de mensagens concluído com sucesso!');
  print('📊 Total: 22 mensagens criadas entre 3 conversas');
}
