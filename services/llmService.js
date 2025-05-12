const axios = require("axios");
require("dotenv").config();

exports.callLLM = async (userMessage) => {
  const systemInstruction = `
Tu es un assistant intelligent avec accès à des actions :
- Pour rechercher un hôtel : <<ACTION: searchHotels {"city":"Paris"}>>
- Pour réserver un hôtel : <<ACTION: bookHotel {"hotel":"Eden", "user":"Meryem", "date":"2024-02-14"}>>

Ne réponds pas directement si une action est nécessaire. Donne l'action à exécuter.
`;

  const response = await axios.post(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${process.env.GOOGLE_API_KEY}`,
    {
      contents: [
        { role: "user", parts: [{ text: systemInstruction }] },
        { role: "user", parts: [{ text: userMessage }] },
      ],
    },
    {
      headers: { "Content-Type": "application/json" },
    }
  );

  const reply = response.data.candidates[0].content.parts[0].text;
  return reply;
};
