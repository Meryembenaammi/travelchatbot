const mongoose = require('mongoose');

const HotelSchema = new mongoose.Schema({
  id: String,
  title: String,
  primaryInfo: String,
  secondaryInfo: String,
  badge: {
    size: String,
    type: String,
    year: String
  },
  bubbleRating: {
    count: String,
    rating: Number
  },
  isSponsored: Boolean,
  accentedLabel: Boolean,
  provider: String
});

module.exports = mongoose.model('Hotel', HotelSchema);
