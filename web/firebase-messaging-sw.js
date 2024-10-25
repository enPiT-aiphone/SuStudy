// firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-messaging.js');

firebase.initializeApp({
    apiKey: 'AIzaSyDaAMNihzzLLoirhp5fujWUG0hkyDi9MtA',
    appId: '1:62928690852:web:8a1c4c8f3dc9fc164e1031',
    messagingSenderId: '62928690852',
    projectId: 'todokukunn',
    authDomain: 'todokukunn.firebaseapp.com',
    storageBucket: 'todokukunn.appspot.com',
    measurementId: 'G-N48D2XDC7M',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png' // アイコンのURL
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
