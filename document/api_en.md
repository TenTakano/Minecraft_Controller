FORMAT: 1A

# MinecraftControllerAPI list

This is an API spec document of MinecraftController

- All APIs except Login API and API for test (Get Version API) requires API Token for Authorization header.
    - Login API generates API Token.
    - API Token will expire if it exceeds the period set on the server side. Then, you need to log in again.
    - If the request with invalid API Token or without Authorization header comes, APIs return BadRequest.

# Group User

## Login [POST /api/users/login]

- Execute log in sequence and publish API Token as a response.

- Request (application/json)
    - Attributes
        - `id`: `user_name` (string, required) - Login ID
        - `password`: `password` (string, required) - Password

- Response 200 (application/json)
    - Attributes
        - `token`: `sometoken` (string, required) - API Token. This is used for Authorization headers of APIs which requires user authorization.

# Group Minecraft Server

## Start Server [GET /api/ec2/start]

- Starts the EC2 instance for Minecraft server.
    - This API takes 20-30 seconds to response because it waits the EC2 instance starts.
    - This API judges the completion by launching the EC2 instance. Thus, the API doesn't care wheather Minecraft server starts or not.

- Request
    - Headers

            authorization: some_api_token

- Response 200
    - Attributes
        - `ip`: `123.123.123.123` (string, required) - IP address of Minecraft server.

# Group Others

## Get MinecraftController Version [GET /api/version]

- Gets MinecraftController version. This API is deprecated because it's for testing. It will be removed in the future.

- Response 200
    - Attributes
        - `version`: `0.1.0` (string, required) - Version of MinecraftController
