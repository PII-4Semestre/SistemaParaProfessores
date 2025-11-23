import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

// Modelo de mensagem (pronto para MongoDB)
class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isRead;
  final List<String> reactions;
  final String? replyToId;
  final String? replyToContent;
  final AttachedFile? attachment;
  final bool isEdited;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.isRead = false,
    this.reactions = const [],
    this.replyToId,
    this.replyToContent,
    this.attachment,
    this.isEdited = false,
  });
}

class AttachedFile {
  final String name;
  final String type; // 'image', 'pdf', 'doc', etc
  final int size; // em bytes
  final String url;

  AttachedFile({
    required this.name,
    required this.type,
    required this.size,
    required this.url,
  });
}

class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String participantRole;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isTyping;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.participantRole,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isTyping = false,
  });
}

class TelaMensagensAluno extends StatefulWidget {
  const TelaMensagensAluno({super.key});

  @override
  State<TelaMensagensAluno> createState() => _TelaMensagensAlunoState();
}

class _TelaMensagensAlunoState extends State<TelaMensagensAluno> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  final ApiService _apiService = ApiService();

  int? _selectedConversationIndex;
  Message? _replyingTo;
  Message? _editingMessage;
  String _conversationFilter = 'all'; // 'all', 'unread'
  
  bool _isLoadingMessages = false;
  bool _isInitializing = true;
  String? _currentUserId;

  List<Conversation> _conversations = [];

  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    print('🚀 Iniciando tela de mensagens do aluno...');
    await _apiService.init();
    _currentUserId = _apiService.currentUser?['id']?.toString();
    print('👤 Usuário atual ID: $_currentUserId');
    if (_currentUserId != null) {
      await _carregarConversas();
    } else {
      print('⚠️ Nenhum usuário logado encontrado');
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
      print('✅ Inicialização completa');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  Future<void> _carregarConversas() async {
    try {
      if (_currentUserId != null) {
        print('🔍 Carregando conversas para usuário ID: $_currentUserId');
        final conversasData = await _apiService.getConversas(int.parse(_currentUserId!));
        print('✅ Recebidas ${conversasData.length} conversas');
        
        final conversasReais = <Conversation>[];
        
        for (var data in conversasData) {
          final participantId = data['participantId']?.toString() ?? '';
          
          // Filtrar apenas IDs numéricos (ignorar mock data como prof1, prof2, etc)
          if (int.tryParse(participantId) == null) {
            print('⚠️ Ignorando conversa mock: $participantId');
            continue;
          }
          
          String participantName = 'Professor $participantId';
          
          // Buscar nome real do usuário
          try {
            final usuario = await _apiService.getUsuario(participantId);
            participantName = usuario['nome'] ?? participantName;
          } catch (e) {
            print('⚠️ Erro ao buscar usuário $participantId: $e');
          }
          
          DateTime? lastMessageTime;
          if (data['dataUltimaMensagem'] != null) {
            try {
              lastMessageTime = DateTime.parse(data['dataUltimaMensagem']);
            } catch (e) {
              lastMessageTime = null;
            }
          }
          
          conversasReais.add(Conversation(
            id: participantId,
            participantId: participantId,
            participantName: participantName,
            participantRole: '',
            lastMessage: data['ultimaMensagem'],
            lastMessageTime: lastMessageTime,
            unreadCount: data['naoLidas'] ?? 0,
          ));
        }
        
        if (mounted) {
          setState(() {
            _conversations = conversasReais;
          });
          print('📋 ${conversasReais.length} conversas carregadas na UI');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar conversas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar conversas: $e')),
        );
      }
    }
  }

  // Converter dados da API para Message da UI
  Message _dadosParaMessage(Map<String, dynamic> data) {
    return Message(
      id: data['id']?.toString() ?? '',
      content: data['conteudo'] ?? '',
      senderId: data['remetenteId']?.toString() ?? '',
      senderName: data['remetenteId']?.toString() == _currentUserId ? 'Eu' : 'Professor',
      timestamp: data['dataEnvio'] != null ? DateTime.parse(data['dataEnvio']) : DateTime.now(),
      isRead: data['lida'] ?? false,
      reactions: (data['reacoes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      replyToId: data['respostaParaId']?.toString(),
      replyToContent: data['respostaParaConteudo']?.toString(),
      isEdited: data['editada'] ?? false,
    );
  }

  Future<void> _carregarMensagens(String outroUsuarioId) async {
    if (_currentUserId == null) return;
    
    // Validar se os IDs são numéricos
    if (int.tryParse(_currentUserId!) == null || int.tryParse(outroUsuarioId) == null) {
      print('⚠️ IDs não numéricos: $_currentUserId, $outroUsuarioId (ignorando)');
      setState(() => _isLoadingMessages = false);
      return;
    }
    
    setState(() => _isLoadingMessages = true);
    try {
      print('📨 Carregando mensagens entre $_currentUserId e $outroUsuarioId');
      final mensagensData = await _apiService.getMensagens(
        usuarioId: int.parse(_currentUserId!),
        outroUsuarioId: int.parse(outroUsuarioId),
      );
      print('✅ ${mensagensData.length} mensagens carregadas');
      
      final mensagensConvertidas = mensagensData.map((data) => _dadosParaMessage(data)).toList();
      
      if (mounted) {
        setState(() {
          _messages = mensagensConvertidas;
          _isLoadingMessages = false;
        });
        
        // Marcar mensagens recebidas como lidas
        for (var mensagem in mensagensConvertidas) {
          if (mensagem.senderId == outroUsuarioId && !mensagem.isRead) {
            try {
              await _apiService.marcarMensagemComoLida(mensagem.id);
              print('✅ Mensagem ${mensagem.id} marcada como lida');
            } catch (e) {
              print('⚠️ Erro ao marcar mensagem ${mensagem.id} como lida: $e');
            }
          }
        }
        
        // Atualizar contador de não lidas
        _carregarConversas();
        
        _scrollToBottom();
      }
    } catch (e) {
      print('❌ Erro ao carregar mensagens: $e');
      if (mounted) {
        setState(() => _isLoadingMessages = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mensagens: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messagesScrollController.hasClients) {
        _messagesScrollController.animateTo(
          _messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      return days[timestamp.weekday % 7];
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showReactionPicker(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reagir à mensagem'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['👍', '❤️', '😊', '😂', '😮', '😢', '🎉', '🔥']
              .map(
                (emoji) => InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      if (message.reactions.contains(emoji)) {
                        // Remover reação se já existe
                        await _apiService.removerReacao(
                          mensagemId: message.id,
                          emoji: emoji,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reação removida!')),
                        );
                      } else {
                        // Adicionar nova reação
                        await _apiService.adicionarReacao(
                          mensagemId: message.id,
                          emoji: emoji,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reação adicionada!')),
                        );
                      }
                      // Recarregar mensagens para atualizar as reações
                      if (_selectedConversationIndex != null) {
                        final conversation = _conversations[_selectedConversationIndex!];
                        _carregarMensagens(conversation.participantId);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao reagir: $e')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.reactions.contains(emoji) 
                          ? Colors.orange.withValues(alpha: 0.2)
                          : null,
                      border: Border.all(
                        color: message.reactions.contains(emoji) 
                            ? Colors.orange
                            : Colors.grey[300]!,
                        width: message.reactions.contains(emoji) ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.senderId == 'me') ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingMessage = message;
                    _messageController.text = message.content;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Deletar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await _apiService.deletarMensagem(message.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mensagem deletada')),
                    );
                    // Recarregar mensagens
                    if (_selectedConversationIndex != null) {
                      final conversation = _conversations[_selectedConversationIndex!];
                      _carregarMensagens(conversation.participantId);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao deletar mensagem: $e')),
                    );
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Responder'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _replyingTo = message;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensagem copiada')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction),
              title: const Text('Reagir'),
              onTap: () {
                Navigator.pop(context);
                _showReactionPicker(message);
              },
            ),
            // Opção para marcar como não lida (apenas mensagens recebidas e lidas)
            if (message.senderId != _currentUserId && message.senderId != 'me' && message.isRead)
              ListTile(
                leading: const Icon(Icons.mark_chat_unread),
                title: const Text('Marcar como não lida'),
                onTap: () async {
                  Navigator.pop(context);
                  // TODO: Implementar endpoint para marcar como não lida no backend
                  // await apiService.marcarComoNaoLida(message.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recurso ainda não disponível')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickFile() {
    // TODO: Implementar file picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar arquivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Imagem'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecionando imagem...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Documento PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecionando PDF...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Outro arquivo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecionando arquivo...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_currentUserId == null || _selectedConversationIndex == null) return;

    final content = _messageController.text.trim();
    final conversation = _conversations[_selectedConversationIndex!];

    try {
      if (_editingMessage != null) {
        // Editar mensagem existente
        await _apiService.editarMensagem(
          mensagemId: _editingMessage!.id,
          novoConteudo: content,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensagem editada!')),
        );
      } else {
        // Enviar nova mensagem
        await _apiService.enviarMensagem(
          remetenteId: int.parse(_currentUserId!),
          destinatarioId: int.parse(conversation.participantId),
          conteudo: content,
          respostaParaId: _replyingTo?.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensagem enviada!')),
        );
      }

      setState(() {
        _messageController.clear();
        _replyingTo = null;
        _editingMessage = null;
      });

      // Recarregar mensagens e conversas
      _carregarMensagens(conversation.participantId);
      _carregarConversas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  void _mostrarDialogoNovaConversa() async {
    try {
      // Buscar lista de professores
      print('🔍 Buscando lista de professores...');
      final response = await _apiService.getUsuarios();
      final professores = response.where((user) => user['tipo'] == 'professor').toList();
      print('✅ ${professores.length} professores encontrados');

      if (!mounted) return;

      if (professores.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum professor encontrado no sistema')),
        );
        return;
      }

      // Mostrar diálogo para selecionar professor
      final professorSelecionado = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nova Conversa'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: Column(
              children: [
                const Text('Selecione um professor para iniciar a conversa:'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: professores.length,
                    itemBuilder: (context, index) {
                      final professor = professores[index];
                      final professorId = professor['id']?.toString() ?? '';
                      final professorNome = professor['nome'] ?? 'Professor $professorId';
                      final professorEmail = professor['email'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text(
                            professorNome.substring(0, 2).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(professorNome),
                        subtitle: Text(professorEmail),
                        onTap: () => Navigator.pop(context, professor),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (professorSelecionado == null || !mounted) return;

      final professorId = professorSelecionado['id']?.toString() ?? '';
      final professorNome = professorSelecionado['nome'] ?? 'Professor $professorId';

      // Verificar se já existe conversa com esse professor
      final conversaExistente = _conversations.indexWhere(
        (c) => c.participantId == professorId,
      );

      if (conversaExistente != -1) {
        // Conversa já existe, apenas selecionar
        setState(() {
          _selectedConversationIndex = conversaExistente;
        });
        _carregarMensagens(professorId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversa com $professorNome já existe')),
        );
      } else {
        // Criar nova conversa (adicionar à lista localmente)
        setState(() {
          _conversations.add(Conversation(
            id: professorId,
            participantId: professorId,
            participantName: professorNome,
            participantRole: 'Professor',
            lastMessage: null,
            lastMessageTime: null,
            unreadCount: 0,
          ));
          _selectedConversationIndex = _conversations.length - 1;
          _messages = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nova conversa com $professorNome iniciada! Digite a primeira mensagem.')),
        );
      }
    } catch (e) {
      print('❌ Erro ao buscar professores: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar professores: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentUserId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Erro: Usuário não autenticado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor, faça login novamente',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final filteredConversations = _conversationFilter == 'unread'
        ? _conversations.where((c) => c.unreadCount > 0).toList()
        : _conversations;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;
        final showChatArea = _selectedConversationIndex != null;

        // Em telas estreitas, mostrar apenas uma view por vez
        if (!isWideScreen && showChatArea) {
          return _buildChatArea(
            filteredConversations[_selectedConversationIndex!],
          );
        }

        return Padding(
          padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
          child: isWideScreen
              ? Row(
                  children: [
                    // Lista de conversas
                    Expanded(
                      flex: 2,
                      child: _buildConversationsList(
                        filteredConversations,
                        isWideScreen,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Área de conversa
                    Expanded(
                      flex: 3,
                      child: _selectedConversationIndex == null
                          ? _buildEmptyState()
                          : _buildChatArea(
                              filteredConversations[
                                  _selectedConversationIndex!],
                            ),
                    ),
                  ],
                )
              : _buildConversationsList(filteredConversations, isWideScreen),
        );
      },
    );
  }

  Widget _buildConversationsList(
    List<Conversation> conversations,
    bool isWideScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWideScreen)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Mensagens',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _mostrarDialogoNovaConversa,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nova Conversa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              // Filtro de conversas
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    label: Text('Todas'),
                    icon: Icon(Icons.chat, size: 16),
                  ),
                  ButtonSegment(
                    value: 'unread',
                    label: Text('Não lidas'),
                    icon: Icon(Icons.mark_chat_unread, size: 16),
                  ),
                ],
                selected: {_conversationFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _conversationFilter = newSelection.first;
                  });
                },
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mensagens',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Filtro de conversas - versão mobile
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    label: Text('Todas'),
                  ),
                  ButtonSegment(
                    value: 'unread',
                    label: Text('Não lidas'),
                  ),
                ],
                selected: {_conversationFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _conversationFilter = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        if (isWideScreen) ...[
          const SizedBox(height: 8),
          Text(
            'Converse com seus professores',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
        SizedBox(height: isWideScreen ? 24 : 16),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar conversas...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma conversa encontrada',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final isSelected = _selectedConversationIndex == index;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.orange.withValues(
                          alpha: 0.1,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: conversation.unreadCount > 0
                                  ? Colors.orange
                                  : Colors.grey[300],
                              child: Text(
                                conversation.participantName
                                    .substring(0, 2)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (conversation.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          conversation.participantName,
                          style: TextStyle(
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          conversation.isTyping
                              ? 'digitando...'
                              : (conversation.lastMessage ?? 'Sem mensagens'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                            fontStyle: conversation.isTyping
                                ? FontStyle.italic
                                : FontStyle.normal,
                            color: conversation.isTyping
                                ? Colors.orange
                                : null,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (conversation.lastMessageTime != null)
                              Text(
                                _formatTimestamp(
                                  conversation.lastMessageTime!,
                                ),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            if (conversation.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${conversation.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedConversationIndex = index;
                          });
                          // Carregar mensagens da conversa
                          final conversation = _conversations[index];
                          _carregarMensagens(conversation.participantId);
                          _scrollToBottom();
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.orange.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecione uma conversa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um professor para começar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea(Conversation conversation) {
    // Rolar para o final quando o chat for construído
    _scrollToBottom();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = MediaQuery.of(context).size.width > 900;
        
        return Card(
          child: Column(
            children: [
              // Cabeçalho da conversa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    // Botão voltar em telas estreitas
                    if (!isWideScreen)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _selectedConversationIndex = null;
                          });
                        },
                      ),
                    CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    conversation.participantName.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.participantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        conversation.participantRole,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (conversation.isTyping)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'digitando...',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Mensagens
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, 
                              size: 64, 
                              color: Colors.grey[300]
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma mensagem ainda',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicie a conversa enviando uma mensagem',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _messagesScrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == _currentUserId || message.senderId == 'me';
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          // Reply indicator
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Respondendo a ${_replyingTo!.senderName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          _replyingTo!.content,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _replyingTo = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          // Campo de entrada
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Anexar arquivo',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _editingMessage != null
                          ? 'Editando mensagem...'
                          : 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: _editingMessage != null
                          ? const Icon(Icons.edit, color: Colors.blue)
                          : null,
                    ),
                    onChanged: (value) {
                      // TODO: Enviar indicador de digitação
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(
                    _editingMessage != null ? Icons.check : Icons.send,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  tooltip: _editingMessage != null ? 'Salvar edição' : 'Enviar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Reply indicator
              if (message.replyToContent != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isMe ? Colors.orange : Colors.grey).withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 30,
                        color: isMe ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message.replyToContent!,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Message bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isMe ? Colors.orange : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.senderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    // Attachment
                    if (message.attachment != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              message.attachment!.type == 'image'
                                  ? Icons.image
                                  : message.attachment!.type == 'pdf'
                                  ? Icons.picture_as_pdf
                                  : Icons.insert_drive_file,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.attachment!.name,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatFileSize(message.attachment!.size),
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.download,
                              size: 16,
                              color: isMe ? Colors.white : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    // Content
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Time and status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.isEdited)
                          Text(
                            'editada • ',
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : Colors.black45,
                            ),
                          ),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : Colors.black54,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.blue
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Reactions
              if (message.reactions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: message.reactions.map((emoji) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
