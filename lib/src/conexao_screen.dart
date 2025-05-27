import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConexaoScreen extends StatefulWidget {
  final String usuarioId;

  const ConexaoScreen({required this.usuarioId, super.key});

  @override
  State<ConexaoScreen> createState() => _ConexaoScreenState();
}

class _ConexaoScreenState extends State<ConexaoScreen> {
  final TextEditingController _segundoUsuarioController = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _criarConexao() async {
    final segundoUsuario = _segundoUsuarioController.text.trim();
    if (segundoUsuario.isEmpty) {
      _showMessage('Por favor, insira o ID do segundo usuário.');
      return;
    }

    if (segundoUsuario == widget.usuarioId) {
      _showMessage('Você não pode se conectar a si mesmo.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.104:3000/api/conexao/criar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario1': widget.usuarioId,
          'usuario2': segundoUsuario,
        }),
      );

      if (response.statusCode == 201) {
        _showMessage('Solicitação de conexão enviada com sucesso.');
      } else {
        final data = jsonDecode(response.body);
        _showMessage(data['erro'] ?? 'Erro ao solicitar conexão.');
      }
    } catch (e) {
      _showMessage('Erro ao conectar ao servidor.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarConexao() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.104:3000/api/conexao/usuario/${widget.usuarioId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage('Conectado com: ${data['usuario1']['nome']} e ${data['usuario2']['nome']}');
      } else {
        _showMessage('Nenhuma conexão ativa encontrada.');
      }
    } catch (e) {
      _showMessage('Erro ao buscar conexão.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarPendentes() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.104:3000/api/conexao/pendentes/${widget.usuarioId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage('Conexões pendentes: ${data.length}');
      } else {
        _showMessage('Nenhuma solicitação pendente encontrada.');
      }
    } catch (e) {
      _showMessage('Erro ao buscar solicitações pendentes.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logoApp.png',
                height: 150,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Gerenciar Conexões',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _segundoUsuarioController,
                      decoration: InputDecoration(
                        labelText: 'ID do Segundo Usuário',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _criarConexao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Criar Conexão', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _buscarConexao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Buscar Conexão', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _buscarPendentes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Ver Pendentes', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
