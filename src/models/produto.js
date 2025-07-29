const mongoose = require('mongoose');

const produtoSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  descricao: { type: String, required: true },
  preco: { type: Number, required: true },
  categoria: { type: String, required: true },
  data_criacao: { type: Date, default: Date.now },
  data_atualizacao: { type: Date, default: Date.now }
});

const Produto = mongoose.model('Produto', produtoSchema);

module.exports = Produto;