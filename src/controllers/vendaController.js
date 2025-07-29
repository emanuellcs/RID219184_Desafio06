const Venda = require('../models/venda');
const Estoque = require('../models/estoque');
const Produto = require('../models/produto');

// Listar todas as vendas
exports.getAllVendas = async (req, res) => {
  try {
    const vendas = await Venda.find().populate('cliente_id').populate('itens.produto_id');
    res.json(vendas);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Obter uma venda por ID
exports.getVendaById = async (req, res) => {
  try {
    const venda = await Venda.findById(req.params.id).populate('cliente_id').populate('itens.produto_id');
    if (venda == null) {
      return res.status(404).json({ message: 'Venda não encontrada' });
    }
    res.json(venda);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Criar uma nova venda
exports.createVenda = async (req, res) => {
    const { cliente_id, status } = req.body;
    const itens = req.body.itens || []; // Garante que itens é um array
    try {
        let total_venda = 0;
        const itensComPreco = [];

        for (const item of itens) {
            const produto = await Produto.findById(item.produto_id);
            if (!produto) {
                throw new Error(`Produto com ID ${item.produto_id} não encontrado.`);
            }

            const estoque = await Estoque.findOne({ produto_id: item.produto_id });
            if (!estoque || estoque.quantidade < item.quantidade) {
                throw new Error(`Estoque insuficiente para o produto ${produto.nome}.`);
            }

            const preco_unitario = produto.preco;
            total_venda += preco_unitario * item.quantidade;
            
            itensComPreco.push({
                produto_id: item.produto_id,
                quantidade: item.quantidade,
                preco_unitario: preco_unitario
            });

            // Atualiza o estoque
            estoque.quantidade -= item.quantidade;
            await estoque.save();
        }

        const novaVenda = new Venda({
            cliente_id,
            itens: itensComPreco,
            total_venda,
            status
        });

        const vendaSalva = await novaVenda.save();
        res.status(201).json(vendaSalva);

    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};


// Atualizar o status de uma venda
exports.updateVendaStatus = async (req, res) => {
  try {
    const venda = await Venda.findById(req.params.id);
    if (venda == null) {
      return res.status(404).json({ message: 'Venda não encontrada' });
    }

    if (req.body.status != null) {
      venda.status = req.body.status;
    }

    const updatedVenda = await venda.save();
    res.json(updatedVenda);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};