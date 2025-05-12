const mongoose = require('mongoose');

const flightSchema = new mongoose.Schema({
  airline: String,
  departure: {
    city: String,
    airport: String,
    time: String
  },
  arrival: {
    city: String,
    airport: String,
    time: String
  },
  price: Number
});

module.exports = mongoose.models.Flight || mongoose.model('Flight', flightSchema);
