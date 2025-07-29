const express = require('express');
const router = express.Router();
const vendaController = require('../controllers/vendaController');

// Rotas de Vendas
router.get('/', vendaController.getAllVendas);
router.get('/:id', vendaController.getVendaById);
router.post('/', vendaController.createVenda);
router.put('/:id', vendaController.updateVendaStatus);

module.exports = router;