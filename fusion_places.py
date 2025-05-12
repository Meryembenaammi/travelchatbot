from pymongo import MongoClient
import random

# Connexion MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client["TravelPlanner"]
places_collection = db["places"]
places_collection.delete_many({})  # Réinitialise la collection

# Dictionnaire des quartiers par ville
quartiersParVille = {
    "Paris": ["batignolles", "montparnasse", "champs", "louvre", "opéra", 
              "belleville", "montmartre", "défense", "saint-germain", 
              "charonne", "butte", "passy", "grenelle", "marais",
              "bastille", "la chapelle", "clichy", "villette", "auteuil",
              "trocadéro", "invalides", "quartier latin", "châtelet"],
    "Madrid": ["salamanca", "chamberí", "malasaña", "la latina", "retiro", 
               "centro", "argüelles", "chamartín", "paseo del prado"],
    "New York City": ["manhattan", "downtown", "midtown", "hudson yards", "theater district", 
                      "brooklyn", "queens", "staten island", "greenwich village"],
    "Istanbul": ["beyoğlu", "sultanahmet", "taksim", "kadıköy", "beşiktaş"]
}

# 🔹 HOTELS
for doc in db.hotels.find({}):
    ville = doc.get("ville", "Paris")
    quartier = random.choice(quartiersParVille.get(ville, ["inconnu"]))

    data = doc.get("data", {})
    hotel_list = []

    if isinstance(data, dict):
        hotel_list = data.get("data", [])
    elif isinstance(data, list):
        hotel_list = data
    else:
        print(f"⚠️ Format inattendu pour doc['data'] : {type(data)}")
        continue

    for hotel in hotel_list:
        new_doc = {
            "type": "hotel",
            "name": hotel.get("title"),
            "location": quartier,
            "city": ville,
            "rating": hotel.get("bubbleRating", {}).get("rating"),
            "reviewCount": hotel.get("bubbleRating", {}).get("count"),
            "price": hotel.get("priceForDisplay"),
            "provider": hotel.get("provider"),
            "images": [img["sizes"]["urlTemplate"].format(width=700, height=500)
                       for img in hotel.get("cardPhotos", []) if "sizes" in img],
            "tags": [],
            "reviews": []
        }
        places_collection.insert_one(new_doc)

# 🔹 RESTAURANTS
for doc in db.Restaurants.find({}):
    ville = doc.get("ville", "Paris")
    quartier = random.choice(quartiersParVille.get(ville, ["inconnu"]))
    restaurants = doc.get("data", {}).get("restaurants", [])
    for rest in restaurants:
        new_doc = {
            "type": "restaurant",
            "name": rest.get("name"),
            "location": quartier,
            "city": ville,
            "rating": rest.get("averageRating"),
            "reviewCount": rest.get("userReviewCount"),
            "price": rest.get("priceTag"),
            "provider": "Tripadvisor",
            "images": [url for url in [rest.get("heroImgUrl"), rest.get("squareImgUrl")] if url],
            "tags": rest.get("establishmentTypeAndCuisineTags", []),
            "reviews": [
                {
                    "text": r.get("reviewText"),
                    "url": r.get("reviewUrl")
                } for r in rest.get("reviewSnippets", [])
            ]
        }
        places_collection.insert_one(new_doc)

# 🔹 ACTIVITIES (si tu en as besoin)
for doc in db.Activities.find({}):  # Utiliser la collection des activités
    ville = doc.get("ville", "Paris")
    quartier = random.choice(quartiersParVille.get(ville, ["inconnu"]))
    activities = doc.get("data", {}).get("activities", [])
    for activity in activities:
        new_doc = {
            "type": "activity",
            "name": activity.get("name"),
            "location": quartier,
            "city": ville,
            "rating": activity.get("rating"),
            "reviewCount": activity.get("userReviewCount"),
            "price": activity.get("price"),
            "provider": "Tripadvisor",
            "images": [url for url in [activity.get("imageUrl")] if url],
            "tags": activity.get("tags", []),
            "reviews": [
                {
                    "text": r.get("reviewText"),
                    "url": r.get("reviewUrl")
                } for r in activity.get("reviewSnippets", [])
            ]
        }
        places_collection.insert_one(new_doc)

print("✅ Transformation terminée. Données insérées dans 'places'.")
