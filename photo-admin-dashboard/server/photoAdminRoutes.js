/**
 * 照片管理系统路由
 * 
 * 提供照片管理后台的API路由
 */

const express = require('express');
const router = express.Router();
const {
  getStats,
  getPhotos,
  getUsers,
  deletePhoto,
  deleteUser,
  getRecentUploads
} = require('./photoAdminController');

// 中间件：简单的管理员认证（可选）
const adminAuth = (req, res, next) => {
  // 在生产环境中，这里应该添加真正的管理员认证
  // 目前为了简化，直接通过
  next();
};

// 统计数据
router.get('/admin/stats', adminAuth, getStats);

// 照片管理
router.get('/admin/photos', adminAuth, getPhotos);
router.delete('/admin/photos/:photoId', adminAuth, deletePhoto);

// 用户管理
router.get('/admin/users', adminAuth, getUsers);
router.delete('/admin/users/:userId', adminAuth, deleteUser);

// 仪表盘数据
router.get('/admin/recent-uploads', adminAuth, getRecentUploads);

// 健康检查
router.get('/admin/health', (req, res) => {
  res.json({
    success: true,
    message: '照片管理系统运行正常',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
