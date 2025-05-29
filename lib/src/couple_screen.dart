import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoupleScreen extends StatefulWidget {
  final String conexaoId;
  final String apiBaseUrl;

  const CoupleScreen({
    super.key,
    required this.conexaoId,
    required this.apiBaseUrl,
  });

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  Map<String, dynamic>? _infos;
  bool _isLoading = true;
  String? _error;
  String? _editingKey;
  final Map<String, TextEditingController> _controllers = {};

  final Map<String, IconData> _icons = {
    'musicaFavorita': Icons.music_note,
    'filmeFavorito': Icons.movie,
    'dataEspecial': Icons.calendar_today,
    'proximoAniversarioNamoro': Icons.cake,
  };

  final Map<String, String> _labels = {
    'musicaFavorita': 'Música favorita',
    'filmeFavorito': 'Filme favorito',
    'dataEspecial': 'Data especial',
    'proximoAniversarioNamoro': 'Próximo aniversário de namoro',
  };

  @override
  void initState() {
    super.initState();
    _fetchCoupleInfo();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCoupleInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final uri = Uri.parse('${widget.apiBaseUrl}/informacoesCasal/listar/${widget.conexaoId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _infos = data;
          for (var key in _labels.keys) {
            _controllers[key] = TextEditingController(text: data[key]?.toString() ?? '');
          }
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _infos = {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar informações (${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Erro de rede ao carregar informações.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCoupleInfo(String key, String value) async {
    final uri = Uri.parse('${widget.apiBaseUrl}/informacoesCasal/atualizar/${widget.conexaoId}');
    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...?_infos, key: value}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _infos = json.decode(response.body);
          _controllers[key]?.text = value;
          _editingKey = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informação atualizada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar informações (${response.statusCode}).')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de rede ao atualizar informações.')),
      );
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Casal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: _labels.keys.map((key) {
            final label = _labels[key]!;
            final icon = _icons[key] ?? Icons.info;
            final value = _infos?[key];

            final displayValue = key == 'proximoAniversarioNamoro' && value != null
                ? _formatDate(value)
                : value ?? 'Não informado';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: ListTile(
                  leading: Icon(icon, color: iconColor),
                  title: Text(label),
                  subtitle: _editingKey == key
                      ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[key],
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Salvar',
                        onPressed: () => _updateCoupleInfo(
                          key,
                          _controllers[key]?.text ?? '',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Cancelar',
                        onPressed: () => setState(() => _editingKey = null),
                      ),
                    ],
                  )
                      : GestureDetector(
                    onTap: () => setState(() => _editingKey = key),
                    child: Row(
                      children: [
                        Expanded(child: Text(displayValue)),
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.edit, size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
