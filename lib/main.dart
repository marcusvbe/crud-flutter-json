import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Usuários',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(secondary: Colors.orangeAccent),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          labelStyle: TextStyle(color: Colors.indigo),
        ),
      ),
      home: const PaginaInicial(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialEstado();
}

class _PaginaInicialEstado extends State<PaginaInicial> {
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _chaveFormulario = GlobalKey<FormState>();
  final _chaveFormularioEdicao = GlobalKey<FormState>();

  List<Map<String, String>> _listaUsuariosCadastrados = [];
  final String _nomeArquivo = 'dados_usuarios.json';
  int? _usuarioEditandoIndex;

  @override
  void initState() {
    super.initState();
    _carregarUsuariosDoArquivo();
  }

  // Obtém o diretório de documentos com base na plataforma
  Future<String> _obterCaminhoDiretorioDocumentos() async {
    String caminhoDiretorio;
    if (Platform.isLinux) {
      final String? diretorioHome = Platform.environment['HOME'];
      if (diretorioHome != null && diretorioHome.isNotEmpty) {
        String caminhoDocumentosPtBr = p.join(diretorioHome, 'Documentos');
        Directory dirPtBr = Directory(caminhoDocumentosPtBr);
        if (await dirPtBr.exists() ||
            Platform.localeName.toLowerCase().startsWith('pt_br')) {
          caminhoDiretorio = caminhoDocumentosPtBr;
        } else {
          String caminhoDocumentsEn = p.join(diretorioHome, 'Documents');
          Directory dirEn = Directory(caminhoDocumentsEn);
          if (await dirEn.exists()) {
            caminhoDiretorio = caminhoDocumentsEn;
          } else {
            caminhoDiretorio = caminhoDocumentosPtBr;
          }
        }
      } else {
        final Directory diretorioDocsApp =
            await getApplicationDocumentsDirectory();
        caminhoDiretorio = diretorioDocsApp.path;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Diretório HOME não encontrado. Usando ${diretorioDocsApp.path}',
              ),
            ),
          );
        }
      }
    } else {
      final Directory diretorioDocsApp =
          await getApplicationDocumentsDirectory();
      caminhoDiretorio = diretorioDocsApp.path;
    }
    final Directory dir = Directory(caminhoDiretorio);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return caminhoDiretorio;
  }

  // Obtém o arquivo JSON
  Future<File> _obterArquivoLocal() async {
    final caminhoDiretorio = await _obterCaminhoDiretorioDocumentos();
    return File(p.join(caminhoDiretorio, _nomeArquivo));
  }

  // Salva a lista de usuários no arquivo JSON
  Future<void> _persistirListaUsuarios(List<Map<String, String>> lista) async {
    final arquivo = await _obterArquivoLocal();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String dadosJson = encoder.convert(lista);
    await arquivo.writeAsString(dadosJson);
  }

  // Carrega usuários do arquivo JSON
  Future<void> _carregarUsuariosDoArquivo() async {
    try {
      final arquivo = await _obterArquivoLocal();
      if (await arquivo.exists()) {
        final String conteudoExistente = await arquivo.readAsString();
        if (conteudoExistente.isNotEmpty) {
          final List<dynamic> dadosDecodificados = jsonDecode(
            conteudoExistente,
          );
          setState(() {
            _listaUsuariosCadastrados = dadosDecodificados
                .map((item) => Map<String, String>.from(item as Map))
                .toList();
          });
        } else {
          setState(() {
            _listaUsuariosCadastrados = [];
          });
        }
      } else {
        setState(() {
          _listaUsuariosCadastrados = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar dados: $e. Iniciando com lista vazia.',
            ),
          ),
        );
      }
      setState(() {
        _listaUsuariosCadastrados = [];
      });
    }
  }

  // CREATE - Adiciona um novo usuário
  Future<void> _adicionarUsuario() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }
    final String nome = _controladorNome.text;
    final String email = _controladorEmail.text;
    final Map<String, String> novoDado = {'nome': nome, 'email': email};

    final listaTemporaria = List<Map<String, String>>.from(
      _listaUsuariosCadastrados,
    );
    listaTemporaria.add(novoDado);

    try {
      await _persistirListaUsuarios(listaTemporaria);
      setState(() {
        _listaUsuariosCadastrados = listaTemporaria;
      });
      _controladorNome.clear();
      _controladorEmail.clear();
      FocusScope.of(context).unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário "${novoDado['nome']}" adicionado!')),
        );
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar usuário: $erro')),
        );
      }
    }
  }

  // UPDATE - Edita um usuário existente
  Future<void> _editarUsuario(int index) async {
    // Preencher formulário com dados existentes
    setState(() {
      _usuarioEditandoIndex = index;
    });
    final usuarioParaEditar = _listaUsuariosCadastrados[index];
    _controladorNome.text = usuarioParaEditar['nome'] ?? '';
    _controladorEmail.text = usuarioParaEditar['email'] ?? '';

    // Mostrar bottom sheet com formulário de edição
    final resultado = await showModalBottomSheet<Map<String, String>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Editar Usuário',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: _chaveFormularioEdicao,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controladorNome,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe o nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controladorEmail,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe o email.';
                        }
                        if (!valor.contains('@') || !valor.contains('.')) {
                          return 'Informe um email válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_chaveFormularioEdicao.currentState!
                                .validate()) {
                              Navigator.pop(context, {
                                'nome': _controladorNome.text,
                                'email': _controladorEmail.text,
                              });
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );

    // Limpar o estado de edição
    setState(() {
      _usuarioEditandoIndex = null;
    });

    // Processar o resultado da edição
    if (resultado != null) {
      final listaTemporaria = List<Map<String, String>>.from(
        _listaUsuariosCadastrados,
      );
      listaTemporaria[index] = resultado;

      try {
        await _persistirListaUsuarios(listaTemporaria);
        setState(() {
          _listaUsuariosCadastrados = listaTemporaria;
        });
        _controladorNome.clear();
        _controladorEmail.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário atualizado com sucesso!')),
          );
        }
      } catch (erro) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar usuário: $erro')),
          );
        }
      }
    }
  }

  // DELETE - Exclui um usuário
  Future<void> _excluirUsuario(int index) async {
    final usuarioParaExcluir = _listaUsuariosCadastrados[index];
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o usuário "${usuarioParaExcluir['nome']}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      final listaTemporaria = List<Map<String, String>>.from(
        _listaUsuariosCadastrados,
      );
      listaTemporaria.removeAt(index);
      try {
        await _persistirListaUsuarios(listaTemporaria);
        setState(() {
          _listaUsuariosCadastrados = listaTemporaria;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usuário "${usuarioParaExcluir['nome']}" excluído.',
              ),
            ),
          );
        }
      } catch (erro) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir usuário: $erro')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD de Usuários'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      backgroundColor: const Color.fromARGB(255, 37, 51, 132),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              elevation: 3.0,
              margin: const EdgeInsets.only(bottom: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Novo Usuário',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.indigo[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controladorNome,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Informe seu nome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controladorEmail,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Informe seu email.';
                          }
                          if (!valor.contains('@') || !valor.contains('.')) {
                            return 'Informe um email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _adicionarUsuario,
                        child: const Text('Adicionar Usuário'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usuários Cadastrados:',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _listaUsuariosCadastrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.people_outline,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum usuário cadastrado ainda.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _listaUsuariosCadastrados.length,
                      itemBuilder: (context, index) {
                        final usuario = _listaUsuariosCadastrados[index];
                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              foregroundColor: Colors.white,
                              child: Text(
                                usuario['nome']!.isNotEmpty
                                    ? usuario['nome']![0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              usuario['nome'] ?? 'Nome não disponível',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              usuario['email'] ?? 'Email não disponível',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue[700],
                                  ),
                                  tooltip: 'Editar ${usuario['nome']}',
                                  onPressed: () {
                                    _editarUsuario(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[700],
                                  ),
                                  tooltip: 'Excluir ${usuario['nome']}',
                                  onPressed: () {
                                    _excluirUsuario(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
