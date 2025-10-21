import 'package:flutter/material.dart';
import '../professor/tela_inicial_professor.dart';
import '../aluno/tela_inicial_aluno.dart';
import '../../services/api_service.dart';

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
    // Validação básica
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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
          'email': inputText == 'professor' ? 'carlos.mendes@email.com' : 'joao.silva@email.com',
          'tipo': inputText,
        };
        
        await _apiService.devLogin(inputText, userData);
        
        if (!mounted) return;
        
        // Navegar para a tela apropriada
        if (inputText == 'professor') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TelaInicialProfessor(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const TelaInicialAluno(),
            ),
          );
        }
        return;
      }
      
      // Se não for "aluno" ou "professor", mostrar erro
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite "aluno" ou "professor" para fazer login'),
          backgroundColor: Colors.orange,
        ),
      );
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.jpg',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Portal Educacional',
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.developer_mode, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'MODO DESENVOLVIMENTO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Digite "aluno" ou "professor"',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
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
                    decoration: InputDecoration(
                      labelText: 'Login Rápido',
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'Digite "aluno" ou "professor"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
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
                                  fontWeight: FontWeight.bold
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
      ), 
    ); 
  } 
}
