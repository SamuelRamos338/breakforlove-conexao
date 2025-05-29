const mongoose = require('mongoose');

const informacoesCasalSchema = new mongoose.Schema({
    conexao: { type: mongoose.Schema.Types.ObjectId, ref: 'Conexao', required: true },
    musicaFavorita: { type: String, required: false},
    filmeFavorito: { type: String, required: false},
    dataEspecial: { type: String, required: false},
    proximoAniversarioNamoro: { type: Date, required: false},
}, { timestamps: true });

module.exports = mongoose.model('InformacoesCasal', informacoesCasalSchema);
