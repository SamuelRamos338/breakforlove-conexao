// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Classe que representa um item do checklist
class CheckListItem {
  final String id;
  final String descricao;
  final bool marcado;

  CheckListItem({required this.id, required this.descricao, required this.marcado});

  factory CheckListItem.fromJson(Map<String, dynamic> json) {
    return CheckListItem(
      id: json['_id'],
      descricao: json['descricao'],
      marcado: json['marcado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descricao': descricao, 'marcado': marcado};
  }
}

const String baseUrl = 'http://192.168.0.104:3000/api/checkList';

// Função para listar os itens do checklist
Future<List<CheckListItem>> listarCheckList(String conexaoId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/listar/$conexaoId'));
    if (response.statusCode == 200) {
      final List dados = jsonDecode(response.body);
      return dados.map((json) => CheckListItem.fromJson(json)).toList();
    } else {
      print('Erro ao listar checklist: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao buscar checklist');
    }
  } catch (e) {
    print('Exceção ao listar checklist: $e');
    rethrow;
  }
}

// Função para criar um novo item no checklist
Future<void> criarItem(String descricao, String conexaoId) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/criar/$conexaoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao}),
    );
    if (response.statusCode != 201) {
      print('Erro ao criar item: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao criar item');
    }
  } catch (e) {
    print('Exceção ao criar item: $e');
    rethrow;
  }
}

// Função para atualizar um item do checklist
Future<void> atualizarItem(CheckListItem item, String conexaoId) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/atualizar/$conexaoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([item.toJson()]),
    );
    if (response.statusCode != 200) {
      print('Erro ao atualizar item: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao atualizar item');
    }
  } catch (e) {
    print('Exceção ao atualizar item: $e');
    rethrow;
  }
}

// Função para deletar um item do checklist
Future<void> deletarItem(String conexaoId, String idItem) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/deletar/$conexaoId?id=$idItem'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      print('Erro ao deletar item: ${response.statusCode} - ${response.body}');
      throw Exception('Erro ao deletar');
    }
  } catch (e) {
    print('Exceção ao deletar item: $e');
    rethrow;
  }
}

// Tela principal da Home
class HomeScreen extends StatefulWidget {
  final String conexaoId;

  const HomeScreen({required this.conexaoId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CheckListItem> checklist = [];

  @override
  void initState() {
    super.initState();
    carregarChecklist();
  }

  Future<void> carregarChecklist() async {
    try {
      final dados = await listarCheckList(widget.conexaoId);
      setState(() => checklist = dados);
    } catch (e) {
      print('Erro ao carregar checklist: $e');
    }
  }

  Future<void> adicionarItem() async {
    String? descricao = await _showEditDialog(context, 'Novo item', '');
    if (descricao != null && descricao.trim().isNotEmpty) {
      try {
        await criarItem(descricao.trim(), widget.conexaoId);
        await carregarChecklist();
      } catch (e) {
        print('Erro ao adicionar item: $e');
      }
    }
  }

  Future<void> editarItem(int index) async {
    String? novaDesc = await _showEditDialog(context, 'Renomear item', checklist[index].descricao);
    if (novaDesc != null && novaDesc.trim().isNotEmpty) {
      final atualizado = CheckListItem(
        id: checklist[index].id,
        descricao: novaDesc.trim(),
        marcado: checklist[index].marcado,
      );
      try {
        await atualizarItem(atualizado, widget.conexaoId);
        await carregarChecklist();
      } catch (e) {
        print('Erro ao editar item: $e');
      }
    }
  }

  Future<void> marcarItem(int index, bool marcado) async {
    final atualizado = CheckListItem(
      id: checklist[index].id,
      descricao: checklist[index].descricao,
      marcado: marcado,
    );
    try {
      await atualizarItem(atualizado, widget.conexaoId);
      await carregarChecklist();
    } catch (e) {
      print('Erro ao marcar item: $e');
    }
  }

  Future<void> removerItem(int index) async {
    try {
      await deletarItem(widget.conexaoId, checklist[index].id);
      await carregarChecklist();
    } catch (e) {
      print('Erro ao remover item: $e');
    }
  }

  Future<String?> _showEditDialog(BuildContext context, String title, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Digite seu lembrete'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String dia = DateFormat('d', 'pt_BR').format(now);
    final String mes = DateFormat('MMMM', 'pt_BR').format(now);
    final iconColor = Theme.of(context).iconTheme.color ?? Colors.pink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/profile1.jpg')),
                    const SizedBox(width: 24),
                    Icon(Icons.favorite, color: iconColor, size: 32),
                    const SizedBox(width: 24),
                    const CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/profile2.jpg')),
                  ],
                ),
                const SizedBox(height: 60),
                Divider(color: Theme.of(context).dividerColor, thickness: 4),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(dia, style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              mes[0].toUpperCase() + mes.substring(1),
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            'Aniversario sogra,\nAniversario de namoro',
                            style: TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Lembretes', style: TextStyle(color: iconColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(icon: Icon(Icons.add, color: iconColor), onPressed: adicionarItem),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(checklist.length, (i) => Row(
                        children: [
                          Checkbox(
                            value: checklist[i].marcado,
                            onChanged: (val) => marcarItem(i, val ?? false),
                            activeColor: iconColor,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => editarItem(i),
                              child: Text(
                                checklist[i].descricao,
                                style: TextStyle(fontSize: 17, color: iconColor),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 18, color: iconColor),
                            onPressed: () => editarItem(i),
                            tooltip: 'Renomear',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 18, color: Colors.grey),
                            onPressed: () => removerItem(i),
                            tooltip: 'Excluir',
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}