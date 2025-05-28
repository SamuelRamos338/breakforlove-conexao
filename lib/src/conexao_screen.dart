import 'dart:convert';
    import 'package:flutter/material.dart';
    import 'package:http/http.dart' as http;
    import '../main.dart';

    class UsuarioModel {
      final String id;
      final String usuario;
      final String nome;
      String? conexao;

      UsuarioModel({
        required this.id,
        required this.usuario,
        required this.nome,
        this.conexao,
      });

      factory UsuarioModel.fromJson(Map<String, dynamic> json) {
        return UsuarioModel(
          id: json['_id'] ?? json['id'],
          usuario: json['usuario'],
          nome: json['nome'],
          conexao: json['conexao'],
        );
      }

      Map<String, dynamic> toJson() {
        return {
          '_id': id,
          'usuario': usuario,
          'nome': nome,
          'conexao': conexao,
        };
      }
    }

    class ConexaoScreen extends StatefulWidget {
      final UsuarioModel usuarioLogado;
      final String apiBaseUrl;

      const ConexaoScreen({
        Key? key,
        required this.usuarioLogado,
        required this.apiBaseUrl, required usuarioId,
      }) : super(key: key);

      @override
      _ConexaoScreenState createState() => _ConexaoScreenState();
    }

    class _ConexaoScreenState extends State<ConexaoScreen> {
      final TextEditingController _usuarioBuscadoController = TextEditingController();
      bool _isCarregandoBusca = false;
      String? _erroBusca;
      UsuarioModel? _usuarioEncontrado;

      bool _isCarregandoPendentes = false;
      String? _erroPendentes;
      List<Map<String, dynamic>> _pendentes = [];

      @override
      void initState() {
        super.initState();
        if (widget.usuarioLogado.conexao != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainPage(conexaoId: widget.usuarioLogado.conexao!),
              ),
            );
          });
        } else {
          _carregarPendentes();
        }
      }

      Future<void> _carregarPendentes() async {
        setState(() {
          _isCarregandoPendentes = true;
          _erroPendentes = null;
        });

        final uri = Uri.parse('${widget.apiBaseUrl}/conexao/pendentes/${widget.usuarioLogado.id}');
        try {
          final resp = await http.get(uri);
          if (resp.statusCode == 200) {
            final List dados = json.decode(resp.body);
            setState(() {
              _pendentes = dados.cast<Map<String, dynamic>>();
              _isCarregandoPendentes = false;
            });
          } else if (resp.statusCode == 404) {
            setState(() {
              _pendentes = [];
              _isCarregandoPendentes = false;
            });
          } else {
            setState(() {
              _erroPendentes = 'Erro ao carregar pendentes (${resp.statusCode}).';
              _isCarregandoPendentes = false;
            });
          }
        } catch (e) {
          setState(() {
            _erroPendentes = 'Erro de rede ao carregar pendentes.';
            _isCarregandoPendentes = false;
          });
        }
      }

      Future<void> _buscarUsuarioPorNome() async {
        final nomeBuscado = _usuarioBuscadoController.text.trim();
        if (nomeBuscado.isEmpty) {
          setState(() => _erroBusca = 'Informe um nome de usuário');
          return;
        }

        setState(() {
          _isCarregandoBusca = true;
          _erroBusca = null;
          _usuarioEncontrado = null;
        });

        final uri = Uri.parse('${widget.apiBaseUrl}/usuario/buscar-id/$nomeBuscado');
        try {
          final resp = await http.get(uri);
          if (resp.statusCode == 200) {
            final mapa = json.decode(resp.body) as Map<String, dynamic>;
            final encontrado = UsuarioModel.fromJson(mapa);
            setState(() {
              _usuarioEncontrado = encontrado;
              _isCarregandoBusca = false;
            });
          } else if (resp.statusCode == 404) {
            setState(() {
              _erroBusca = 'Usuário não encontrado';
              _isCarregandoBusca = false;
            });
          } else {
            setState(() {
              _erroBusca = 'Erro ao buscar usuário (${resp.statusCode})';
              _isCarregandoBusca = false;
            });
          }
        } catch (e) {
          setState(() {
            _erroBusca = 'Erro de rede ao buscar usuário';
            _isCarregandoBusca = false;
          });
        }
      }

      Future<void> _enviarSolicitacao(UsuarioModel alvo) async {
        final uri = Uri.parse('${widget.apiBaseUrl}/conexao/criar');
        final body = json.encode({
          'usuario1': widget.usuarioLogado.id,
          'usuario2': alvo.id,
        });

        try {
          final resp = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          );
          if (resp.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Solicitação enviada com sucesso!')),
            );
            setState(() {
              _usuarioEncontrado = null;
              _usuarioBuscadoController.clear();
            });
            await _carregarPendentes();
          } else {
            final erro = json.decode(resp.body)['erro'] ?? 'Erro desconhecido';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao enviar: $erro')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro de rede ao enviar solicitação')),
          );
        }
      }

      Future<void> _aceitarConexao(String conexaoId) async {
        final uri = Uri.parse('${widget.apiBaseUrl}/conexao/aceitar/$conexaoId');
        try {
          final resp = await http.put(uri);
          if (resp.statusCode == 200) {
            final conexaoMap = json.decode(resp.body)['conexao'] as Map<String, dynamic>;
            setState(() {
              widget.usuarioLogado.conexao = conexaoMap['_id'];
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainPage(conexaoId: widget.usuarioLogado.conexao!),
              ),
            );
          } else {
            final erro = (json.decode(resp.body)['erro'] ?? 'Erro desconhecido');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao aceitar: $erro')),
            );
            await _carregarPendentes();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro de rede ao aceitar')),
          );
          await _carregarPendentes();
        }
      }

      Future<void> _rejeitarConexao(String conexaoId) async {
        final uri = Uri.parse('${widget.apiBaseUrl}/conexao/rejeitar/$conexaoId');
        try {
          final resp = await http.put(uri);
          if (resp.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Conexão rejeitada com sucesso')),
            );
          } else {
            final erro = (json.decode(resp.body)['erro'] ?? 'Erro desconhecido');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao rejeitar: $erro')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro de rede ao rejeitar')),
          );
        } finally {
          await _carregarPendentes();
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Conexões'),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nova solicitação de conexão',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _usuarioBuscadoController,
                          decoration: InputDecoration(
                            labelText: 'Nome de usuário',
                            border: OutlineInputBorder(),
                            errorText: _erroBusca,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isCarregandoBusca ? null : _buscarUsuarioPorNome,
                              child: _isCarregandoBusca
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text('Buscar'),
                            ),
                            SizedBox(width: 12),
                            if (_usuarioEncontrado != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Usuário encontrado:',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text('ID: ${_usuarioEncontrado!.id}'),
                                    Text('Usuário: ${_usuarioEncontrado!.usuario}'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (_usuarioEncontrado != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => _enviarSolicitacao(_usuarioEncontrado!),
                              child: Text('Enviar solicitação'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitações pendentes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        if (_isCarregandoPendentes)
                          Center(child: CircularProgressIndicator()),
                        if (!_isCarregandoPendentes && _erroPendentes != null)
                          Text(
                            _erroPendentes!,
                            style: TextStyle(color: Colors.red),
                          ),
                        if (!_isCarregandoPendentes && _pendentes.isEmpty)
                          Text('Nenhuma solicitação pendente.'),
                        if (!_isCarregandoPendentes && _pendentes.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _pendentes.length,
                            separatorBuilder: (_, __) => Divider(),
                            itemBuilder: (context, idx) {
                              final item = _pendentes[idx];
                              final usuario1 = item['usuario1'] as Map<String, dynamic>;
                              final conexaoId = item['_id'] as String;

                              return ListTile(
                                title: Text('${usuario1['nome']}'),
                                subtitle: Text('Usuário: ${usuario1['usuario']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _aceitarConexao(conexaoId),
                                      child: Text('Aceitar'),
                                    ),
                                    SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _rejeitarConexao(conexaoId),
                                      child: Text('Rejeitar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      @override
      void dispose() {
        _usuarioBuscadoController.dispose();
        super.dispose();
      }
    }