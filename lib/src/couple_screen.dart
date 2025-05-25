import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({super.key});

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  final List<Map<String, dynamic>> _items = [];
  final String _baseUrl = 'http://192.168.0.104:3000/api/couple';

  Future<void> _fetchItems(String conexaoId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$conexaoId'));
      if (response.statusCode == 200) {
        setState(() {
          _items.clear();
          _items.addAll(List<Map<String, dynamic>>.from(jsonDecode(response.body)));
        });
      }
    } catch (e) {
      _showError('Erro ao buscar itens.');
    }
  }

  Future<void> _addItem(String descricao, String conexaoId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'descricao': descricao, 'conexaoId': conexaoId}),
      );
      if (response.statusCode == 201) {
        _fetchItems(conexaoId);
      }
    } catch (e) {
      _showError('Erro ao adicionar item.');
    }
  }

  Future<void> _updateItem(String id, String descricao) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'descricao': descricao}),
      );
      if (response.statusCode == 200) {
        _fetchItems(_items.first['conexaoId']);
      }
    } catch (e) {
      _showError('Erro ao atualizar item.');
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _items.removeWhere((item) => item['id'] == id);
        });
      }
    } catch (e) {
      _showError('Erro ao deletar item.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Couple Screen')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item['descricao']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateItem(item['id'], 'Nova descrição'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem('Novo item', 'conexaoId'),
        child: const Icon(Icons.add),
      ),
    );
  }
}