$url = "https://tycpgjpjxzoxtwpzinpj.supabase.co/rest/v1"
$headers = @{
    "apikey" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y3BnanBqeHpveHR3cHppbnBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTQ0NzYsImV4cCI6MjA5NTM3MDQ3Nn0.3I-MZPmAz_DStBH5PyfTE727l8IhNjlNYxj3wGXgrT4"
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y3BnanBqeHpveHR3cHppbnBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTQ0NzYsImV4cCI6MjA5NTM3MDQ3Nn0.3I-MZPmAz_DStBH5PyfTE727l8IhNjlNYxj3wGXgrT4"
}

Write-Host "1. Deleting all stock rows..."
try {
    Invoke-RestMethod -Uri "$url/stock?id=neq.00000000-0000-0000-0000-000000000000" -Method Delete -Headers $headers
    Write-Host "Success!"
} catch {
    Write-Host "Error deleting stock: $_"
}

Write-Host "2. Deleting all parts rows..."
try {
    Invoke-RestMethod -Uri "$url/parts?id=neq.00000000-0000-0000-0000-000000000000" -Method Delete -Headers $headers
    Write-Host "Success!"
} catch {
    Write-Host "Error deleting parts: $_"
}

Write-Host "3. Deleting all pieces rows..."
try {
    Invoke-RestMethod -Uri "$url/pieces?id=neq.0" -Method Delete -Headers $headers
    Write-Host "Success!"
} catch {
    Write-Host "Error deleting pieces: $_"
}

Write-Host "Demo data clean up completed!"
