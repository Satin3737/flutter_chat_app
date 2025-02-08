    const {
      onDocumentCreated,
    } = require("firebase-functions/v2/firestore");
     
    const admin = require('firebase-admin');
     
    admin.initializeApp();
     
    exports.myFunction =
      onDocumentCreated("/chat/{messageId}", async (event) => {
        return admin.messaging().send({
          notification: {
            title: event.data.data()['userName'],
            body: event.data.data()['message'],
          },
          data: {
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          topic: 'chat',
        });
      });