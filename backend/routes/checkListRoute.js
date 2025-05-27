const express = require('express');
const router = express.Router();
const CheckListController = require('../controllers/CheckListController');

// Criar item no checklist
router.post('/criar/:conexaoId', CheckListController.criarCheckList);

// Listar itens do checklist
router.get('/listar/:conexaoId', CheckListController.listarCheckList);

// Atualizar item do checklist
router.put('/atualizar/:conexaoId', CheckListController.atualizarCheckList);

// Deletar item do checklist
router.delete('/deletar/:conexaoId', CheckListController.deletarCheckList);

module.exports = router;