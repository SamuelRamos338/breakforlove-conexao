import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/usuario_model.dart';
import 'login_screen.dart';
import '../main.dart';

class ConexaoScreen extends StatefulWidget {
  final UsuarioModel usuarioLogado;
  final String apiBaseUrl;

  const ConexaoScreen({
    Key? key,
    required this.usuarioLogado,
    required this.apiBaseUrl,
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
            builder: (_) => MainPage(usuarioLogado: widget.usuarioLogado),
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
        print('Pendentes carregados com sucesso: $_pendentes');
      } else if (resp.statusCode == 404) {
        setState(() {
          _pendentes = [];
          _isCarregandoPendentes = false;
        });
        print('Nenhuma conexão pendente encontrada.');
      } else {
        setState(() {
          _erroPendentes = 'Erro ao carregar pendentes (${resp.statusCode}).';
          _isCarregandoPendentes = false;
        });
        print('Erro ao carregar pendentes: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _erroPendentes = 'Erro de rede ao carregar pendentes.';
        _isCarregandoPendentes = false;
      });
      print('Erro de rede ao carregar pendentes: $e');
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
        print('Usuário encontrado: $encontrado');

        // Chama automaticamente a função _enviarSolicitacao
        await _enviarSolicitacao(encontrado);
      } else if (resp.statusCode == 404) {
        setState(() {
          _erroBusca = 'Usuário não encontrado';
          _isCarregandoBusca = false;
        });
        print('Usuário não encontrado.');
      } else {
        setState(() {
          _erroBusca = 'Erro ao buscar usuário (${resp.statusCode})';
          _isCarregandoBusca = false;
        });
        print('Erro ao buscar usuário: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _erroBusca = 'Erro de rede ao buscar usuário';
        _isCarregandoBusca = false;
      });
      print('Erro de rede ao buscar usuário: $e');
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
        print('Solicitação enviada com sucesso.');
        await _carregarPendentes();
      } else {
        final erro = json.decode(resp.body)['erro'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao enviar: $erro')),
        );
        print('Falha ao enviar solicitação: $erro');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede ao enviar solicitação')),
      );
      print('Erro de rede ao enviar solicitação: $e');
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
        print('Conexão aceita com sucesso: $conexaoMap');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(usuarioLogado: widget.usuarioLogado),
          ),
        );
      } else {
        final erro = (json.decode(resp.body)['erro'] ?? 'Erro desconhecido');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao aceitar: $erro')),
        );
        print('Falha ao aceitar conexão: $erro');
        await _carregarPendentes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede ao aceitar')),
      );
      print('Erro de rede ao aceitar conexão: $e');
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
        print('Conexão rejeitada com sucesso.');
      } else {
        final erro = (json.decode(resp.body)['erro'] ?? 'Erro desconhecido');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao rejeitar: $erro')),
        );
        print('Falha ao rejeitar conexão: $erro');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede ao rejeitar')),
      );
      print('Erro de rede ao rejeitar conexão: $e');
    } finally {
      await _carregarPendentes();
    }
  }

 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final primary = theme.colorScheme.primary;
  final secondary = theme.colorScheme.secondary;

  return Scaffold(
    body: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
                Image.asset(
                  'assets/LogoApp.png',
                  width: 480,
                  height: 200,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Faça a conexão com outro usuário',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _usuarioBuscadoController,
                          decoration: InputDecoration(
                            labelText: 'Buscar usuário',
                            labelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _isCarregandoBusca ? null : _buscarUsuarioPorNome,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_usuarioEncontrado != null)
                          ListTile(
                            title: Text(_usuarioEncontrado!.nome),
                            subtitle: Text('Usuário: ${_usuarioEncontrado!.usuario}'),
                            trailing: ElevatedButton(
                              onPressed: () => _enviarSolicitacao(_usuarioEncontrado!),
                              child: const Text('Conectar'),
                            ),
                          ),
                        const SizedBox(height: 18),
                        const Text(
                          'Conexões pendentes:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (_isCarregandoPendentes)
                          const Center(child: CircularProgressIndicator()),
                        if (!_isCarregandoPendentes && _pendentes.isEmpty)
                          const Text(
                            'Nenhuma solicitação pendente.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        if (!_isCarregandoPendentes && _pendentes.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pendentes.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, idx) {
                              final item = _pendentes[idx];
                              return ListTile(
                                title: Text(item['usuario1']['nome']),
                                subtitle: Text('Usuário: ${item['usuario1']['usuario']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _aceitarConexao(item['_id']),
                                      child: const Text('Aceitar'),
                                    ),
                                    const SizedBox(width: 18),
                                    TextButton(
                                      onPressed: () => _rejeitarConexao(item['_id']),
                                      child: const Text(
                                        'Rejeitar',
                                        style: TextStyle(color: Colors.red),
                                      ),
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
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Não posso me conectar agora',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
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

  @override
  void dispose() {
    _usuarioBuscadoController.dispose();
    super.dispose();
  }
}