const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnHouseUpdate = functions.firestore
  .document("houses/{houseId}")
  .onWrite(async (change, context) => {
    const after = change.after.data();
    if (!after) {
      return null;
    }

    const housingType = after.type; // Assurez-vous que 'type' est bien défini dans vos documents

    // Obtenez les utilisateurs qui ont cette préférence
    const usersSnapshot = await admin
      .firestore()
      .collection("userPreferences")
      .get();
    const usersWithPreference = usersSnapshot.docs.filter((doc) => {
      const user = doc.data();
      return user.preferences && user.preferences[housingType];
    });

    const tokens = usersWithPreference.map((user) => user.fcmToken); // Assurez-vous que 'fcmToken' est stocké

    if (tokens.length === 0) {
      return null;
    }

    const payload = {
      notification: {
        title: "Nouvelle annonce",
        body: `Il y a une nouvelle annonce pour un ${housingType}!`,
      },
    };

    return admin.messaging().sendToDevice(tokens, payload);
  });

// @@@@@@@@@@@@@

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnNewHouse = functions.firestore
  .document("houses/{houseId}")
  .onCreate(async (snap, context) => {
    const newHouse = snap.data();
    const houseType = newHouse.type;

    // Obtenez tous les utilisateurs dont les préférences correspondent au type de logement
    const usersSnapshot = await admin
      .firestore()
      .collection("userPreferences")
      .where(houseType, "==", true)
      .get();

    if (usersSnapshot.empty) {
      return null;
    }

    const tokens = usersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token) => token != null);

    if (tokens.length === 0) {
      return null;
    }

    const payload = {
      notification: {
        title: "Nouvelle annonce de logement",
        body: `Il y a une nouvelle annonce pour un ${houseType}!`,
      },
    };

    return admin.messaging().sendToDevice(tokens, payload);
  });
