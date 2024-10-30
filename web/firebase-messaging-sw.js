// firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDaAMNihzzLLoirhp5fujWUG0hkyDi9MtA",
  authDomain: "todokukunn.firebaseapp.com",
  projectId: "todokukunn",
  storageBucket: "todokukunn.appspot.com",
  messagingSenderId: "62928690852",
  appId: "1:62928690852:web:8a1c4c8f3dc9fc164e1031",
  measurementId: "G-N48D2XDC7M"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("Received background message: ", message);
  const notificationTitle = message.notification.title;
  const notificationOptions = {
    body: message.notification.body,
    icon: '/icon.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
