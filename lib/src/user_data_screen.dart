import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDataScreen extends StatefulWidget {
  final String usuarioId;

  const UserDataScreen({super.key, required this.usuarioId});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Atualizar dados do usuário
      final usuarioResponse = await http.put(
        Uri.parse('http://seu-servidor.com/usuario/atualizar/${widget.usuarioId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': _nomeController.text,
          'usuario': _emailController.text,
          'senha': _senhaController.text.isNotEmpty ? _senhaController.text : null,
        }),
      );

      if (usuarioResponse.statusCode == 200) {
        // Atualizar foto de perfil (exemplo com ID de foto fixa)
        final fotoResponse = await http.put(
          Uri.parse('http://seu-servidor.com/design/foto-perfil/${widget.usuarioId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'fotoPerfil': 1}), // Substitua pelo ID da foto desejada
        );

        if (fotoResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alterações salvas com sucesso!')),
          );
        } else {
          throw Exception('Erro ao atualizar foto de perfil');
        }
      } else {
        throw Exception('Erro ao atualizar usuário');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Dados')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _salvarAlteracoes,
              icon: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
              label: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}