const functions = require("firebase-functions");
const admin = require('firebase-admin')

admin.initializeApp(functions.config().functions);
const db = admin.firestore();

exports.deliveryNotifier = functions.firestore.document('deliveries/{deliveryId}').onCreate(async (snapshot, context) => {
    if (snapshot.empty) {
        console.log('No hay receptor');
    }
    const values = snapshot.data;
    var tokens = [];
    const documents = await db.collection('dommers').get();
    for (var doc of documents.docs) {
        tokens.push(doc.data().token);
    }
    var payload = {
        notification: { title: 'Título ${deliveryId}', body: 'Ganarás ${values.price}', sound: 'default' },
        data: { click_action: 'FLUTTER_NOTIFICATION_CLICK', message: 'El cliente es ${values.userName}' },
    };
    try {
        console.log('E')
        const responde = await admin.messaging().sendToDevice(tokens, payload);
        console.log('Exito')
    } catch (e) {
        console.log('Error notificando')
    }
});