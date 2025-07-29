const Estoque = require('../models/estoque');

// Obter estoque por ID do produto
exports.getEstoqueByProductId = async (req, res) => {
  try {
    const estoque = await Estoque.findOne({ produto_id: req.params.produto_id });
    if (estoque == null) {
      return res.status(404).json({ message: 'Estoque não encontrado para este produto' });
    }
    res.json(estoque);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Atualizar estoque (adicionar/remover quantidade)
exports.updateEstoque = async (req, res) => {
  try {
    const estoque = await Estoque.findOne({ produto_id: req.params.produto_id });
    if (estoque == null) {
      return res.status(404).json({ message: 'Estoque não encontrado para este produto' });
    }

    if (req.body.quantidade != null) {
      estoque.quantidade = req.body.quantidade;
    }

    const updatedEstoque = await estoque.save();
    res.json(updatedEstoque);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Deletar entrada de estoque (raramente usado, mas para CRUD completo)
exports.deleteEstoque = async (req, res) => {
  try {
    const estoque = await Estoque.findOne({ produto_id: req.params.produto_id });
    if (estoque == null) {
      return res.status(404).json({ message: 'Estoque não encontrado para este produto' });
    }
    await Estoque.deleteOne({ produto_id: req.params.produto_id });
    res.json({ message: 'Entrada de estoque deletada' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};