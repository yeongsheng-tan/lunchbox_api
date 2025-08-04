# Authentication System

This application uses JWT authentication with GitHub OAuth for `/api/*` endpoints.

## Overview

- **JWT Authentication**: Secure token-based authentication
- **GitHub OAuth**: Login with GitHub account only
- **Protected Routes**: API endpoints require valid JWT tokens

## Environment Variables

Set these environment variables for OAuth configuration:

```bash
# JWT Secret (change in production)
export JWT_SECRET="your-super-secret-jwt-key"

# GitHub OAuth
export GITHUB_CLIENT_ID="your-github-client-id"
export GITHUB_CLIENT_SECRET="your-github-client-secret"
export GITHUB_REDIRECT_URI="http://localhost:4000/auth/github/callback"
```

## Authentication Flow

### GitHub OAuth
```bash
# Start OAuth flow
curl -X GET http://localhost:4000/auth/github

# After GitHub redirects back, you'll get a JWT token
# Use this token for API requests
```

### Using JWT Token for API Requests

```bash
# Get the token from OAuth callback response
TOKEN="your-jwt-token-here"

# Use token for API requests
curl -X GET \
  http://localhost:4000/api/v1/foods \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Create food
curl -X POST \
  http://localhost:4000/api/v1/foods \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"food": {"name": "Pizza", "status": "available"}}'

# Update food
curl -X PUT \
  http://localhost:4000/api/v1/foods/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"food": {"name": "Updated Pizza", "status": "sold"}}'

# Delete food
curl -X DELETE \
  http://localhost:4000/api/v1/foods/1 \
  -H "Authorization: Bearer $TOKEN"
```

## Testing

Run the authentication tests:

```bash
# Run all tests
mix test

# Run specific authentication tests
mix test test/lunchbox_api_web/auth/
mix test test/lunchbox_api_web/controllers/auth_controller_test.exs
mix test test/lunchbox_api_web/controllers/food_controller_test.exs
```

## Security Features

1. **JWT Token Validation**: All protected routes validate JWT tokens
2. **OAuth Integration**: Secure authentication via GitHub
3. **Token Expiration**: JWT tokens expire after 7 days
4. **Protected Routes**: API endpoints require authentication
5. **Error Handling**: Proper error responses for invalid tokens

## API Endpoints

### Public Endpoints
- `GET /` - Home page
- `GET /auth/github` - GitHub OAuth login
- `GET /auth/github/callback` - GitHub OAuth callback
- `POST /auth/logout` - Logout

### Protected Endpoints (require JWT token)
- `GET /api/v1/foods` - List foods
- `POST /api/v1/foods` - Create food
- `GET /api/v1/foods/:id` - Get food
- `PUT /api/v1/foods/:id` - Update food
- `DELETE /api/v1/foods/:id` - Delete food
- `GET /dashboard` - Phoenix LiveDashboard (dev/test only)