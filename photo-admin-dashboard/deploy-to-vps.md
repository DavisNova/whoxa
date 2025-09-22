# VPS 部署指南

## 1. 将管理系统上传到VPS

### 上传文件到VPS
```bash
# 在VPS上创建管理系统目录
ssh root@195.86.16.16
cd /var/www/whoxa
mkdir -p admin
```

### 本地上传命令
```bash
# 上传前端文件
scp -r photo-admin-dashboard/index.html root@195.86.16.16:/var/www/whoxa/admin/
scp -r photo-admin-dashboard/guide.html root@195.86.16.16:/var/www/whoxa/admin/
scp -r photo-admin-dashboard/css root@195.86.16.16:/var/www/whoxa/admin/
scp -r photo-admin-dashboard/js root@195.86.16.16:/var/www/whoxa/admin/
scp -r photo-admin-dashboard/images root@195.86.16.16:/var/www/whoxa/admin/
scp -r photo-admin-dashboard/config.json root@195.86.16.16:/var/www/whoxa/admin/

# 上传后端控制器和路由
scp photo-admin-dashboard/server/photoAdminController.js root@195.86.16.16:/var/www/whoxa/controller/Admin/
scp photo-admin-dashboard/server/photoAdminRoutes.js root@195.86.16.16:/var/www/whoxa/routes/
```

## 2. 在VPS上集成API路由

### 修改主路由文件
```bash
# 在VPS上编辑路由文件
ssh root@195.86.16.16
cd /var/www/whoxa
nano routes/AuthRoutes.js
```

### 添加管理系统路由
在 `routes/AuthRoutes.js` 文件末尾添加：
```javascript
// 照片管理系统路由
const photoAdminRoutes = require('./photoAdminRoutes');
router.use('/api', photoAdminRoutes);
```

## 3. 配置静态文件服务

### 修改主应用文件
```bash
# 编辑主应用文件
nano app.js
```

### 添加静态文件服务
在 Express 配置中添加：
```javascript
// 照片管理后台静态文件
app.use('/admin', express.static(path.join(__dirname, 'admin')));

// 用户照片静态文件
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

## 4. 重启服务

```bash
# 重启PM2服务
pm2 restart all

# 检查服务状态
pm2 status

# 查看日志
pm2 logs
```

## 5. 访问管理系统

- 管理后台地址：`http://195.86.16.16:3000/admin/`
- API健康检查：`http://195.86.16.16:3000/api/admin/health`

## 6. 验证功能

1. 打开管理后台
2. 检查统计数据是否正确显示
3. 验证照片列表是否加载真实数据
4. 测试用户列表功能
5. 确认删除功能工作正常

## 故障排除

### 如果照片不显示
1. 检查 `/uploads` 目录权限：`chmod -R 755 uploads`
2. 确认静态文件路由配置正确
3. 检查浏览器网络面板的错误信息

### 如果API不工作
1. 检查PM2日志：`pm2 logs`
2. 确认路由文件正确导入
3. 验证控制器文件路径正确

### 权限问题
```bash
# 设置正确的文件权限
chown -R www-data:www-data /var/www/whoxa/admin
chmod -R 755 /var/www/whoxa/admin
chmod -R 755 /var/www/whoxa/uploads
```
