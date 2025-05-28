const UsuarioController = {
        async cadastrar(req, res) {
          const { usuario, senha, nome } = req.body;

          if (!usuario || !senha || !nome) {
            return res.status(400).json({ msg: 'Todos os campos são obrigatórios' });
          }

         try {
           const existe = await Usuario.findOne({ usuario });
           if (existe) {
             console.error('Usuário já existe:', usuario);
             return res.status(400).json({ msg: 'Usuário já existe' });
           }

           const senhaHash = await bcrypt.hash(senha, 10);
           const novoUsuario = new Usuario({ usuario, senha: senhaHash, nome });
           await novoUsuario.save();

           const designPadrao = new Design({
             usuario: novoUsuario._id,
             tema: 0,
             fotoPerfil: 0
           });

           await designPadrao.save();

           res.status(201).json({ msg: 'Usuário cadastrado com sucesso', usuario: { id: novoUsuario._id, nome: novoUsuario.nome, usuario: novoUsuario.usuario } });
         } catch (error) {
           console.error('Erro no cadastro:', error.message, error.stack);
           res.status(500).json({ msg: 'Erro interno no servidor' });
         }
        },

        async login(req, res) {
          const { usuario, senha } = req.body;

          if (!usuario || !senha) {
            return res.status(400).json({ msg: 'Usuário e senha são obrigatórios' });
          }

          try {
            const user = await Usuario.findOne({ usuario });
            if (!user) {
              return res.status(400).json({ msg: 'Usuário não encontrado' });
            }

            const senhaValida = await bcrypt.compare(senha, user.senha);
            if (!senhaValida) {
              return res.status(401).json({ msg: 'Senha incorreta' });
            }

            res.status(200).json({
              msg: 'Login realizado com sucesso',
              usuario: {
                id: user._id,
                nome: user.nome,
                usuario: user.usuario,
                conexao: user.conexao || null
              }
            });
          } catch (error) {
            console.error('Erro no login:', error);
            res.status(500).json({ msg: 'Erro interno no servidor' });
          }
        },

        async buscarIdPorUsuario(req, res) {
          const { usuario } = req.params;
          try {
            const user = await Usuario.findOne({ usuario });
            if (!user) return res.status(404).json({ msg: 'Usuário não encontrado.' });
            res.status(200).json({
              id: user._id,
              nome: user.nome,
              usuario: user.usuario
            });
          } catch (err) {
            console.error('Erro ao buscar usuário:', err);
            res.status(500).json({ msg: 'Erro ao buscar ID do usuário.' });
          }
        }
      };

      module.exports = UsuarioController;