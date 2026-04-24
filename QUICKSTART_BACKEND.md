# 🚀 Quick Start Guide - Backend

## Prerequisites
- Java 17+
- Maven 3.6+
- MySQL 8.0+

## Step 1: Setup Database

```bash
# Open MySQL
mysql -u root -p

# Create database
CREATE DATABASE crop_disease_db;

# Exit MySQL
exit
```

## Step 2: Configure Database Connection

Edit `src/main/resources/application.properties`:
```properties
spring.datasource.username=root
spring.datasource.password=your_password
```

## Step 3: Build Project

```bash
mvn clean install
```

## Step 4: Run Application

```bash
mvn spring-boot:run
```

Server starts on: **http://localhost:8080**

## Step 5: Test API

```bash
# Health check
curl http://localhost:8080/api/health

# Get API info
curl http://localhost:8080/api/info

# Get prediction history
curl http://localhost:8080/api/history
```

## Upload Test Image

```bash
curl -X POST \
  -F "image=@sample_leaf.jpg" \
  http://localhost:8080/api/predict
```

---

## 📡 Key Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/predict` | Upload image & predict disease |
| GET | `/api/history` | Get all predictions |
| GET | `/api/health` | Health check |
| GET | `/api/info` | API documentation |

---

## 🐛 Troubleshooting

**Database connection error?**
- Ensure MySQL is running
- Check credentials in `application.properties`

**Port already in use?**
- Change in `application.properties`: `server.port=8081`

**Maven build fails?**
- Install Java 17: `java -version`
- Update Maven: `mvn -v`

---

Next Step: Create Python AI API & Frontend
