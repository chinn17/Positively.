const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);




exports.sendPushNotification = functions.database.ref('/messages/{messageId}').onWrite(event => {
       

    var db = admin.database();

    var messageText;
    var senderName;
    var receiverId;
    var senderId;

    var messageId = event.params.messageId;


    var messageTextRef = db.ref('/messages/' + messageId + '/text');
    var senderIdRef = db.ref('/messages/' + messageId + '/fromId');
    var receiverIdRef = db.ref('/messages/' + messageId + '/toId');

   return messageTextRef.once("value", function(data) {

            if (data.val() == null) {
            messageText = "sent an image"
        } else {
            messageText = data.val();
        }

    senderIdRef.once("value", function(data) {

            senderId = data.val();


    receiverIdRef.once("value", function(data) {

            receiverId = data.val();


     var senderNameRef = db.ref('/users/' + senderId + '/name');

    senderNameRef.once("value", function(data) {

            senderName = data.val();

            console.log(senderName);
            console.log(messageText);



    const payload = {

    	notification : {
    		title: String(senderName),
    		body: String(messageText),
    		badge: "1",
    		sound: 'default',
    	}

    };

    	 return admin.database().ref('fcmToken').once('value').then(allToken => {
    	 	if (allToken.val()) {
    	 		const token = Object.keys(allToken.val());
    		return admin.messaging().sendToTopic(receiverId, payload).then(response => {

    			});

    		 };



            }, function (errorObject) {
        console.log("The read failed: " + errorObject.code);
        });


     }, function (errorObject) {
        console.log("The read failed: " + errorObject.code);
        });    


         }, function (errorObject) {
        console.log("The read failed: " + errorObject.code);
        });


 
     }, function (errorObject) {
        console.log("The read failed: " + errorObject.code);
        });


  	});                                                                               
   });
