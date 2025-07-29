const Produto = require('../models/produto');
const Estoque = require('../models/estoque');

// Listar todos os produtos
exports.getAllProdutos = async (req, res) => {
  try {
    const produtos = await Produto.find();
    res.json(produtos);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Obter um produto por ID
exports.getProdutoById = async (req, res) => {
  try {
    const produto = await Produto.findById(req.params.id);
    if (produto == null) {
      return res.status(404).json({ message: 'Produto não encontrado' });
    }
    res.json(produto);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Criar um novo produto
exports.createProduto = async (req, res) => {
  const produto = new Produto({
    nome: req.body.nome,
    descricao: req.body.descricao,
    preco: req.body.preco,
    categoria: req.body.categoria,
  });

  try {
    const newProduto = await produto.save();
    // Cria a entrada correspondente no estoque
    const estoque = new Estoque({
        produto_id: newProduto._id,
        quantidade: 100 // Estoque inicial padrão
    });
    await estoque.save();
    res.status(201).json(newProduto);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Atualizar um produto
exports.updateProduto = async (req, res) => {
  try {
    const produto = await Produto.findById(req.params.id);
    if (produto == null) {
      return res.status(404).json({ message: 'Produto não encontrado' });
    }

    if (req.body.nome != null) {
      produto.nome = req.body.nome;
    }
    if (req.body.descricao != null) {
      produto.descricao = req.body.descricao;
    }
    if (req.body.preco != null) {
      produto.preco = req.body.preco;
    }
    if (req.body.categoria != null) {
      produto.categoria = req.body.categoria;
    }
    produto.data_atualizacao = Date.now();

    const updatedProduto = await produto.save();
    res.json(updatedProduto);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Deletar um produto
exports.deleteProduto = async (req, res) => {
  try {
    const produto = await Produto.findById(req.params.id);
    if (produto == null) {
      return res.status(404).json({ message: 'Produto não encontrado' });
    }
    // Deleta a entrada correspondente no estoque
    await Estoque.deleteOne({ produto_id: req.params.id });
    await Produto.findByIdAndDelete(req.params.id);
    res.json({ message: 'Produto deletado' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};