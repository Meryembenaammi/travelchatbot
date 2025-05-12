const express = require('express');
const router = express.Router();
const Hotel = require('../models/Hotel');

// 🔍 Route GET pour tester la lecture des hôtels
router.get('/', async (req, res) => {
  try {
    const hotels = await Hotel.find();
    res.json(hotels);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur lors de la récupération des hôtels' });
  }
});

// ➕ Route POST pour insérer un hôtel de test
router.post('/add', async (req, res) => {
  try {
    const newHotel = new Hotel({
      name: "Hôtel Test",
      location: "Paris",
      stars: 4,
      price: 120,
      description: "Un hôtel romantique pour la Saint-Valentin",
      amenities: ["WiFi", "Spa", "Petit-déjeuner"]
    });
    const saved = await newHotel.save();
    res.json(saved);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Erreur lors de l’ajout de l’hôtel' });
  }
});

module.exports = router;
