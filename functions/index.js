const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnNewHouse = functions.firestore
  .document("houses/{houseId}")
  .onCreate(async (snap, context) => {
    const newHouse = snap.data();
    const houseType = newHouse.type;
    const houseId = context.params.houseId;
    const messageId = Math.floor(Math.random() * 90000) + 10000;

    // Obtenez tous les utilisateurs
    const usersSnapshot = await admin
      .firestore()
      .collection("userPreferences")
      .get();

    if (usersSnapshot.empty) {
      return null;
    }

    const tokens = [];

    // Parcourez chaque utilisateur pour vérifier ses préférences
    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();

      // Vérifiez si les préférences correspondent au type de logement
      if (
        userData[houseType] === true &&
        userData["notificationsEnabled"] === true
      ) {
        const token = userData.fcmToken;
        if (token) {
          tokens.push(token);
        }
      }
    }

    if (tokens.length === 0) {
      return null;
    }

    const payload = {
      notification: {
        title: "Nouvelle annonce de logement",
        body: `Il y a une nouvelle annonce pour un ${houseType["label"]}!`,
        sound: "sound_notification",
        // channel_id: "alysites.madifoodcommand",
      },
      data: {
        houseId: houseId,
        houseImage: newHouse.imageUrl,
        messageId: messageId,
      },
    };
    return admin.messaging().sendToDevice(tokens, payload);
  });
