# 手动测试搜索API
Write-Host "🔍 测试搜索API..." -ForegroundColor Green

$headers = @{
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbF9pZCI6IiIsImZpcnN0X25hbWUiOiIiLCJsYXN0X25hbWUiOiIiLCJkZXZpY2VfdG9rZW4iOiIiLCJvbmVfc2lnbmFsX3BsYXllcl9pZCI6IiIsInVzZXJfbmFtZSI6IiIsImJpbyI6IkF2YWlsYWJsZSIsImRvYiI6IiIsInBhc3N3b3JkIjoiIiwibGFzdF9zZWVuIjowLCJnZW5kZXIiOiIiLCJwcm9maWxlX2ltYWdlIjoiIiwiQmxvY2tlZF9ieV9hZG1pbiI6ZmFsc2UsInZpZXdlZF9ieV9hZG1pbiI6ZmFsc2UsImF2YXRhcl9pZCI6MCwiaXNfYWNjb3VudF9kZWxldGVkIjpmYWxzZSwiaXNfbW9iaWxlIjpmYWxzZSwiaXNfd2ViIjpmYWxzZSwidXNlcl9pZCI6MiwicGhvbmVfbnVtYmVyIjoiMTExMTExMSIsIm90cCI6MTIzNDU2LCJjb3VudHJ5X2NvZGUiOiIrMSIsImNvdW50cnkiOiJVUyIsImNvdW50cnlfZnVsbF9uYW1lIjoiVW5pdGVkIFN0YXRlcyIsInVwZGF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImNyZWF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImlhdCI6MTc1ODM0MDI2MH0.AbHOETnBqKrHkKdkgvp8HbO8kxE_5-u4hFKxLLDvPc8'
    'Content-Type' = 'application/json'
}

$body = @{
    user_name = 'qwe'
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri 'http://195.86.16.16:3000/api/search-user' -Method Post -Headers $headers -Body $body
    Write-Host "✅ 搜索API测试成功!" -ForegroundColor Green
    Write-Host "响应数据:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ 搜索API测试失败:" -ForegroundColor Red
    Write-Host "错误信息: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "响应内容: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n按任意键继续..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
