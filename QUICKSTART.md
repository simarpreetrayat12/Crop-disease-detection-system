# 🌾 Crop Disease Detection System - Complete Setup & Running Guide

## ✅ Project Status

**AllComponents Built and Ready!**

- ✅ **Backend**: Spring Boot 4.0 (Java 25) - BUILT
- ✅ **Python AI API**: Flask stub - CREATED
- ✅ **Frontend**: HTML/CSS/JS - CREATED
- ✅ **Database**: H2 (In-Memory) - CONFIGURED

---

## 🚀 Quick Start (5 Minutes)

### **Option 1: Automatic Start (Windows)**

```batch
# Navigate to the project folder and run:
start.bat
```

This will:
- ✅ Start Python AI API on port 5000
- ✅ Start Spring Boot Backend on port 8080
- ✅ Open Frontend in browser

---

### **Option 2: Manual Start**

#### **1️⃣ Start Python AI API (Terminal 1)**

```bash
cd "c:\Users\simar\Desktop\Crop disease detection"
python python_ai_api.py
```

**Expected Output:**
```
============================================================
🌾 Crop Disease Detection AI API Started
📍 Server running at http://localhost:5000
============================================================
```

#### **2️⃣ Start Spring Boot Backend (Terminal 2)**

```bash
cd "c:\Users\simar\Desktop\Crop disease detection\backend"
mvn spring-boot:run
```

**Expected Output:**
```
================================================
🌾 Crop Disease Detection System Started
📍 Server running at http://localhost:8080
================================================
```

#### **3️⃣ Open Frontend (Browser)**

```
1. Open any web browser
2. Type: file:///c:/Users/simar/Desktop/Crop disease detection/index.html
3. Or drag index.html into browser
```

---

## 📋 Project Structure

```
Crop disease detection/
├── 🌐 index.html                    # Frontend home page
├── 🎨 styles.css                    # Frontend styling
├── 📜 script.js                     # Frontend JavaScript
├── 🐍 python_ai_api.py             # Flask AI API (mock predictions)
├── 🚀 start.bat                     # Windows startup script
├── 📖 README.md                     # This file
│
└── backend/                         # Spring Boot Backend
    ├── pom.xml                      # Maven dependencies
    ├── src/main/
    │   ├── java/com/cropdetection/
    │   │   ├── CropDiseaseDetectionApplication.java   # Main app
    │   │   ├── controller/
    │   │   │   ├── PredictionController.java          # REST APIs
    │   │   │   └── dto/
    │   │   │       ├── PredictionRequest.java
    │   │   │       └── PredictionResponse.java
    │   │   ├── service/
    │   │   │   └── PredictionService.java             # Business logic
    │   │   ├── entity/
    │   │   │   └── Prediction.java                    # Database model
    │   │   ├── repository/
    │   │   │   └── PredictionRepository.java          # Data access
    │   │   ├── config/
    │   │   │   └── CorsConfig.java                    # CORS setup
    │   │   └── util/
    │   │       ├── ImageUploadUtil.java               # File handling
    │   │       └── PythonAIClient.java                # API client
    │   └── resources/
    │       └── application.properties                 # Config
    ├── database/
    │   └── crop_disease_system.sql                   # Database schema
    ├── uploads/                                       # Uploaded images
    └── target/                                        # Build output
```

---

## 🔄 Complete Workflow

### **Step 1: Upload Image**
- Navigate to frontend (`index.html`)
- Click upload area or drag & drop a crop leaf image
- Supported: JPG, PNG, GIF (Max 10 MB)

### **Step 2: Get Prediction**
- Click "🚀 Predict Disease" button
- Backend processes request

### **Step 3: Backend Processing**
```
Frontend → Backend → Python AI API → Backend → Frontend
  (POST)     (REST)      (Flask)      (JSON)    (Display)
```

### **Step 4: View Results**
- Disease name (e.g., "Early Blight")
- Confidence percentage (e.g., 92.5%)
- Treatment solution

### **Step 5: View History**
- Click "📜 History" tab
- View all past predictions
- See disease trends

---

## 🔌 API Endpoints

### **Backend Endpoints** (`http://localhost:8080/api`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/predict` | Upload image & get prediction |
| `GET` | `/history` | Get all predictions |
| `GET` | `/history/disease?name=...` | Filter by disease |
| `GET` | `/history/confidence?min=75` | Filter by confidence |
| `GET` | `/health` | Health check |
| `GET` | `/info` | API information |

### **Python AI API Endpoints** (`http://localhost:5000`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/predict` | Predict disease (receives image) |
| `GET` | `/health` | Health check |
| `GET` | `/info` | API information |

---

## 🧪 Testing the System

### **Test 1: Check Backend Health**

Using cURL or Postman:
```bash
GET http://localhost:8080/api/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "service": "Crop Disease Detection API",
  "totalPredictions": 0
}
```

### **Test 2: Upload Image**

```bash
POST http://localhost:8080/api/predict
Content-Type: multipart/form-data
Body: image=[image_file]
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "disease": "Early Blight",
    "confidence": 92.5,
    "solution": "Apply copper-based fungicide...",
    "createdAt": "2026-04-04 10:30:45"
  },
  "message": "Disease prediction successful"
}
```

### **Test 3: Get History**

```bash
GET http://localhost:8080/api/history
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "disease": "Early Blight",
      "confidence": 92.5,
      "solution": "Apply copper-based fungicide...",
      "createdAt": "2026-04-04 10:30:45"
    }
  ],
  "total": 1,
  "message": "Predictions retrieved successfully"
}
```

---

## 🐛 Troubleshooting

### **❌ "Backend is not running" message**

**Solution:**
```bash
# Terminal 1: Start backend
cd backend
mvn spring-boot:run
```

Check if `http://localhost:8080/api/health` returns response.

### **❌ "Python API is not responding"**

**Solution:**
```bash
# Terminal 2: Start Python API
python python_ai_api.py
```

Check if `http://localhost:5000/health` returns response.

### **❌ "File not found" error**

**Solution:**
- Make sure `index.html` is in the right location
- Use full path: `file:///c:/Users/simar/Desktop/Crop disease detection/index.html`
- Or use a local server:
  ```bash
  # In the project folder
  python -m http.server 3000
  # Then open: http://localhost:3000
  ```

### **❌ CORS errors**

**Already configured!** CORS is enabled in `backend/src/.../config/CorsConfig.java`

### **❌ Port already in use**

**For Port 8080 (Backend):**
```bash
# Find process using port 8080
netstat -ano | findstr :8080

# Kill the process (replace PID)
taskkill /PID [PID] /F
```

**For Port 5000 (Python API):**
```bash
# Find process
netstat -ano | findstr :5000

# Kill the process
taskkill /PID [PID] /F
```

---

## 📊 Database

### **Database: H2 (In-Memory)**

- **No installation needed!** Embeds in Spring Boot
- **Auto-creates tables** on startup
- **Data lost** when app restarts (development mode)

### **Access H2 Console:**

```
http://localhost:8080/h2-console
```

**Credentials:**
- URL: `jdbc:h2:mem:crop_disease_db`
- User: `sa`
- Password: (leave empty)

---

## 🎯 Key Features

### **Frontend**
- 🖼️ Drag & drop image upload
- 📱 Responsive mobile design
- 📊 Prediction history view
- 🎨 Beautiful gradient UI
- ⚡ Real-time error handling

### **Backend**
- 🔄 RESTful API
- 🗄️ Database persistence (H2)
- 📁 Image storage on disk
- 📊 Multiple query endpoints
- ✅ Input validation

### **Python AI API**
- 🤖 Mock predictions (for testing)
- 🎯 Random disease selection
- 📝 Realistic responses
- 🔌 Easy to connect real ML model

---

## 🚀 Next Steps (Future Enhancements)

1. **Train Real ML Model**
   - Replace mock predictions with actual ML model
   - Use TensorFlow/PyTorch for disease classification

2. **Add Authentication**
   - Login/signup
   - User-specific history
   - Admin dashboard

3. **Deploy to Cloud**
   - Azure App Service (Backend)
   - Azure Storage (Images)
   - Azure DB (Production DB)

4. **Add More Features**
   - Real-time disease alerts
   - Weather-based recommendations
   - Mobile app (React Native/Flutter)
   - SMS notifications

5. **Production Setup**
   - Use MySQL instead of H2
   - Add SSL/HTTPS
   - Implement rate limiting
   - Add logging and monitoring

---

## 📚 Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Backend** | Spring Boot | 4.0.0 |
| **Java** | OpenJDK | 25 |
| **Frontend** | HTML5 + CSS3 + Vanilla JS | Latest |
| **Python API** | Flask | 2.x+ |
| **Database** | H2 Database | In-Memory |
| **Build Tool** | Maven | 3.9.14 |
| **Server** | Tomcat (Embedded) | 10.x |

---

## 📞 Support & Debugging

### **Enable Debug Logging**

Edit `backend/src/main/resources/application.properties`:
```properties
logging.level.com.cropdetection=DEBUG
logging.level.org.springframework.web=DEBUG
```

### **View Logs**

- **Backend Logs**: Console output when running `mvn spring-boot:run`
- **Frontend Logs**: Browser DevTools (F12 → Console)
- **Python Logs**: Console output when running `python python_ai_api.py`

### **Common Commands**

```bash
# Build backend
cd backend
mvn clean compile

# Run tests
mvn test

# Build JAR
mvn clean package

# Clean build files
mvn clean
```

---

## ✅ Verification Checklist

Before claiming the project is "done":

- [ ] Backend compiles without errors
- [ ] Python API returns mock predictions
- [ ] Frontend loads in browser
- [ ] Can upload image through UI
- [ ] Backend receives and processes request
- [ ] Python API returns mock response
- [ ] Result displays in frontend
- [ ] Data saves to database
- [ ] History page shows all predictions
- [ ] No console errors (F12)

---

## 🎓 Learning Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [REST API Best Practices](https://restfulapi.net/)
- [HTML/CSS/JS Tutorial](https://developer.mozilla.org/en-US/)

---

## 📄 License

This project is open source and available for educational purposes.

---

## 👤 Author

Created as a demonstration of a complete full-stack application with AI integration.

---

**Happy Coding! 🚀🌾**

If everything works → You have a working prototype!
If you get stuck → Check troubleshooting section above
