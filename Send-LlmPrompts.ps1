<#
.SYNOPSIS
    Script that sends prompts to Large Language Models via Substrate LLM API.

    Alternative approaches to get an access token:

    [Option 1] Use azure cli
        az login
        $accessToken = (az account get-access-token | ConvertFrom-Json).AccessToken

    [Option 2] Use MSAL.PS module (https://github.com/AzureAD/MSAL.PS)
        $accessToken = (Get-MsalToken -ClientId 68df66a4-cad9-4bfd-872b-c6ddde00d6b2 `
            -Authority https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47 `
            -Scopes api://68df66a4-cad9-4bfd-872b-c6ddde00d6b2/access).AccessToken

.EXAMPLE
    .\Send-LlmPrompt.ps1 -Prompts @("Once upon a time, a little boy")

    Using the default 'text-davinci-003' model. This will prompt the caller for authentication.

.EXAMPLE
    .\Send-LlmPrompt.ps1 -Prompts @("Who is the fastest person on earth?") -Model 'text-chat-davinci-002'
    
    Asking a question to ChatGPT model.

.EXAMPLE
    .\Send-LlmPrompt.ps1 -Prompts @("Who is the fastest person on earth?") -AccessToken $accessToken
    
    Providing an authentication token, which can be retrieved using the another script:
    PS C:\> $accessToken = .\Get-AccessTokenViaDeviceFlow.ps1
#>
param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Model = "text-chat-davinci-002",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxTokens = 400,

    [Parameter(Mandatory=$false)]
    [int]$N = 1,

    [Parameter(Mandatory=$false)]
    [float]$Temperature = 0.5,

    [Parameter(Mandatory=$false)]
    [float]$TopP = 0.5,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Prompts,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$AccessToken
)

$AccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiI2OGRmNjZhNC1jYWQ5LTRiZmQtODcyYi1jNmRkZGUwMGQ2YjIiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vNzJmOTg4YmYtODZmMS00MWFmLTkxYWItMmQ3Y2QwMTFkYjQ3L3YyLjAiLCJpYXQiOjE2NzY0NDMwMDksIm5iZiI6MTY3NjQ0MzAwOSwiZXhwIjoxNjc2NDQ4MDU3LCJhaW8iOiJBV1FBbS84VEFBQUFTTjBKVTJTL2dXbUZmWUVUQjUyMzdHRExYa2UyeWgya1krU3cyUFltWmdWWWM5NTZtMWdoVktiYVJDMHJhcjAyVHkzTEZodzdiTEZ6bTF0bTRzc2U1ZlIwaHVWUitBUE5VZG5yUWhtZ3VLQ3dTaHBmV0ZrTDA0Mlh5NnpuQUtjbyIsImF6cCI6IjY4ZGY2NmE0LWNhZDktNGJmZC04NzJiLWM2ZGRkZTAwZDZiMiIsImF6cGFjciI6IjAiLCJlbWFpbCI6Inl1YW5oYW90dUBtaWNyb3NvZnQuY29tIiwibmFtZSI6Ill1YW5oYW8gVHUiLCJvaWQiOiIyOGY4ZGE0YS1kMWYzLTRiYjUtYjkxMi0zZDNiMDAwZTVhMzIiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJ5dWFuaGFvdHVAbWljcm9zb2Z0LmNvbSIsInJoIjoiMC5BUm9BdjRqNWN2R0dyMEdScXkxODBCSGJSNlJtMzJqWnl2MUxoeXZHM2Q0QTFySWFBRFEuIiwic2NwIjoiYWNjZXNzIiwic3ViIjoiY0h5Z0x1ZnJzbnlkS05XM0YzY0NjODM2X2RUT0lYLWJXc2tab2ZfWTB4VSIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6IlhjNTY2aHNrYVVpWXRZSzlXMEFTQUEiLCJ2ZXIiOiIyLjAiLCJ2ZXJpZmllZF9wcmltYXJ5X2VtYWlsIjpbInl1YW5oYW90dUBtaWNyb3NvZnQuY29tIl19.f2E_T3gHdtGGBMsYZC087kVlqV3KqSCB96HWNf5iIegf5WSqH6JheRENJiK9_kodtTfyq6YViifQMrCNJTiXZEkfpaM90DunrsliCLRO4MOSrMo_lDNz5e_B4C7MAxVuT5UH8RmENOeu7L3-7X2iVa6PqLfsaXOFCWkDmGGC9WnS7EgOMQnhmF7KZCvc8uFNIkzJA3cuXYLH7VaTEUOnxDGLccaTPX3YQH1L7JF1s9LGPsRN_93ZXOqKW0GPGQLamOm8TspSdxGGGNcQzOEZVW52C23UL6Om1YsH8un_pdrw88VeBBlSrJ077_QSEXSsqJAJ6tzklb2yxmU6dZczdw"


$endpoint = "https://httpqas26-frontend-qasazap-prod-dsm02p.qas.binginternal.com/completions"

echo $AccessToken

$headers = @{    
    Authorization="Bearer $AccessToken"    
    "Content-Type"='application/json'
    "X-AppName"='PowerShell'
    "X-ModelType"=$Model
    "X-RequestId"=[Guid]::NewGuid().ToString()
}

$body = @{
    prompt = $Prompts
    max_tokens = $MaxTokens
    temperature = $Temperature
    top_p = $TopP
    n = $N
    stream = $false
    logprobs = $null
    stop = $null
}

$jsonPayload = ConvertTo-Json $body
Write-Host -ForegroundColor Yellow "POST $endpoint"
$headers.Keys | %{ if ($_ -eq "Authorization") { Write-Host "Authorization: Bearer (...)" } else { Write-Host "$($_): $($headers.$_)" }}
Write-Host $jsonPayload

Write-Host -ForegroundColor Yellow "Response:"
Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body $jsonPayload