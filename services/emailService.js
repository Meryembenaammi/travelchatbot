const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,      
    pass: process.env.EMAIL_PASSWORD   
  },
  tls: {
    rejectUnauthorized: false          // <-- Pour ignorer l’erreur de certificat auto-signé
  }
});

const sendConfirmationEmail = async (userEmail, tripSummary) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: userEmail,
      subject: 'Confirmation de votre réservation SAMWay',
      html: `
        <h1>Confirmation de votre réservation</h1>
        <div>
          <h2>Détails du voyage</h2>
          ${tripSummary}
        </div>
        <p>Merci d'avoir choisi SAMWay pour votre voyage !</p>
      `
    };

    await transporter.sendMail(mailOptions);
    return true;
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email:', error);
    throw error;
  }
};

module.exports = { sendConfirmationEmail };