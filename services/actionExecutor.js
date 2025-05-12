// services/actionExecutor.js
const Hotel = require("../models/Hotel");
const Activity = require("../models/Activity");
const { MongoClient } = require('mongodb');

const url = 'mongodb://localhost:27017';
const dbName = 'TravelPlanner';

// Cette fonction centralise toutes les actions autorisées
const executeAction = async (action, params) => {
  console.log('⚡ [ActionExecutor] Exécution de l\'action:', action, params);
  const client = new MongoClient(url);

  try {
    await client.connect();
    const db = client.db(dbName);

    switch (action) {
      case 'bookHotel':
        return await bookHotel(db, params);
      case 'searchHotels':
        return await searchHotels(db, params);
      case 'searchActivities':
        return await searchActivities(db, params);
      default:
        throw new Error(`Action non reconnue: ${action}`);
    }
  } finally {
    await client.close();
  }
};

// Action : rechercher des hôtels par ville
const searchHotels = async (db, params) => {
  console.log('🔍 [ActionExecutor] Recherche hôtels avec params:', params);
  
  try {
    const query = {};
    if (params.location) {
      query['data.data.secondaryInfo'] = new RegExp(params.location, 'i');
    }
    if (params.priceRange) {
      // Logique de filtrage par prix à implémenter
    }

    const hotels = await db.collection('hotels')
      .find(query)
      .limit(10)
      .toArray();

    return hotels.map(hotel => ({
      name: hotel.data.data.title,
      location: hotel.data.data.secondaryInfo,
      price: hotel.data.data.priceForDisplay,
      description: hotel.data.data.priceSummary
    }));
  } catch (error) {
    console.error('❌ Erreur lors de la recherche d\'hôtels:', error);
    throw error;
  }
};

// Action : réserver un hôtel
const bookHotel = async (db, params) => {
  console.log('🏨 [ActionExecutor] Réservation hôtel avec params:', params);

  try {
    // Nettoyage du nom d'hôtel pour matcher sans numéro devant
    const cleanHotelName = params.hotelName ? params.hotelName.replace(/^\d+\.\s*/, '').trim() : '';

    const hotelDoc = await db.collection('hotels').findOne({
      $or: [
        { 'data.data.title': params.hotelName },
        { 'data.data.title': cleanHotelName }
      ]
    });

    let hotelData = null;
    if (hotelDoc && Array.isArray(hotelDoc.data.data)) {
      hotelData = hotelDoc.data.data.find(h =>
        h.title === params.hotelName || h.title === cleanHotelName
      );
    }

    // Récupère le prix de façon robuste
    const totalPrice =
      hotelData?.priceForDisplay ||
      hotelData?.commerceInfo?.priceForDisplay?.text ||
      params.price ||
      'Prix non disponible';

    // Récupère le nom de l'hôtel de façon robuste
    const hotelName = hotelData?.title || cleanHotelName || params.hotelName || 'Non spécifié';

    // Création de la réservation
    const booking = {
      hotelId: hotelDoc?._id ? hotelDoc._id.toString() : undefined,
      hotelName: hotelName,
      checkIn: params.checkIn,
      checkOut: params.checkOut,
      userEmail: params.userEmail,
      totalPrice: totalPrice,
      status: 'confirmed',
      createdAt: new Date()
    };

    // Sauvegarde de la réservation
    const result = await db.collection('bookings').insertOne(booking);
    console.log('✅ Réservation créée avec ID:', result.insertedId);

    // Retourne un objet formaté pour le frontend
    return {
      confirmationNumber: result.insertedId.toString(),
      hotelName: booking.hotelName,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      userEmail: booking.userEmail,
      totalPrice: booking.totalPrice,
      status: booking.status,
      createdAt: booking.createdAt
    };
  } catch (error) {
    console.error('❌ Erreur lors de la réservation:', error);
    throw error;
  }
};

// Action : rechercher des activités
const searchActivities = async (db, params) => {
  console.log('🔍 [ActionExecutor] Recherche activités avec params:', params);
  
  try {
    const query = {};
    if (params.location) {
      query['data.products.name'] = new RegExp(params.location, 'i');
    }
    if (params.type) {
      // Logique de filtrage par type d'activité à implémenter
    }

    const activities = await db.collection('activities')
      .find(query)
      .limit(10)
      .toArray();

    return activities.map(activity => ({
      name: activity.data.products.name,
      description: activity.data.products.shortDescription,
      price: activity.data.products.representativePrice?.publicAmount,
      currency: activity.data.products.representativePrice?.currency
    }));
  } catch (error) {
    console.error('❌ Erreur lors de la recherche d\'activités:', error);
    throw error;
  }
};

module.exports = { executeAction };
