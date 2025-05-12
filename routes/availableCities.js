const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

const villesConnues = [
  "paris", "madrid", "rabat", "casablanca", "istanbul", "new york",
  "rome", "lisbonne", "dakhla", "al hoceima", "barcelone", "marrakech"
];

function matchCity(str) {
  const cleaned = str.trim().toLowerCase();
  return villesConnues.find(city => cleaned.includes(city)) || null;
}

function getNestedField(obj, path) {
  return path.split('.').reduce((acc, key) => acc && acc[key], obj);
}

async function extractCitiesFromCollection(collectionName, fields = []) {
  const collection = mongoose.connection.collection(collectionName);
  const docs = await collection.find().toArray();
  const cities = new Set();

  docs.forEach(doc => {
    const dataArray = doc?.data?.data;

    if (Array.isArray(dataArray)) {
      dataArray.forEach(item => {
        fields.forEach(field => {
          const value = getNestedField(item, field);
          if (typeof value === 'string') {
            const city = matchCity(value);
            if (city) cities.add(city);
          }

          if (field === 'title' && typeof item.title === 'string') {
            const parts = item.title.split(',');
            if (parts.length >= 2) {
              const city = matchCity(parts[1]);
              if (city) cities.add(city);
            }
          }
        });
      });
    }
  });

  return Array.from(cities).sort();
}

router.get('/', async (req, res) => {
  try {
    const hotels = await extractCitiesFromCollection('hotels', ['title', 'region', 'secondaryInfo']);
    const activities = await extractCitiesFromCollection('activities', ['title', 'region']);
    const restaurants = await extractCitiesFromCollection('restaurants', ['title', 'region']);
    const airports = await extractCitiesFromCollection('airports', ['city']);
    const flights = await extractCitiesFromCollection('flights', ['departure.city', 'arrival.city']);

    return res.json({
      hotels,
      activities,
      restaurants,
      airports,
      flights
    });
  } catch (err) {
    console.error('❌ Erreur:', err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;
