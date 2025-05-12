const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  title: String,
  secondaryInfo: String,
  description: String,
  ufiDetails: {
    bCityName: String,
  }
});

module.exports = mongoose.models.Activity || mongoose.model('Activity', activitySchema);
