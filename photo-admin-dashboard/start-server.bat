@echo off
echo ========================================
echo    Beimo 照片管理后台 - 本地服务器
echo ========================================
echo.

echo 正在启动本地服务器...
echo 服务器地址: http://localhost:8080
echo 按 Ctrl+C 停止服务器
echo.

REM 尝试使用 Python 启动服务器
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo 使用 Python 启动服务器...
    python -m http.server 8080
    goto :end
)

REM 尝试使用 Node.js 启动服务器
node --version >nul 2>&1
if %errorlevel% == 0 (
    echo 使用 Node.js 启动服务器...
    npx http-server -p 8080
    goto :end
)

REM 尝试使用 PHP 启动服务器
php --version >nul 2>&1
if %errorlevel% == 0 (
    echo 使用 PHP 启动服务器...
    php -S localhost:8080
    goto :end
)

echo 错误: 未找到 Python、Node.js 或 PHP
echo 请安装其中任意一个来启动本地服务器
echo 或者直接在浏览器中打开 index.html 文件
pause

:end
