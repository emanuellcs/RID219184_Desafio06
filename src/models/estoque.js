const mongoose = require('mongoose');

const estoqueSchema = new mongoose.Schema({
  produto_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Produto', required: true },
  quantidade: { type: Number, required: true },
  data_atualizacao: { type: Date, default: Date.now }
});

const Estoque = mongoose.model('Estoque', estoqueSchema);

module.exports = Estoque;