@echo off
echo 上传修复文件到VPS...

echo 上传 AuthRoutes.js...
scp whoxa_vps\whoxa\routes\AuthRoutes.js root@195.86.16.16:/root/whoxa/routes/

echo 上传 searchUser.js (修复Block字段问题)...
scp whoxa_vps\whoxa\controller\user\searchUser.js root@195.86.16.16:/root/whoxa/controller/user/

echo 重启后端服务...
ssh root@195.86.16.16 "cd /root/whoxa && pm2 restart 0"

echo 等待服务重启...
timeout /t 3

echo 测试搜索API...
node test_search_simplified.js

echo 修复完成！
pause
