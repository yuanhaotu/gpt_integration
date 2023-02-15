$device_code_response = Invoke-WebRequest -Method POST `
-Uri https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47/oauth2/v2.0/devicecode `
-Headers @{ "Content-Type"='application/x-www-form-urlencoded' } `
-Body "client_id=68df66a4-cad9-4bfd-872b-c6ddde00d6b2&scope=api%3A%2F%2F68df66a4-cad9-4bfd-872b-c6ddde00d6b2%2Faccess"

$response_content = $device_code_response.Content | ConvertFrom-Json

Write-Host -ForegroundColor Yellow $response_content.message
Write-Warning "Complete the device code authorization before proceeding!"
PAUSE

$token_response = Invoke-WebRequest -Method POST `
-Uri https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47/oauth2/v2.0/token `
-Headers @{ "Content-Type"='application/x-www-form-urlencoded' } `
-Body "grant_type=urn:ietf:params:oauth:grant-type:device_code&client_id=68df66a4-cad9-4bfd-872b-c6ddde00d6b2&device_code=$($response_content.device_code)"

return ($token_response.Content | ConvertFrom-Json).access_token