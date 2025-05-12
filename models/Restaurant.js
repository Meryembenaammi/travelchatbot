// models/Restaurant.js
const mongoose = require('mongoose');

const RestaurantSchema = new mongoose.Schema({
  restaurantsId: { type: String, required: true },
  name: { type: String, required: true },
  averageRating: { type: String },
  userReviewCount: { type: Number },
  currentOpenStatus: { type: String },
  priceTag: { type: String },
  menuUrl: { type: String },
  establishmentTypeAndCuisineTags: [{ type: String }],
  heroImgUrl: { type: String },
  reviewSnippets: [{
    reviewText: { type: String },
    reviewUrl: { type: String }
  }]
});

module.exports = mongoose.model('Restaurant', RestaurantSchema);
