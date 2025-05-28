const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  usuario: { type: String, required: true, unique: true }, // usuário de login
  senha: { type: String, required: true }, // senha de login
  nome: { type: String, required: true }, // nome da pessoa
  conexao: { type: mongoose.Schema.Types.ObjectId, ref: 'Conexao', default: null } // conexão com outro usuário
}, { timestamps: true });

module.exports = mongoose.model('Usuario', usuarioSchema);