# 🚀 VPS部署命令集合

## 📋 部署前准备

确保你在 `photo-admin-dashboard` 目录下，并且有VPS的SSH访问权限。

## 🔧 一键部署命令

### Windows用户
```batch
# 双击运行部署脚本
deploy.bat

# 或者在命令行运行
.\deploy.bat
```

### Linux/Mac用户
```bash
# 创建部署目录
ssh root@195.86.16.16 "cd /var/www/whoxa && mkdir -p admin/css admin/js admin/images"

# 上传前端文件
scp index.html root@195.86.16.16:/var/www/whoxa/admin/
scp guide.html root@195.86.16.16:/var/www/whoxa/admin/
scp config.json root@195.86.16.16:/var/www/whoxa/admin/
scp -r css/* root@195.86.16.16:/var/www/whoxa/admin/css/
scp -r js/* root@195.86.16.16:/var/www/whoxa/admin/js/

# 上传后端文件
scp server/photoAdminController.js root@195.86.16.16:/var/www/whoxa/controller/Admin/
scp server/photoAdminRoutes.js root@195.86.16.16:/var/www/whoxa/routes/

# 设置权限
ssh root@195.86.16.16 "chmod -R 755 /var/www/whoxa/admin && chmod -R 755 /var/www/whoxa/uploads"
```

## 🔗 VPS服务器集成

### 1. 修改路由文件
```bash
# 连接到VPS
ssh root@195.86.16.16

# 编辑路由文件
cd /var/www/whoxa
nano routes/AuthRoutes.js

# 在文件末尾（module.exports = router; 之前）添加：
```

```javascript
// 照片管理系统路由
const photoAdminRoutes = require('./photoAdminRoutes');
router.use('/', photoAdminRoutes);
```

### 2. 修改主应用文件
```bash
# 编辑主应用文件
nano app.js

# 在中间件配置部分添加：
```

```javascript
// 照片管理后台静态文件服务
app.use('/admin', express.static(path.join(__dirname, 'admin')));

// 用户照片静态文件服务
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
```

### 3. 重启服务
```bash
# 重启PM2服务
pm2 restart all

# 检查服务状态
pm2 status

# 查看日志（如有问题）
pm2 logs
```

## 🌐 访问地址

- **管理后台首页**: http://195.86.16.16:3000/admin/
- **使用指南页面**: http://195.86.16.16:3000/admin/guide.html
- **API健康检查**: http://195.86.16.16:3000/api/admin/health
- **统计数据API**: http://195.86.16.16:3000/api/admin/stats
- **照片列表API**: http://195.86.16.16:3000/api/admin/photos

## ✅ 验证部署

### 1. 检查文件是否上传成功
```bash
ssh root@195.86.16.16 "ls -la /var/www/whoxa/admin/"
```

### 2. 测试API接口
```bash
# 健康检查
curl http://195.86.16.16:3000/api/admin/health

# 统计数据
curl http://195.86.16.16:3000/api/admin/stats

# 照片列表
curl http://195.86.16.16:3000/api/admin/photos?limit=5
```

### 3. 检查静态文件访问
```bash
# 测试管理后台页面
curl -I http://195.86.16.16:3000/admin/

# 测试CSS文件
curl -I http://195.86.16.16:3000/admin/css/style.css
```

## 🔧 故障排除

### 问题1：页面404错误
```bash
# 检查文件权限
ssh root@195.86.16.16 "ls -la /var/www/whoxa/admin/"
ssh root@195.86.16.16 "chmod -R 755 /var/www/whoxa/admin"
```

### 问题2：API不响应
```bash
# 检查PM2状态
ssh root@195.86.16.16 "pm2 status"

# 查看错误日志
ssh root@195.86.16.16 "pm2 logs --lines 50"

# 重启服务
ssh root@195.86.16.16 "pm2 restart all"
```

### 问题3：照片不显示
```bash
# 检查uploads目录权限
ssh root@195.86.16.16 "ls -la /var/www/whoxa/uploads/"
ssh root@195.86.16.16 "chmod -R 755 /var/www/whoxa/uploads"

# 检查照片文件
ssh root@195.86.16.16 "find /var/www/whoxa/uploads -name '*.jpg' | head -5"
```

### 问题4：CORS跨域错误
在 `app.js` 中添加CORS中间件：
```javascript
app.use('/admin', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});
```

## 📊 性能监控

### 检查服务器资源使用
```bash
ssh root@195.86.16.16 "top -n 1 | head -20"
ssh root@195.86.16.16 "df -h"
ssh root@195.86.16.16 "free -h"
```

### 检查PM2进程状态
```bash
ssh root@195.86.16.16 "pm2 monit"
```

## 🔄 更新部署

如需更新管理系统：
```bash
# 重新运行部署脚本
.\deploy.bat

# 或手动上传更新的文件
scp js/app.js root@195.86.16.16:/var/www/whoxa/admin/js/
scp css/style.css root@195.86.16.16:/var/www/whoxa/admin/css/

# 重启服务
ssh root@195.86.16.16 "pm2 restart all"
```

---

**🎉 部署完成后，你就可以通过 http://195.86.16.16:3000/admin/ 访问精美的照片管理后台了！**
