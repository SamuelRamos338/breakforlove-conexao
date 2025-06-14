import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _visible = false;
  bool _isLoading = false;
  late final AnimationController _logoAnimController;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() => _visible = true);
      _logoAnimController.forward();
    });
  }

  @override
  void dispose() {
    _logoAnimController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.104:3000/api/usuario/cadastrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': _userController.text,
          'nome': _nameController.text,
          'senha': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        _showError(data['msg'] ?? 'Erro ao cadastrar usuário.');
      }
    } catch (e) {
      _showError('Erro ao conectar ao servidor. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary,
              secondary,
              primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  AnimatedBuilder(
                    animation: _logoAnimController,
                    builder: (context, child) => AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _logoAnimController.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    ),
                    child: Image.asset(
                      'assets/LogoApp.png',
                      width: 480,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Crie sua conta',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _visible ? 1 : 0,
                    curve: Curves.easeOutCubic,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 400),
                      offset: _visible ? Offset(0, 0) : Offset(0, 0.15),
                      curve: Curves.easeOutCubic,
                      child: _RegisterScreenForm(
                        userController: _userController,
                        nameController: _nameController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        onRegisterTap: _register,
                        isLoading: _isLoading,
                        onLoginTap: () {
                          Navigator.pop(context);
                        },
                      ),
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

class _RegisterScreenForm extends StatefulWidget {
  final TextEditingController userController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegisterTap;
  final VoidCallback onLoginTap;
  final bool isLoading;

  const _RegisterScreenForm({
    required this.userController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegisterTap,
    required this.onLoginTap,
    required this.isLoading,
  });

  @override
  State<_RegisterScreenForm> createState() => _RegisterScreenFormState();
}

class _RegisterScreenFormState extends State<_RegisterScreenForm> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.userController,
              decoration: InputDecoration(
                labelText: 'Usuário',
                prefixIcon: Icon(Icons.person, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.confirmPasswordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                prefixIcon: Icon(Icons.lock_outline, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: widget.isLoading ? null : widget.onRegisterTap,
                    child: widget.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Cadastrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: widget.onLoginTap,
              child: const Text(
                'Já tem uma conta? Voltar ao login',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}