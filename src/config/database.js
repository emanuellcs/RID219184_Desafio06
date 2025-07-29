const mongoose = require('mongoose');
require('dotenv').config();

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Conectado ao MongoDB. Sistema pronto para uso.');
  } catch (error) {
    console.error('Erro de conexão com o MongoDB:', error);
    process.exit(1);
  }
};

module.exports = connectDB;