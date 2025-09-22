/**
 * 将此代码添加到 /var/www/whoxa/routes/AuthRoutes.js 文件的末尾
 * 
 * 位置：在 module.exports = router; 之前添加
 */

// 照片管理系统路由
const photoAdminRoutes = require('./photoAdminRoutes');

// 添加管理系统API路由
router.use('/', photoAdminRoutes);

// 健康检查路由（用于验证管理系统是否正常工作）
router.get('/admin/health', (req, res) => {
  res.json({
    success: true,
    message: '照片管理系统运行正常',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 注意：确保此代码添加在 module.exports = router; 之前
