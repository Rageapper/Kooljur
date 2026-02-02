/**
 * Vercel Serverless Function для автоматического получения и обновления FCM токена
 * 
 * Развертывание:
 * 1. Установите Vercel CLI: npm install -g vercel
 * 2. Войдите: vercel login
 * 3. Разверните: vercel --prod
 * 
 * Или используйте веб-интерфейс Vercel для развертывания
 */

const { GoogleAuth } = require('google-auth-library');

// Кэш токена
let cachedToken = null;
let tokenExpiry = null;

async function getAccessToken() {
  // Проверяем, действителен ли кэшированный токен
  if (cachedToken && tokenExpiry && Date.now() < tokenExpiry - 5 * 60 * 1000) {
    return cachedToken;
  }

  try {
    // Загружаем Service Account ключ из переменных окружения
    const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
    
    if (!serviceAccountKey) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_KEY environment variable is not set');
    }

    const key = JSON.parse(serviceAccountKey);
    
    // Создаем клиент для аутентификации
    const auth = new GoogleAuth({
      credentials: key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });

    // Получаем токен
    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();

    if (accessToken.token) {
      // Кэшируем токен (действителен ~1 час)
      cachedToken = accessToken.token;
      tokenExpiry = Date.now() + 55 * 60 * 1000; // 55 минут для безопасности
      
      return cachedToken;
    } else {
      throw new Error('Failed to get access token');
    }
  } catch (error) {
    console.error('Error getting access token:', error);
    throw error;
  }
}

// Vercel Serverless Function
module.exports = async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const token = await getAccessToken();
    
    res.status(200).json({
      success: true,
      token: token,
      expiresIn: 3600, // 1 час в секундах
      timestamp: Date.now(),
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to get token',
    });
  }
};
