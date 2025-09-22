/**
 * 将此代码添加到 /var/www/whoxa/app.js 文件中
 * 
 * 位置：在其他 app.use() 配置之后添加
 */

// 照片管理后台静态文件服务
app.use('/admin', express.static(path.join(__dirname, 'admin')));

// 用户照片静态文件服务（如果还没有的话）
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 添加CORS支持（如果需要跨域访问）
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

// 确保此代码添加在路由配置之前，但在基本中间件之后
