import 'package:flutter/material.dart';
import '../professor/tela_inicial_professor.dart';
import '../aluno/tela_inicial_aluno.dart';
import '../../services/api_service.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializa o TabController com 2 abas
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Garante que o controller seja descartado para evitar vazamentos de memória
    _tabController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  // Função chamada ao pressionar o botão de login
  void _performLogin() async {
    // Validação básica
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Chamar API de login
      final response = await _apiService.login(
        emailController.text.trim(),
        senhaController.text,
      );

      if (!mounted) return;

      final user = response['user'];
      final tipo = user['tipo'];
      
      // Navegar para a tela apropriada
      if (tipo == 'professor') {
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
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
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
                  const SizedBox(height: 32),
                  // TabBar para seleção Aluno/Professor
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.orange,
                    indicatorWeight: 4,
                    tabs: const [
                      Tab(
                        text: 'ALUNO', 
                        icon: Icon(Icons.school_outlined)
                      ),
                      Tab(
                        text: 'PROFESSOR', 
                        icon: Icon(Icons.person_outline)
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Campo de E-mail
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: 'Digite seu e-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo de Senha
                  TextField(
                    controller: senhaController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _performLogin(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Digite sua senha',
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
                  const SizedBox(height: 12),
                  // Botão Esqueceu a Senha
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de recuperação de senha não implementada.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ], 
              ), 
            ), 
          ), 
        ), 
      ), 
    ); 
  } 
}
