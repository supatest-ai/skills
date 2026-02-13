# API Documentation Generator

Generate comprehensive API documentation from code, including OpenAPI specs, endpoint descriptions, and usage examples.

## When to use this skill

Use this skill when you need to:
- Document API endpoints
- Generate OpenAPI/Swagger specs
- Create API reference documentation
- Document request/response formats
- Provide usage examples for APIs
- Update existing API docs

## Instructions

When the user invokes this skill:

1. **Identify API Code**
   - Ask for specific files/routes if not provided
   - Look for common API patterns:
     - Express/Fastify routes
     - REST controllers
     - GraphQL schemas
     - tRPC procedures
   - Search for route definitions: `grep -r "router\." src/` or similar

2. **Analyze Each Endpoint**
   For each API endpoint, extract:
   - **HTTP Method**: GET, POST, PUT, PATCH, DELETE
   - **Path**: URL path with parameters
   - **Description**: What the endpoint does
   - **Authentication**: Required auth method
   - **Authorization**: Required permissions/roles
   - **Request**:
     - Path parameters
     - Query parameters
     - Request body schema
     - Headers required
   - **Response**:
     - Success responses (200, 201, etc.)
     - Error responses (400, 401, 404, 500, etc.)
     - Response body schema
   - **Examples**: Request/response examples

3. **Extract Type Information**
   - Read TypeScript interfaces/types
   - Parse validation schemas (Zod, Yup, Joi, etc.)
   - Identify required vs optional fields
   - Note data types and formats
   - Extract enum values

4. **Generate Documentation**

   **Format 1: Markdown API Reference**
   ```markdown
   # API Reference

   ## Authentication
   [Description of auth method]

   ## Endpoints

   ### Create User
   `POST /api/users`

   Creates a new user account.

   **Authentication**: Required
   **Authorization**: None

   **Request Body**
   ```json
   {
     "email": "string (required)",
     "name": "string (required)",
     "role": "admin | user (optional, default: user)"
   }
   ```

   **Success Response** (201 Created)
   ```json
   {
     "id": "string",
     "email": "string",
     "name": "string",
     "role": "string",
     "createdAt": "string (ISO 8601)"
   }
   ```

   **Error Responses**
   - `400 Bad Request`: Invalid input
   - `409 Conflict`: Email already exists
   - `500 Internal Server Error`: Server error

   **Example**
   ```bash
   curl -X POST https://api.example.com/users \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <token>" \
     -d '{
       "email": "user@example.com",
       "name": "John Doe",
       "role": "user"
     }'
   ```
   ```

   **Format 2: OpenAPI 3.0 Spec**
   Generate a complete OpenAPI specification:
   ```yaml
   openapi: 3.0.0
   info:
     title: [API Name]
     version: 1.0.0
     description: [API Description]

   servers:
     - url: https://api.example.com/v1

   paths:
     /users:
       post:
         summary: Create a new user
         operationId: createUser
         tags:
           - Users
         security:
           - bearerAuth: []
         requestBody:
           required: true
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/CreateUserRequest'
         responses:
           '201':
             description: User created successfully
             content:
               application/json:
                 schema:
                   $ref: '#/components/schemas/User'
           '400':
             $ref: '#/components/responses/BadRequest'
           '409':
             $ref: '#/components/responses/Conflict'

   components:
     schemas:
       CreateUserRequest:
         type: object
         required:
           - email
           - name
         properties:
           email:
             type: string
             format: email
           name:
             type: string
           role:
             type: string
             enum: [admin, user]
             default: user

       User:
         type: object
         properties:
           id:
             type: string
             format: uuid
           email:
             type: string
             format: email
           name:
             type: string
           role:
             type: string
           createdAt:
             type: string
             format: date-time

     securitySchemes:
       bearerAuth:
         type: http
         scheme: bearer
         bearerFormat: JWT

     responses:
       BadRequest:
         description: Invalid request
         content:
           application/json:
             schema:
               type: object
               properties:
                 error:
                   type: string
   ```

5. **Organization**
   Group endpoints logically:
   - By resource (Users, Posts, Comments)
   - By feature (Authentication, Payments)
   - By version (v1, v2)

6. **Additional Information**
   Include:
   - **Rate Limiting**: Request limits if applicable
   - **Pagination**: How pagination works
   - **Filtering & Sorting**: Query parameter patterns
   - **Versioning**: API version strategy
   - **Webhooks**: If supported
   - **SDKs**: Available client libraries
   - **Common Errors**: Standard error format

7. **Usage Examples**
   Provide examples in multiple formats:
   - cURL commands
   - JavaScript/TypeScript (fetch, axios)
   - Python (requests)
   - Code snippets for SDKs

8. **Interactive Elements**
   Suggest:
   - Swagger UI setup for interactive docs
   - Postman collection export
   - API playground setup

## Examples

### Example 1: Document Express API
```
User: "Document the API endpoints in src/api/users.ts"

You: Read the file and respond with:

# Users API Documentation

## Overview
API endpoints for managing user accounts.

**Base URL**: `/api/v1/users`
**Authentication**: Bearer token required for all endpoints

## Endpoints

### List Users
`GET /api/v1/users`

Retrieve a paginated list of users.

**Query Parameters**
- `page` (number, optional): Page number (default: 1)
- `limit` (number, optional): Items per page (default: 20, max: 100)
- `role` (string, optional): Filter by role ('admin' | 'user')
- `search` (string, optional): Search by name or email

**Response** (200 OK)
```json
{
  "users": [
    {
      "id": "123",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

**Example Request**
```bash
curl "https://api.example.com/v1/users?page=1&limit=20&role=user" \
  -H "Authorization: Bearer <token>"
```

[... more endpoints ...]
```

### Example 2: Generate OpenAPI Spec
```
User: "Generate an OpenAPI spec for the entire API in src/api/"

You: Analyze all API files and generate a complete OpenAPI 3.0 specification with all endpoints, schemas, and examples.
```

### Example 3: Update Existing Docs
```
User: "Update the API docs to include the new search endpoint"

You:
1. Read existing documentation
2. Analyze new search endpoint code
3. Add documentation in the same style/format
4. Update table of contents if applicable
```

## Tips

- **Be thorough but concise**: Include all necessary info without overwhelming
- **Use real examples**: Actual request/response data helps understanding
- **Document errors well**: Error cases are often forgotten but crucial
- **Keep it up to date**: Suggest adding doc generation to CI/CD
- **Link to types**: Reference TypeScript types/interfaces when possible
- **Show the happy path first**: Success case before edge cases
- **Include business logic**: Explain what happens, not just the API shape
- **Note breaking changes**: Call out if anything changes between versions
- **Provide context**: Explain when and why to use each endpoint
- **Use consistent formatting**: Same style throughout all docs

## Integration Points

- **TypeScript**: Extract types directly from code
- **Validation Libraries**: Parse Zod/Yup/Joi schemas
- **OpenAPI Tools**: Suggest swagger-jsdoc or similar
- **Testing**: Link to example tests that show usage
- **Postman**: Offer to generate Postman collection

## Notes

- For large APIs, break documentation into multiple files
- Consider auto-generating docs from code comments (TSDoc/JSDoc)
- Keep examples updated when schemas change
- Include versioning information prominently
- Provide both reference docs (detailed) and guides (tutorials)
- Consider generating docs automatically in CI/CD pipeline
- If API uses GraphQL, adjust format accordingly
- For webhook endpoints, document payload formats and retry logic
