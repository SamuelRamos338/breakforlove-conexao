const express = require('express');
const router = express.Router();
const InformacoesCasalController = require('../controllers/InformacoesCasalController');

// Listar informações do casal pelo
router.get('/listar/:conexaoId', InformacoesCasalController.listarInformacoesCasal);

// Atualizar informações do casal
router.put('/atualizar/:conexaoId', InformacoesCasalController.atualizarInformacoesCasal);

module.exports = router;
