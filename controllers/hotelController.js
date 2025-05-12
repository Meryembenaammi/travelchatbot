 // controllers/hotelController.js
const Hotel = require("../models/Hotel");

exports.getAllHotels = async (req, res) => {
  try {
    const hotels = await Hotel.find();
    res.json(hotels);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur", error });
  }
};
