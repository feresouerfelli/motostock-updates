$url = "https://tycpgjpjxzoxtwpzinpj.supabase.co/rest/v1"
$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y3BnanBqeHpveHR3cHppbnBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTQ0NzYsImV4cCI6MjA5NTM3MDQ3Nn0.3I-MZPmAz_DStBH5PyfTE727l8IhNjlNYxj3wGXgrT4"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y3BnanBqeHpveHR3cHppbnBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTQ0NzYsImV4cCI6MjA5NTM3MDQ3Nn0.3I-MZPmAz_DStBH5PyfTE727l8IhNjlNYxj3wGXgrT4"
}

Write-Host "Testing connection to parts table..."
try {
    $res = Invoke-RestMethod -Uri "$url/parts?select=*,stock(*)" -Method Get -Headers $headers
    Write-Host "parts table exists! Count: $($res.Count)"
    $res | ConvertTo-Json
} catch {
    Write-Host "Error parts: $_"
}

Write-Host "Testing connection to pieces table..."
try {
    $res = Invoke-RestMethod -Uri "$url/pieces?select=*" -Method Get -Headers $headers
    Write-Host "pieces table exists! Count: $($res.Count)"
} catch {
    Write-Host "Error pieces: $_"
}

Write-Host "Testing connection to stock table..."
try {
    $res = Invoke-RestMethod -Uri "$url/stock?select=*" -Method Get -Headers $headers
    Write-Host "stock table exists! Count: $($res.Count)"
    $res | ConvertTo-Json
} catch {
    Write-Host "Error stock: $_"
}
