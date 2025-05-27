import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
}

class CheckListScreen extends StatefulWidget {
  final String conexaoId;

  const CheckListScreen({required this.conexaoId});

  @override
  _CheckListScreenState createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListScreen> {
  Future<List<CheckListItem>> fetchCheckList() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.104:3000/api/checkList/listar/${widget.conexaoId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CheckListItem.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar checklist');
    }
  }

  Future<void> addCheckListItem(String descricao) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.104:3000/api/checkList/criar/${widget.conexaoId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao}),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      throw Exception('Erro ao adicionar item');
    }
  }

  Future<void> updateCheckListItem(CheckListItem item) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.104:3000/api/checkList/atualizar/${widget.conexaoId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([
        {'id': item.id, 'descricao': item.descricao, 'marcado': item.marcado}
      ]),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      throw Exception('Erro ao atualizar item');
    }
  }

  Future<void> deleteCheckListItem(String id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.0.104:3000/api/checkList/deletar/${widget.conexaoId}?id=$id'),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      throw Exception('Erro ao deletar item');
    }
  }

  void showAddItemDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Descrição do item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await addCheckListItem(controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color ?? Colors.pink;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Avatar e ícone de favoritos
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
                // Cartão com data e lembretes
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
                            Text(
                              DateFormat('d', 'pt_BR').format(DateTime.now()),
                              style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM', 'pt_BR').format(DateTime.now()).toUpperCase(),
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
                // Lista de lembretes
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
                          IconButton(icon: Icon(Icons.add, color: iconColor), onPressed: showAddItemDialog),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<CheckListItem>>(
                        future: fetchCheckList(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erro ao carregar checklist: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhum item encontrado'));
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final item = snapshot.data![index];
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: item.marcado,
                                      onChanged: (val) async {
                                        await updateCheckListItem(
                                          CheckListItem(
                                            id: item.id,
                                            descricao: item.descricao,
                                            marcado: val ?? false,
                                          ),
                                        );
                                      },
                                      activeColor: iconColor,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => {}, // Lógica para editar
                                        child: Text(
                                          item.descricao,
                                          style: TextStyle(fontSize: 17, color: iconColor),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 18, color: Colors.grey),
                                      onPressed: () async {
                                        await deleteCheckListItem(item.id);
                                      },
                                      tooltip: 'Excluir',
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
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