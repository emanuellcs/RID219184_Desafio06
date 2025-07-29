const Cliente = require('../models/cliente');

// Listar todos os clientes
exports.getAllClientes = async (req, res) => {
  try {
    const clientes = await Cliente.find();
    res.json(clientes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Obter um cliente por ID
exports.getClienteById = async (req, res) => {
  try {
    const cliente = await Cliente.findById(req.params.id);
    if (cliente == null) {
      return res.status(404).json({ message: 'Cliente não encontrado' });
    }
    res.json(cliente);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Criar um novo cliente
exports.createCliente = async (req, res) => {
  const cliente = new Cliente({
    nome: req.body.nome,
    email: req.body.email,
    telefone: req.body.telefone,
    enderecos: req.body.enderecos,
  });

  try {
    const newCliente = await cliente.save();
    res.status(201).json(newCliente);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Atualizar um cliente
exports.updateCliente = async (req, res) => {
  try {
    const cliente = await Cliente.findById(req.params.id);
    if (cliente == null) {
      return res.status(404).json({ message: 'Cliente não encontrado' });
    }

    if (req.body.nome != null) {
      cliente.nome = req.body.nome;
    }
    if (req.body.email != null) {
      cliente.email = req.body.email;
    }
    if (req.body.telefone != null) {
      cliente.telefone = req.body.telefone;
    }
    if (req.body.enderecos != null) {
      cliente.enderecos = req.body.enderecos;
    }

    const updatedCliente = await cliente.save();
    res.json(updatedCliente);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Deletar um cliente
exports.deleteCliente = async (req, res) => {
  try {
    const cliente = await Cliente.findById(req.params.id);
    if (cliente == null) {
      return res.status(404).json({ message: 'Cliente não encontrado' });
    }
    await Cliente.findByIdAndDelete(req.params.id);
    res.json({ message: 'Cliente deletado' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};