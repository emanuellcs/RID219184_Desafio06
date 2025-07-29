const express = require('express');
const router = express.Router();
const estoqueController = require('../controllers/estoqueController');

// Rotas de Estoque
router.get('/:produto_id', estoqueController.getEstoqueByProductId);
router.put('/:produto_id', estoqueController.updateEstoque);
router.delete('/:produto_id', estoqueController.deleteEstoque);

module.exports = router;