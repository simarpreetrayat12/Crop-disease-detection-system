# 🌾 Crop Disease Detection System - Backend Documentation

## 📋 Project Overview

The backend is built using **Spring Boot** and serves as a bridge between the frontend and the Python AI model. It handles:
- Image upload from users
- Communication with Python AI API for disease prediction
- Storing predictions in MySQL database
- Providing REST APIs for the frontend

---

## 🏗️ Project Structure

```
backend/
├── pom.xml                              # Maven dependencies configuration
├── src/main/java/com/cropdetection/
│   ├── CropDiseaseDetectionApplication.java    # Main Spring Boot application
│   ├── config/
│   │   └── CorsConfig.java                     # CORS configuration for frontend
│   ├── controller/
│   │   ├── PredictionController.java           # REST API endpoints
│   │   └── dto/
│   │       ├── PredictionRequest.java          # DTO for AI response
│   │       └── PredictionResponse.java         # DTO for API response
│   ├── entity/
│   │   └── Prediction.java                     # JPA entity (database model)
│   ├── repository/
│   │   └── PredictionRepository.java           # Data access layer
│   ├── service/
│   │   └── PredictionService.java              # Business logic layer
│   └── util/
│       ├── ImageUploadUtil.java                # Image upload handling
│       └── PythonAIClient.java                 # Python API communication
│
├── src/main/resources/
│   └── application.properties                  # Spring Boot configuration
│
├── uploads/                                     # Directory for storing uploaded images
│
└── database/
    └── setup.sql                               # Database initialization script
```

---

## 🚀 Getting Started

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+
- Python (for AI API)
- Git

### Installation & Setup

#### 1. **Clone/Download the Project**
```bash
cd backend
```

#### 2. **Setup MySQL Database**
```bash
# Open MySQL shell
mysql -u root -p

# Run the setup script
source database/setup.sql

# Or manually create:
CREATE DATABASE crop_disease_db;
```

#### 3. **Configure Database Connection**
Edit `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/crop_disease_db
spring.datasource.username=root
spring.datasource.password=your_password
```

#### 4. **Build the Project**
```bash
mvn clean install
```

#### 5. **Run the Application**
```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

---

## 📡 REST API Endpoints

### 1. **POST /api/predict**
Upload an image and get disease prediction.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Parameter: `image` (MultipartFile)

**Example using cURL:**
```bash
curl -X POST \
  -F "image=@/path/to/leaf.jpg" \
  http://localhost:8080/api/predict
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Disease prediction successful",
  "data": {
    "id": 1,
    "imagePath": "uploads/c1a2b3c4-d5e6-f7g8-h9i0-j1k2l3m4n5o6.jpg",
    "disease": "Early Blight",
    "confidence": 92.5,
    "solution": "Apply copper-based fungicide spray...",
    "createdAt": "2026-04-04 10:30:45"
  }
}
```

---

### 2. **GET /api/history**
Retrieve all predictions (latest first).

**Request:**
- Method: GET

**Example:**
```bash
curl http://localhost:8080/api/history
```

**Response:**
```json
{
  "success": true,
  "message": "Predictions retrieved successfully",
  "total": 5,
  "data": [
    {
      "id": 5,
      "imagePath": "uploads/...",
      "disease": "Powdery Mildew",
      "confidence": 88.3,
      "solution": "...",
      "createdAt": "2026-04-04 14:20:10"
    },
    ...
  ]
}
```

---

### 3. **GET /api/history/disease?disease=Early%20Blight**
Get predictions for a specific disease.

**Request:**
```bash
curl "http://localhost:8080/api/history/disease?disease=Early%20Blight"
```

---

### 4. **GET /api/history/confidence?minConfidence=85**
Get predictions with confidence >= threshold.

**Request:**
```bash
curl "http://localhost:8080/api/history/confidence?minConfidence=85"
```

---

### 5. **GET /api/health**
Health check endpoint.

**Request:**
```bash
curl http://localhost:8080/api/health
```

**Response:**
```json
{
  "status": "UP",
  "service": "Crop Disease Detection API",
  "totalPredictions": 5
}
```

---

### 6. **GET /api/info**
Get API documentation and endpoints.

**Request:**
```bash
curl http://localhost:8080/api/info
```

---

## 🗄️ Database Schema

### predictions table
```sql
+-----------+-------------+------+-----+---------+----------------+
| Field     | Type        | Null | Key | Default | Extra          |
+-----------+-------------+------+-----+---------+----------------+
| id        | BIGINT      | NO   | PRI | NULL    | auto_increment |
| image_path| VARCHAR(255)| NO   |     | NULL    |                |
| disease   | VARCHAR(100)| NO   | MUL | NULL    |                |
| confidence| DOUBLE      | YES  | MUL | NULL    |                |
| solution  | LONGTEXT    | YES  |     | NULL    |                |
| created_at| TIMESTAMP   | NO   | MUL | CURRENT |                |
+-----------+-------------+------+-----+---------+----------------+
```

---

## 🔌 Integration with Python AI API

The backend communicates with Python AI API at `http://localhost:5000/predict`.

### Expected Python API Response Format:
```json
{
  "disease": "Leaf Spot",
  "confidence": 90,
  "solution": "Use fungicide spray every 7-10 days"
}
```

### Configuration:
Update `app.ai.api.url` in `application.properties`:
```properties
app.ai.api.url=http://localhost:5000
```

---

## 📁 Image Upload

- **Upload Directory:** `uploads/`
- **Supported Formats:** JPG, JPEG, PNG, GIF, BMP
- **Max File Size:** 10 MB
- **File Naming:** Images are renamed with UUID to prevent conflicts

### Example:
```
uploads/
├── c1a2b3c4-d5e6-f7g8-h9i0-j1k2l3m4n5o6.jpg
├── a2b3c4d5-e6f7-g8h9-i0j1-k2l3m4n5o6p7.png
└── ...
```

---

## 🧠 Class Descriptions

### Entity Layer
**Prediction.java** - JPA Entity representing a prediction record in database
- Uses `@Entity` and `@Table` annotations
- Auto-generates timestamps with `@PrePersist`

### Repository Layer
**PredictionRepository.java** - Spring Data JPA repository
- Extends `JpaRepository<Prediction, Long>`
- Provides CRUD + custom query methods

### Service Layer
**PredictionService.java** - Business logic
- Handles image upload validation
- Calls Python AI API for prediction
- Saves prediction to database
- Converts entities to DTOs

### Controller Layer
**PredictionController.java** - REST API endpoints
- Handles HTTP requests/responses
- Error handling and validation
- CORS enabled

### Utility Classes
- **ImageUploadUtil.java** - Manages file upload, validation, storage
- **PythonAIClient.java** - HTTP client for Python API communication

---

## ⚙️ Configuration

### application.properties
```properties
# Server
server.port=8080

# Database
spring.datasource.url=jdbc:mysql://localhost:3306/crop_disease_db
spring.datasource.username=root
spring.datasource.password=root123

# JPA
spring.jpa.hibernate.ddl-auto=update

# AI API
app.ai.api.url=http://localhost:5000

# Upload
app.upload.dir=uploads
```

---

## 🔍 Troubleshooting

### Issue: "unable to connect to database"
- Ensure MySQL is running
- Check database credentials in `application.properties`
- Verify database exists: `CREATE DATABASE crop_disease_db;`

### Issue: "Python AI API not found"
- Ensure Python Flask API is running on `http://localhost:5000`
- Update `app.ai.api.url` in properties
- Backend will use mock predictions if API unavailable

### Issue: "Image upload fails"
- Check `uploads/` directory exists and is writable
- Verify file size < 10 MB
- Ensure file format is supported (jpg, png, gif, bmp)

---

## 📊 Future Enhancements

- [ ] User authentication and authorization
- [ ] API rate limiting
- [ ] Image preprocessing before sending to AI
- [ ] Support for batch predictions
- [ ] Advanced filtering and searching
- [ ] Export predictions as CSV/PDF
- [ ] Age of predictions statistics
- [ ] Disease statistics dashboard

---

## 📝 Notes

- **Mock Prediction:** When Python API unavailable, mock prediction is returned for testing
- **Auto Database Migration:** Hibernate is configured with `ddl-auto=update`
- **CORS Enabled:** Frontend can make requests from any origin
- **Logging:** Debug logs at `com.cropdetection` level

---

## 📞 Support

For issues or questions, refer to the main project documentation or contact the development team.

---

**Version:** 1.0.0  
**Last Updated:** April 4, 2026
