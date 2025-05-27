const express = require('express');
const router = express.Router();
const UsuarioController = require('../controllers/UsuarioController');

// Cadastro de usuário
router.post('/cadastrar', UsuarioController.cadastrar);

// Login de usuário
router.post('/login', UsuarioController.login);

// Atualizar usuário
router.put('/atualizar/:id', (req, res) => {
  if (typeof UsuarioController.atualizar === 'function') {
    UsuarioController.atualizar(req, res);
  } else {
    res.status(500).json({ msg: 'Handler de atualização não é uma função válida' });
  }
});

module.exports = router;