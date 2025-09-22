/**
 * 照片管理系统 - 独立Express应用
 * 
 * 运行在独立端口，不影响现有系统
 * 访问地址：http://195.86.16.16:3001/
 */

const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3001; // 使用独立端口

// 中间件配置
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS配置
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// 静态文件服务
app.use('/', express.static(path.join(__dirname)));

// 照片文件服务（指向现有的uploads目录）
app.use('/uploads', express.static('/var/www/whoxa/uploads'));

// 照片存储路径
const PHOTOS_BASE_DIR = '/var/www/whoxa/uploads/user_photos';

// API路由 - 获取统计数据
app.get('/api/admin/stats', async (req, res) => {
  try {
    console.log('📊 获取统计数据...');
    
    const stats = {
      totalPhotos: 0,
      totalUsers: 0,
      totalGroups: 0,
      todayUploads: 0
    };

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json(stats);
    }

    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    stats.totalUsers = userDirs.length;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const userDir of userDirs) {
      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        stats.totalPhotos += files.length;

        files.forEach(file => {
          const filePath = path.join(userPhotoDir, file);
          const fileStat = fs.statSync(filePath);
          if (fileStat.mtime >= today) {
            stats.todayUploads++;
          }
        });

      } catch (error) {
        console.error(`❌ 读取用户 ${userDir} 照片失败:`, error);
      }
    }

    res.json(stats);
  } catch (error) {
    console.error('❌ 获取统计数据失败:', error);
    res.status(500).json({ success: false, message: '获取统计数据失败' });
  }
});

// API路由 - 获取照片列表
app.get('/api/admin/photos', async (req, res) => {
  try {
    const { page = 1, limit = 50, user = '', date = '' } = req.query;
    const photos = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json({ photos: [], total: 0 });
    }

    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    for (const userDir of userDirs) {
      const userId = userDir.replace('user_', '');
      
      if (user && userId !== user) continue;

      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        for (const file of files) {
          const filePath = path.join(userPhotoDir, file);
          const fileStat = fs.statSync(filePath);
          
          // 日期筛选逻辑
          if (date) {
            const fileDate = new Date(fileStat.mtime);
            const now = new Date();
            
            let shouldInclude = false;
            switch (date) {
              case 'today':
                const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                shouldInclude = fileDate >= today;
                break;
              case 'week':
                const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                shouldInclude = fileDate >= weekAgo;
                break;
              case 'month':
                const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
                shouldInclude = fileDate >= monthStart;
                break;
              default:
                shouldInclude = true;
            }
            
            if (!shouldInclude) continue;
          }

          photos.push({
            id: `${userId}_${file}`,
            fileName: file,
            originalName: file.replace(/^photo_\d+_\d+/, 'IMG'),
            userId: userId,
            groupId: null,
            uploadTime: fileStat.mtime.toISOString(),
            size: fileStat.size,
            url: `/uploads/user_photos/${userDir}/${file}`,
            thumbnail: `/uploads/user_photos/${userDir}/${file}`
          });
        }

      } catch (error) {
        console.error(`❌ 读取用户 ${userDir} 照片失败:`, error);
      }
    }

    photos.sort((a, b) => new Date(b.uploadTime) - new Date(a.uploadTime));

    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedPhotos = photos.slice(startIndex, endIndex);

    res.json({
      photos: paginatedPhotos,
      total: photos.length,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(photos.length / limit)
    });

  } catch (error) {
    console.error('❌ 获取照片列表失败:', error);
    res.status(500).json({ success: false, message: '获取照片列表失败' });
  }
});

// API路由 - 获取用户列表
app.get('/api/admin/users', async (req, res) => {
  try {
    const users = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json(users);
    }

    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    for (const userDir of userDirs) {
      const userId = userDir.replace('user_', '');
      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        let lastUpload = null;
        let firstUpload = null;

        if (files.length > 0) {
          const fileTimes = files.map(file => {
            const filePath = path.join(userPhotoDir, file);
            return fs.statSync(filePath).mtime;
          });

          lastUpload = new Date(Math.max(...fileTimes)).toISOString();
          firstUpload = new Date(Math.min(...fileTimes)).toISOString();
        }

        users.push({
          id: userId,
          username: `用户${userId}`,
          email: `user${userId}@example.com`,
          photoCount: files.length,
          lastUpload: lastUpload,
          registrationTime: firstUpload || new Date().toISOString()
        });

      } catch (error) {
        console.error(`❌ 读取用户 ${userDir} 信息失败:`, error);
      }
    }

    users.sort((a, b) => b.photoCount - a.photoCount);
    res.json(users);

  } catch (error) {
    console.error('❌ 获取用户列表失败:', error);
    res.status(500).json({ success: false, message: '获取用户列表失败' });
  }
});

// API路由 - 获取最近上传
app.get('/api/admin/recent-uploads', async (req, res) => {
  try {
    const { limit = 5 } = req.query;
    const photos = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json(photos);
    }

    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    for (const userDir of userDirs) {
      const userId = userDir.replace('user_', '');
      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        for (const file of files) {
          const filePath = path.join(userPhotoDir, file);
          const fileStat = fs.statSync(filePath);
          
          photos.push({
            id: `${userId}_${file}`,
            fileName: file,
            originalName: file.replace(/^photo_\d+_\d+/, 'IMG'),
            userId: userId,
            uploadTime: fileStat.mtime.toISOString(),
            url: `/uploads/user_photos/${userDir}/${file}`,
            thumbnail: `/uploads/user_photos/${userDir}/${file}`
          });
        }

      } catch (error) {
        console.error(`❌ 读取用户 ${userDir} 照片失败:`, error);
      }
    }

    photos.sort((a, b) => new Date(b.uploadTime) - new Date(a.uploadTime));
    const recentPhotos = photos.slice(0, parseInt(limit));

    res.json(recentPhotos);

  } catch (error) {
    console.error('❌ 获取最近上传失败:', error);
    res.status(500).json({ success: false, message: '获取最近上传失败' });
  }
});

// API路由 - 删除照片
app.delete('/api/admin/photos/:photoId', async (req, res) => {
  try {
    const { photoId } = req.params;
    const [userId, fileName] = photoId.split('_', 2);
    
    if (!userId || !fileName) {
      return res.status(400).json({ success: false, message: '无效的照片ID' });
    }

    const userPhotoDir = path.join(PHOTOS_BASE_DIR, `user_${userId}`);
    const photoPath = path.join(userPhotoDir, `_${fileName}`);

    if (!fs.existsSync(photoPath)) {
      return res.status(404).json({ success: false, message: '照片不存在' });
    }

    fs.unlinkSync(photoPath);
    res.json({ success: true, message: '照片删除成功' });

  } catch (error) {
    console.error('❌ 删除照片失败:', error);
    res.status(500).json({ success: false, message: '删除照片失败' });
  }
});

// API路由 - 删除用户
app.delete('/api/admin/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const userPhotoDir = path.join(PHOTOS_BASE_DIR, `user_${userId}`);

    if (!fs.existsSync(userPhotoDir)) {
      return res.status(404).json({ success: false, message: '用户不存在' });
    }

    fs.rmSync(userPhotoDir, { recursive: true, force: true });
    res.json({ success: true, message: '用户删除成功' });

  } catch (error) {
    console.error('❌ 删除用户失败:', error);
    res.status(500).json({ success: false, message: '删除用户失败' });
  }
});

// 健康检查
app.get('/api/admin/health', (req, res) => {
  res.json({
    success: true,
    message: '照片管理系统运行正常',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 错误处理
app.use((error, req, res, next) => {
  console.error('❌ 服务器错误:', error);
  res.status(500).json({
    success: false,
    message: '服务器内部错误'
  });
});

// 404处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: '页面不存在'
  });
});

// 启动服务器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 照片管理系统已启动`);
  console.log(`📍 访问地址: http://195.86.16.16:${PORT}/`);
  console.log(`🔍 API健康检查: http://195.86.16.16:${PORT}/api/admin/health`);
  console.log(`📊 统计数据: http://195.86.16.16:${PORT}/api/admin/stats`);
});

module.exports = app;
