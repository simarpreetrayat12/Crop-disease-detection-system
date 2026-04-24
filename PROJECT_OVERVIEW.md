# 🌾 Crop Disease Detection Web Application

## Project Overview

A complete **AI-based web application** that helps farmers identify plant diseases by uploading images of crops. The system provides instant diagnosis, treatment suggestions, and maintains a history of predictions.

---

## 🎯 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Frontend (HTML/CSS/JS)                  │
│        (Home, Upload, Result, History Pages)                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓ (HTTP/REST)
                     
┌─────────────────────────────────────────────────────────────────┐
│              Java Backend (Spring Boot) - Port 8080              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • Image Upload & Validation                              │  │
│  │ • REST API Endpoints (/api/predict, /api/history)        │  │
│  │ • Communication with Python AI API                        │  │
│  │ • Database Integration (JPA/Hibernate)                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────┬─────────────────────────────────────────────────────┬──┘
         │                                                      │
         ↓ (HTTP)                                              ↓ (JDBC)
         
    Python AI API                                    MySQL Database
    (Flask/FastAPI)                                  (predictions table)
    Port 5000
    • CNN Model
    • Image Processing
    • Disease Prediction
```

---

## 📂 Folder Structure

```
Crop disease detection/
│
├── backend/                                   # ✅ COMPLETED
│   ├── src/main/java/com/cropdetection/
│   │   ├── CropDiseaseDetectionApplication.java
│   │   ├── config/
│   │   │   └── CorsConfig.java
│   │   ├── controller/
│   │   │   ├── PredictionController.java
│   │   │   └── dto/
│   │   ├── entity/
│   │   │   └── Prediction.java
│   │   ├── repository/
│   │   │   └── PredictionRepository.java
│   │   ├── service/
│   │   │   └── PredictionService.java
│   │   └── util/
│   │       ├── ImageUploadUtil.java
│   │       └── PythonAIClient.java
│   ├── src/main/resources/
│   │   └── application.properties
│   ├── database/
│   │   └── setup.sql
│   ├── uploads/                              # Directory for storing images
│   ├── pom.xml
│   └── README.md
│
├── frontend/                                  # ⏳ TO BE CREATED
│   ├── index.html                            # Home page
│   ├── upload.html                           # Upload page
│   ├── result.html                           # Result page
│   ├── history.html                          # History page
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── script.js
│   └── images/
│
├── ai-model/                                  # ⏳ TO BE CREATED
│   ├── app.py                                # Flask API
│   ├── model.py                              # AI model and prediction
│   ├── requirements.txt
│   └── uploads/                              # Temporary uploads
│
└── documentation/
    ├── QUICKSTART_BACKEND.md                 # ✅ Quick start for backend
    └── DATABASE_SETUP.md                     # Coming soon
```

---

## 🔧 Technologies Used

### Backend (Java Spring Boot) ✅
- **Java 17+**
- **Spring Boot 3.2**
- **Spring Data JPA + Hibernate**
- **MySQL 8.0**
- **Maven 3.6+**
- **Apache HTTP Client** (for Python API communication)

### Frontend (HTML/CSS/JS) ⏳
- **HTML5**
- **CSS3 (Bootstrap)**
- **JavaScript (Fetch API)**

### AI Model (Python) ⏳
- **Flask** or **FastAPI**
- **TensorFlow / Keras / PyTorch**
- **OpenCV** (image processing)
- **Pandas, NumPy**

### Database
- **MySQL 8.0+**
- **Predictions table** with id, image_path, disease, confidence, solution, created_at

---

## 📡 API Endpoints (Backend)

### Prediction
- **POST** `/api/predict` - Upload image and predict disease
  - Request: `multipart/form-data` with file field `image`
  - Response: JSON with disease, confidence, solution

### History
- **GET** `/api/history` - Get all predictions
- **GET** `/api/history/disease?disease=name` - Filter by disease
- **GET** `/api/history/confidence?minConfidence=80` - Filter by confidence

### Health & Info
- **GET** `/api/health` - Health check
- **GET** `/api/info` - API documentation

---

## ✨ Features

### Current (Backend) ✅
- ✅ Image upload with validation
- ✅ REST API for prediction and history
- ✅ MySQL database integration
- ✅ Communication with Python AI API
- ✅ Error handling and logging
- ✅ CORS enabled for frontend
- ✅ Auto database schema creation

### Planned (Frontend & AI Model) ⏳
- ⏳ User-friendly web interface
- ⏳ Real-time image preview
- ⏳ Disease detection using CNN
- ⏳ Treatment recommendations
- ⏳ Prediction history with filters
- ⏳ Statistics dashboard
- ⏳ User profiles (optional)

---

## 🚀 Getting Started

### Backend Setup (Java)
```bash
cd backend

# 1. Setup MySQL database
mysql -u root -p < database/setup.sql

# 2. Configure application.properties
# (Update database credentials)

# 3. Build project
mvn clean install

# 4. Run application
mvn spring-boot:run
```

**Backend runs on:** `http://localhost:8080`

### Frontend Setup (Coming Soon)
```bash
cd frontend
# Serve using Python HTTP server, VSCode Live Server, or similar
python -m http.server 8000
```

**Frontend runs on:** `http://localhost:8000`

### AI Model Setup (Coming Soon)
```bash
cd ai-model

# Install dependencies
pip install -r requirements.txt

# Run Flask API
python app.py
```

**AI API runs on:** `http://localhost:5000`

---

## 📊 Database Schema

### predictions Table
```sql
CREATE TABLE predictions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    disease VARCHAR(100) NOT NULL,
    confidence DOUBLE,
    solution LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_disease (disease),
    INDEX idx_created_at (created_at),
    INDEX idx_confidence (confidence)
);
```

---

## 🧪 Testing

### Test Backend
```bash
# Health check
curl http://localhost:8080/api/health

# Get history
curl http://localhost:8080/api/history

# Upload image
curl -X POST \
  -F "image=@sample_leaf.jpg" \
  http://localhost:8080/api/predict
```

---

## 📝 Project Phases

### Phase 1: Backend (✅ COMPLETED)
- [x] Spring Boot project setup
- [x] JPA entities and repository
- [x] REST API controllers
- [x] MySQL database integration
- [x] Image upload utility
- [x] Python AI API client
- [x] CORS configuration
- [x] Error handling
- [x] Documentation

### Phase 2: Frontend (⏳ IN PROGRESS)
- [ ] HTML pages structure
- [ ] CSS styling with Bootstrap
- [ ] JavaScript form handling
- [ ] Fetch API integration
- [ ] Image upload functionality
- [ ] Results display
- [ ] History management
- [ ] Responsive design

### Phase 3: AI Model (⏳ PENDING)
- [ ] Flask API setup
- [ ] CNN model training/loading
- [ ] Image preprocessing
- [ ] Disease prediction logic
- [ ] Treatment database
- [ ] Model evaluation

### Phase 4: Integration & Testing (⏳ PENDING)
- [ ] End-to-end testing
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Deployment preparation

---

## 🔐 Security Considerations

- ✅ File upload validation
- ✅ CORS enabled selectively
- ✅ Input validation
- [ ] Authentication (planned)
- [ ] Rate limiting (planned)
- [ ] SQL injection prevention (JPA)

---

## 📈 Performance Notes

- Image size limit: 10 MB
- Supported formats: JPG, JPEG, PNG, GIF, BMP
- Database indexed by disease and confidence
- Async processing recommended for batch predictions

---

## 📞 Support & Documentation

- **Backend README:** [backend/README.md](backend/README.md)
- **Quick Start:** [QUICKSTART_BACKEND.md](QUICKSTART_BACKEND.md)
- **Database Setup:** [backend/database/setup.sql](backend/database/setup.sql)

---

## 👥 Team & Credits

**Project:** Crop Disease Detection System
**Version:** 1.0.0
**Last Updated:** April 4, 2026

---

## 📄 License

This project is created for educational purposes.

---

## 🎉 Next Steps

1. ✅ Backend is ready - Test it!
2. ⏳ Create Frontend (HTML/CSS/JS)
3. ⏳ Build Python AI Model
4. ⏳ Integrate all components
5. ⏳ Deploy to production

---

**Ready to detect crop diseases? Let's grow smarter! 🌱**
