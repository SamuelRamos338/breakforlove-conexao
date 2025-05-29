const InformacoesCasal = require('../models/InformacoesCasalModel');

const InformacoesCasalController = {
  //#region Listar informações do casal pelo ID da conexão
  async listarInformacoesCasal(req, res) {
    const { conexaoId } = req.params;

    try {
      const informacoes = await InformacoesCasal.findOne({ conexao: conexaoId });
      if (!informacoes) {
        return res.status(404).json({ msg: 'Informações do casal não encontradas' });
      }
      res.status(200).json(informacoes);
    } catch (error) {
      console.error('Erro ao listar informações do casal:', error);
      res.status(500).json({ msg: 'Erro interno no servidor' });
    }
  },
  //#endregion

  //#region Atualizar informações do casal (se não existir, cria)
  async atualizarInformacoesCasal(req, res) {
    const { conexaoId } = req.params;
    const { musicaFavorita, filmeFavorito, dataEspecial, proximoAniversarioNamoro } = req.body;

    try {
      const informacoesAtualizadas = await InformacoesCasal.findOneAndUpdate(
        { conexao: conexaoId },
        { musicaFavorita, filmeFavorito, dataEspecial, proximoAniversarioNamoro, conexao: conexaoId },
        { new: true, upsert: true, runValidators: true }
      );

      res.status(200).json(informacoesAtualizadas);
    } catch (error) {
      console.error('Erro ao atualizar informações do casal:', error);
      res.status(500).json({ msg: 'Erro interno no servidor' });
    }
  },
  //#endregion
};

module.exports = InformacoesCasalController;
