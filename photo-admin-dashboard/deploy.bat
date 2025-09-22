@echo off
echo ========================================
echo    Beimo 照片管理后台 - 一键部署到VPS
echo ========================================
echo.

set VPS_IP=195.86.16.16
set VPS_USER=root
set VPS_PATH=/var/www/whoxa

echo 正在部署到 VPS: %VPS_USER%@%VPS_IP%
echo.

echo [1/6] 创建VPS目录结构...
ssh %VPS_USER%@%VPS_IP% "cd %VPS_PATH% && mkdir -p admin && mkdir -p admin/css && mkdir -p admin/js && mkdir -p admin/images"

echo [2/6] 上传前端文件...
scp index.html %VPS_USER%@%VPS_IP%:%VPS_PATH%/admin/
scp guide.html %VPS_USER%@%VPS_IP%:%VPS_PATH%/admin/
scp config.json %VPS_USER%@%VPS_IP%:%VPS_PATH%/admin/

echo [3/6] 上传CSS和JS文件...
scp css/style.css %VPS_USER%@%VPS_IP%:%VPS_PATH%/admin/css/
scp js/app.js %VPS_USER%@%VPS_IP%:%VPS_PATH%/admin/js/

echo [4/6] 上传后端控制器...
scp server/photoAdminController.js %VPS_USER%@%VPS_IP%:%VPS_PATH%/controller/Admin/
scp server/photoAdminRoutes.js %VPS_USER%@%VPS_IP%:%VPS_PATH%/routes/

echo [5/6] 设置文件权限...
ssh %VPS_USER%@%VPS_IP% "cd %VPS_PATH% && chmod -R 755 admin && chmod -R 755 uploads"

echo [6/6] 重启服务...
ssh %VPS_USER%@%VPS_IP% "cd %VPS_PATH% && pm2 restart all"

echo.
echo ========================================
echo 部署完成！
echo.
echo 管理后台地址: http://%VPS_IP%:3000/admin/
echo API健康检查: http://%VPS_IP%:3000/api/admin/health
echo.
echo 请手动完成以下步骤：
echo 1. 在 routes/AuthRoutes.js 中添加管理系统路由
echo 2. 在 app.js 中添加静态文件服务配置
echo 3. 重启PM2服务
echo ========================================

pause
