const axios = require('axios');

async function runGemini(prompt, data) {
  // Exemple simplifié
  const response = await axios.post(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_GOOGLE_API_KEY',
    {
      contents: [{ role: 'user', parts: [{ text: prompt }] }]
    }
  );

  return response.data.candidates?.[0]?.content?.parts?.[0]?.text || 'Aucune réponse générée.';
}

module.exports = { runGemini };
