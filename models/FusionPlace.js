// models/FusionPlace.js
const mongoose = require('mongoose');

const FusionPlaceSchema = new mongoose.Schema({
  ville: String,
  quartier: String,
  type: String, // 'hotel', 'activity', 'restaurant'
  name: String,
  description: String,
  price: String,
  rating: String,
  image: String,
  location: String
}, { collection: 'fusion_places' });

module.exports = mongoose.model('FusionPlace', FusionPlaceSchema);
