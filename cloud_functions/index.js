/**
 * Cloud Functions для отправки push-уведомлений через FCM V1 API
 * 
 * Установка:
 * 1. npm install -g firebase-tools
 * 2. firebase login
 * 3. cd cloud_functions
 * 4. npm install
 * 5. firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function: Отправка уведомления через FCM V1 API
 * Вызывается из админ-панели через Cloud Functions
 */
exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Проверка данных
  const { userId, title, body, data: notificationData } = data;

  if (!userId || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userId, title, and body are required'
    );
  }

  const result = await sendSingleNotification(userId, title, body, notificationData || {});
  
  if (!result.success) {
    throw new functions.https.HttpsError('internal', result.error || 'Failed to send notification');
  }

  return {
    success: true,
    messageId: result.messageId,
  };
});

/**
 * Вспомогательная функция для отправки одного уведомления
 */
async function sendSingleNotification(userId, title, body, notificationData) {
  try {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return { success: false, error: 'User not found' };
    }

    const fcmToken = userDoc.data()?.fcmToken;
    
    if (!fcmToken) {
      return { success: false, error: 'FCM token not found' };
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        ...notificationData,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: fcmToken,
      android: {
        priority: 'high',
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    return { success: true, messageId: response };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

/**
 * Cloud Function: Массовая отправка уведомлений
 */
exports.sendNotificationsToUsers = functions.https.onCall(async (data, context) => {
  const { userIds, title, body, data: notificationData } = data;

  if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userIds array is required'
    );
  }

  if (!title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'title and body are required'
    );
  }

  const results = [];
  
  for (const userId of userIds) {
    const result = await sendSingleNotification(userId, title, body, notificationData);
    results.push({ userId, ...result });
  }

  const successCount = results.filter(r => r.success).length;
  
  return {
    success: true,
    total: userIds.length,
    successCount: successCount,
    results: results,
  };
});
