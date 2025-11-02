import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class TelaMensagensProfessor extends StatefulWidget {
  const TelaMensagensProfessor({super.key});

  @override
  State<TelaMensagensProfessor> createState() => _TelaMensagensProfessorState();
}

class _TelaMensagensProfessorState extends State<TelaMensagensProfessor> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();

  int? _selectedConversationIndex;
  Message? _replyingTo;
  Message? _editingMessage;
  String _conversationFilter = 'all'; // 'all', 'unread'

  // Mock data - será substituído por dados do MongoDB
  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      participantId: 'aluno1',
      participantName: 'Maria Silva',
      participantRole: 'RA: 24.00301-2',
      lastMessage: 'Professor, poderia me ajudar com a questão 5?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 3,
    ),
    Conversation(
      id: '2',
      participantId: 'aluno2',
      participantName: 'João Santos',
      participantRole: 'RA: 24.00302-2',
      lastMessage: 'Obrigado pela explicação!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 1,
      isTyping: true,
    ),
    Conversation(
      id: '3',
      participantId: 'aluno3',
      participantName: 'Ana Costa',
      participantRole: 'RA: 24.00303-2',
      lastMessage: 'Quando será a prova?',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
    ),
    Conversation(
      id: '4',
      participantId: 'aluno4',
      participantName: 'Carlos Mendes',
      participantRole: 'RA: 24.00304-2',
      lastMessage: 'Consegui resolver o exercício!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
    ),
    Conversation(
      id: '5',
      participantId: 'aluno5',
      participantName: 'Beatriz Lima',
      participantRole: 'RA: 24.00305-2',
      lastMessage: 'Bom dia, professor!',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
    ),
  ];

  final List<Message> _mockMessages = [
    Message(
      id: '1',
      content: 'Olá professor! Tenho uma dúvida sobre a atividade 3.',
      senderId: 'me',
      senderName: 'Eu',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: '2',
      content: 'Claro! Me diga qual é sua dúvida.',
      senderId: 'prof1',
      senderName: 'Prof. Silva',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      isRead: true,
    ),
    Message(
      id: '3',
      content: 'É sobre a questão 5. Não entendi como resolver.',
      senderId: 'me',
      senderName: 'Eu',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      isRead: true,
      reactions: ['👍', '😊'],
    ),
    Message(
      id: '4',
      content: 'Vou te enviar um material que vai ajudar!',
      senderId: 'prof1',
      senderName: 'Prof. Silva',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
      attachment: AttachedFile(
        name: 'exercicios_resolvidos.pdf',
        type: 'pdf',
        size: 2456789,
        url: 'https://example.com/file.pdf',
      ),
    ),
    Message(
      id: '5',
      content: 'Muito obrigado! Vou dar uma olhada.',
      senderId: 'me',
      senderName: 'Eu',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      isRead: true,
      replyToId: '4',
      replyToContent: 'Vou te enviar um material que vai ajudar!',
    ),
    Message(
      id: '6',
      content: 'Conseguiu entender? Qualquer dúvida, estou aqui!',
      senderId: 'prof1',
      senderName: 'Prof. Silva',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: true,
    ),
    Message(
      id: '7',
      content: 'Sim! Agora ficou mais claro. Muito obrigado pela ajuda!',
      senderId: 'me',
      senderName: 'Eu',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      reactions: ['❤️', '👍', '🎉'],
    ),
    Message(
      id: '8',
      content: 'De nada! Continue assim, você está indo muito bem nas aulas.',
      senderId: 'prof1',
      senderName: 'Prof. Silva',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
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
                  onTap: () {
                    // TODO: Adicionar reação via MongoDB
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reação $emoji adicionada!')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
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
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Deletar via MongoDB
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem deletada')),
                  );
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Enviar via MongoDB
    setState(() {
      _messageController.clear();
      _replyingTo = null;
      _editingMessage = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mensagem enviada!')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversationFilter == 'unread'
        ? _conversations.where((c) => c.unreadCount > 0).toList()
        : _conversations;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Lista de conversas
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mensagens',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
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
                ),
                const SizedBox(height: 8),
                Text(
                  'Converse com seus alunos',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar conversas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      itemCount: filteredConversations.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = filteredConversations[index];
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
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Área de conversa
          Expanded(
            flex: 3,
            child: _selectedConversationIndex == null
                ? Card(
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
                            'Escolha um aluno para começar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildChatArea(
                    filteredConversations[_selectedConversationIndex!],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(Conversation conversation) {
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
            child: ListView.builder(
              controller: _messagesScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mockMessages.length,
              itemBuilder: (context, index) {
                final message = _mockMessages[index];
                final isMe = message.senderId == 'me';
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
