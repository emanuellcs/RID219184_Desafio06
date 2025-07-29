const mongoose = require('mongoose');

const vendaSchema = new mongoose.Schema({
  cliente_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Cliente', required: true },
  itens: [{
    produto_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Produto', required: true },
    quantidade: { type: Number, required: true },
    preco_unitario: { type: Number, required: true }
  }],
  total_venda: { type: Number, required: true },
  status: { type: String, required: true, default: 'processando' },
  data_venda: { type: Date, default: Date.now }
});

const Venda = mongoose.model('Venda', vendaSchema);

module.exports = Venda;