import 'package:flutter/material.dart';
import '../professor/tela_inicial_professor.dart';
import '../aluno/tela_inicial_aluno.dart';
import '../../services/api_service.dart';
import '../../services/theme_controller.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Função chamada ao pressionar o botão de login
  void _performLogin() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Validação básica
    if (emailController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite "aluno" ou "professor"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inputText = emailController.text.trim().toLowerCase();

      // DEV MODE: Login simplificado para testes
      if (inputText == 'aluno' || inputText == 'professor') {
        // Simular mock user data
        final userData = {
          'id': inputText == 'professor' ? 1 : 3,
          'nome': inputText == 'professor' ? 'Carlos Mendes' : 'João Silva',
          'email': inputText == 'professor'
              ? 'carlos.mendes@email.com'
              : 'joao.silva@email.com',
          'tipo': inputText,
        };

        await _apiService.devLogin(inputText, userData);

        if (!mounted) return;

        // Navegar para a tela apropriada
        if (inputText == 'professor') {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TelaInicialProfessor(),
            ),
          );
        } else {
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const TelaInicialAluno()),
          );
        }
        return;
      }

      // Se não for "aluno" ou "professor", mostrar erro
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Digite "aluno" ou "professor" para fazer login'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa MediaQuerty para garantir que o contêiner de login
    // não seja muito grande em telas amplas.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 450 ? 400 : screenWidth * 0.9;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background com gradiente adaptável ao tema
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF0F0C29),
                        Color(0xFF302B63),
                        Color(0xFF24243E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFFFFF5EB),
                        Color(0xFFFFE8D6),
                        Color(0xFFFFF0E1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
          ),
          // Decoração geométrica no fundo
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: isDark ? 0.1 : 0.3,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.cyan : Colors.orange,
                    width: 40,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: Opacity(
              opacity: isDark ? 0.08 : 0.25,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.purple : Colors.orange.shade200,
                ),
              ),
            ),
          ),
          // Botão de alternância de tema no canto superior direito
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.cyan : Colors.orange,
                  ),
                  onPressed: () {
                    ThemeController.instance.toggle();
                  },
                  tooltip: isDark
                      ? 'Mudar para tema claro'
                      : 'Mudar para tema escuro',
                ),
              ),
            ),
          ),
          // Conteúdo principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A2E).withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo com tratamento para tema escuro
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logo-dark.png'
                              : 'assets/images/logo.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Portal Educacional',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.cyan : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.cyan.withValues(alpha: 0.1)
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.cyan.withValues(alpha: 0.3)
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.developer_mode,
                                  size: 16,
                                  color: isDark ? Colors.cyan : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'MODO DESENVOLVIMENTO',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.cyan : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Digite "aluno" ou "professor"',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Campo de Login
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _performLogin(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Login Rápido',
                          labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.grey.shade700,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: isDark ? Colors.cyan : Colors.orange,
                          ),
                          hintText: 'Digite "aluno" ou "professor"',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.cyan : Colors.orange,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão de Entrar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? Colors.cyan : Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: isDark ? 0 : 5,
                          ),
                          onPressed: _isLoading ? null : _performLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'ENTRAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
