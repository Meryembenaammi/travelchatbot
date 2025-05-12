const mongoose = require('mongoose');

const airportSchema = new mongoose.Schema({
  name: String,
  city: String,
  code: String,
  country: String
});

module.exports = mongoose.models.Airport || mongoose.model('Airport', airportSchema);
