const express = require('express');
const router = express.Router();

const villesConnues = [
  "paris", "madrid", "rabat", "casablanca", "istanbul", "new york",
  "rome", "lisbonne", "dakhla", "al hoceima", "barcelone", "marrakech"
];

router.get('/', (req, res) => {
  res.json({ cities: villesConnues });
});

module.exports = router;
