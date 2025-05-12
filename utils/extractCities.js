const mongoose = require('mongoose');
require('dotenv').config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/TravelPlanner';

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('✅ Connecté à MongoDB');
    run();
  })
  .catch((err) => {
    console.error('❌ Erreur connexion MongoDB:', err);
  });

// ✅ Liste blanche des villes cibles
const villesConnues = [
  "paris", "madrid", "rabat", "casablanca", "istanbul", "new york",
  "rome", "lisbonne", "dakhla", "al hoceima", "barcelone", "marrakech"
];

// ✅ Match plus intelligent : retourne la ville trouvée
function matchCity(str) {
  const cleaned = str.trim().toLowerCase();
  return villesConnues.find(city => cleaned.includes(city)) || null;
}

// 🔁 Pour accéder à un champ imbriqué (ex: "data.location.city")
function getNestedField(obj, path) {
  return path.split('.').reduce((acc, key) => acc && acc[key], obj);
}

// 🔍 Extraction des villes
async function extractUniqueCities(collectionName, fieldCandidates = []) {
  const collection = mongoose.connection.collection(collectionName);
  const docs = await collection.find().toArray();
  const cities = new Set();

  docs.forEach(doc => {
    const dataArray = doc?.data?.data;

    if (Array.isArray(dataArray)) {
      dataArray.forEach(item => {
        fieldCandidates.forEach(field => {
          const value = getNestedField(item, field);

          if (typeof value === 'string' && value.length < 100) {
            const matched = matchCity(value);
            if (matched) cities.add(matched);
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

// 🚀 Fonction principale
async function run() {
  const hotelsCities = await extractUniqueCities('hotels', ['title', 'secondaryInfo', 'region']);
  const activityCities = await extractUniqueCities('activities', ['title', 'region', 'location.city']);
  const restaurantCities = await extractUniqueCities('restaurants', ['title', 'region', 'location.city']);
  const airportCities = await extractUniqueCities('airports', ['city', 'location.city']);
  const flightCities = await extractUniqueCities('flights', ['departure.city', 'arrival.city']);

  console.log('\n📍 Villes valides détectées :\n');
  console.log('🏨 Hôtels :', hotelsCities);
  console.log('🎯 Activités :', activityCities);
  console.log('🍽️ Restaurants :', restaurantCities);
  console.log('✈️ Aéroports :', airportCities);
  console.log('🛫 Vols :', flightCities);

  process.exit();
}
