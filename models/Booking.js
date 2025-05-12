const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  hotel: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hotel'
  },
  activities: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Activity'
  }],
  flights: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Flight'
  }],
  restaurantReservations: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant'
  }],
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    default: 'pending'
  },
  totalPrice: {
    type: Number,
    required: true
  },
  specialRequests: String,
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index pour les requêtes fréquentes
bookingSchema.index({ user: 1, status: 1 });

// Middleware pour valider les dates
bookingSchema.pre('save', function(next) {
  if (this.endDate <= this.startDate) {
    throw new Error('La date de fin doit être après la date de début');
  }
  next();
});

module.exports = mongoose.model('Booking', bookingSchema);