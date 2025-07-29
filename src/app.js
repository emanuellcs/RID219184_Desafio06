require('dotenv').config();
const express = require('express');
const connectDB = require('./config/database');
const produtoRoutes = require('./routes/produtoRoutes');
const clienteRoutes = require('./routes/clienteRoutes');
const vendaRoutes = require('./routes/vendaRoutes');
const estoqueRoutes = require('./routes/estoqueRoutes');

// Conectar ao banco de dados
connectDB();

const app = express();
app.use(express.json());

// Usar as rotas
app.use('/produtos', produtoRoutes);
app.use('/clientes', clienteRoutes);
app.use('/vendas', vendaRoutes);
app.use('/estoque', estoqueRoutes);

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});