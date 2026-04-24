"""
Simple Flask API stub for crop disease detection AI model
Returns mock predictions while the actual ML model is being trained
"""

from flask import Flask, request, jsonify
import json

app = Flask(__name__)

# Mock disease data for testing
MOCK_DISEASES = [
    {
        "disease": "Early Blight",
        "confidence": 92.5,
        "solution": "Apply copper-based fungicide spray every 7-10 days. Improve air circulation. Remove infected leaves. Maintain proper spacing between plants."
    },
    {
        "disease": "Late Blight",
        "confidence": 88.3,
        "solution": "Apply chlorothalonil or mancozeb fungicide. Remove infected plant parts. Keep plants dry. Avoid overhead watering. Improve ventilation."
    },
    {
        "disease": "Septoria Leaf Spot",
        "confidence": 85.7,
        "solution": "Remove infected leaves. Apply fungicide like chlorothalonil. Space plants adequately. Mulch to prevent spore splash. Avoid wetting leaves when watering."
    },
    {
        "disease": "Powdery Mildew",
        "confidence": 90.1,
        "solution": "Apply sulfur-based fungicide or neem oil. Increase air circulation. Remove infected parts. Water at soil level. Reduce humidity levels."
    },
    {
        "disease": "Healthy Leaf",
        "confidence": 95.2,
        "solution": "No treatment needed. Continue regular watering and fertilizer schedule. Monitor for any disease symptoms weekly."
    }
]

@app.route('/predict', methods=['POST'])
def predict():
    """
    Endpoint for disease prediction
    Accepts image file and returns mock disease prediction
    
    Returns:
        JSON: {
            "disease": "Disease name",
            "confidence": confidence_percentage,
            "solution": "Treatment solution"
        }
    """
    try:
        # Check if image file is provided
        if 'file' not in request.files and request.content_length == 0:
            return jsonify({
                "error": "No image provided"
            }), 400
        
        # In production, process the image here with ML model
        # For now, return mock prediction
        import random
        mock_prediction = random.choice(MOCK_DISEASES)
        
        print(f"📸 Received image for prediction")
        print(f"🤔 Processing... (mock)")
        print(f"✅ Prediction: {mock_prediction['disease']} ({mock_prediction['confidence']}%)")
        
        return jsonify(mock_prediction), 200
    
    except Exception as e:
        print(f"❌ Error in predict endpoint: {str(e)}")
        return jsonify({
            "error": f"Prediction failed: {str(e)}"
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "UP",
        "service": "Crop Disease Detection AI API",
        "version": "1.0.0"
    }), 200

@app.route('/info', methods=['GET'])
def info():
    """API information endpoint"""
    return jsonify({
        "service": "Crop Disease Detection AI API",
        "version": "1.0.0",
        "description": "AI model for detecting crop diseases from leaf images",
        "endpoint": "/predict (POST)",
        "status": "Mock mode - using sample predictions"
    }), 200

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🌾 Crop Disease Detection AI API Started")
    print("📍 Server running at http://localhost:5000")
    print("="*60 + "\n")
    app.run(debug=True, port=5000)
