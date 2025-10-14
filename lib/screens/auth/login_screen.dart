import 'package:flutter/material.dart';
import '../teacher/teacher_home_screen.dart';
import '../student/student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

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
  void _performLogin() {
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

    final String tipo = _tabController.index == 0 ? 'Aluno' : 'Professor';
    
    if (tipo == 'Professor') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TeacherHomeScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StudentHomeScreen(),
        ),
      );
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
                      onPressed: _performLogin,
                      child: const Text(
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
