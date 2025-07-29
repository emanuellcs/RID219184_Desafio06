const mongoose = require('mongoose');

const enderecoSchema = new mongoose.Schema({
  rua: { type: String, required: true },
  numero: { type: String, required: true },
  cidade: { type: String, required: true },
  estado: { type: String, required: true },
  cep: { type: String, required: true }
});

const clienteSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  telefone: { type: String, required: true },
  enderecos: [enderecoSchema],
  data_criacao: { type: Date, default: Date.now }
});

const Cliente = mongoose.model('Cliente', clienteSchema);

module.exports = Cliente;