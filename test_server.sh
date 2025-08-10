#!/bin/bash

echo "🚀 Testing LunchboxAPI server at localhost:4000..."

# Test if server is responding
echo "📡 Checking if server is responding..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:4000 | grep -q "200"; then
    echo "✅ Server is responding with HTTP 200"
else
    echo "❌ Server is not responding properly"
    exit 1
fi

# Test the index page content
echo "📄 Checking index page content..."
response=$(curl -s http://localhost:4000)

if echo "$response" | grep -q "Phoenix"; then
    echo "✅ Phoenix branding found in page"
else
    echo "⚠️  Phoenix branding not found"
fi

if echo "$response" | grep -q "app.css"; then
    echo "✅ CSS file reference found"
else
    echo "⚠️  CSS file reference not found"
fi

if echo "$response" | grep -q "app.js"; then
    echo "✅ JavaScript file reference found"
else
    echo "⚠️  JavaScript file reference not found"
fi

# Test API endpoint
echo "🔌 Testing API endpoint..."
api_response=$(curl -s -u specialUserName:superSecretPassword http://localhost:4000/api/v1/foods)

if echo "$api_response" | grep -q '{"data":\[\]}'; then
    echo "✅ API endpoint responding correctly"
else
    echo "⚠️  API endpoint response: $api_response"
fi

# Test time endpoint
echo "⏰ Testing time endpoint..."
time_response=$(curl -s -u specialUserName:superSecretPassword http://localhost:4000/api/v1/time_now)

if echo "$time_response" | grep -q '"time"'; then
    echo "✅ Time endpoint responding correctly"
    echo "   Response: $time_response"
else
    echo "⚠️  Time endpoint not working properly"
fi

echo "🎉 Server test completed!"