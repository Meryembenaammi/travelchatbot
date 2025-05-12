const { GoogleGenerativeAI } = require("@google/generative-ai");
const Hotel = require("../models/hotel.model");
const Activity = require("../models/activity.model");
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

exports.chatWithLLM = async (req, res) => {
  const userMessage = req.body.message;

  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    // Étape 1 : Appel LLM
    const result = await model.generateContent(userMessage);
    const aiResponse = result.response.text();

    // Étape 2 : Optionnel – Appelle MongoDB si l’intention le demande
    let mongoData = null;
    if (userMessage.toLowerCase().includes("hôtel") || aiResponse.includes("hôtel")) {
      mongoData = await Hotel.find({ city: /paris/i }).limit(3); // exemple
    }

    // Étape 3 : Composition finale
    const finalResponse = mongoData
      ? aiResponse + "\nVoici quelques hôtels :\n" + mongoData.map(h => `🏨 ${h.name}`).join("\n")
      : aiResponse;

    res.json({ response: finalResponse });
  } catch (error) {
    console.error("Erreur chat:", error);
    res.status(500).json({ error: "Erreur interne du serveur." });
  }
};
