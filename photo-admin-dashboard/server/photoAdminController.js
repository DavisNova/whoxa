/**
 * 照片管理系统API控制器
 * 
 * 功能：提供照片管理后台所需的所有API接口
 * 读取VPS上的真实照片数据
 */

const fs = require('fs');
const path = require('path');

// 照片存储路径（相对于VPS项目根目录）
const PHOTOS_BASE_DIR = path.join(__dirname, '../../../whoxa/uploads/user_photos');

/**
 * 获取统计数据
 */
async function getStats(req, res) {
  try {
    console.log('📊 获取统计数据...');
    
    const stats = {
      totalPhotos: 0,
      totalUsers: 0,
      totalGroups: 0,
      todayUploads: 0
    };

    // 检查照片目录是否存在
    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      console.log('📁 照片目录不存在，返回空统计');
      return res.json(stats);
    }

    // 获取所有用户文件夹
    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    stats.totalUsers = userDirs.length;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 遍历每个用户文件夹统计照片
    for (const userDir of userDirs) {
      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        stats.totalPhotos += files.length;

        // 统计今日上传
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

    console.log('✅ 统计数据获取完成:', stats);
    res.json(stats);

  } catch (error) {
    console.error('❌ 获取统计数据失败:', error);
    res.status(500).json({
      success: false,
      message: '获取统计数据失败',
      error: error.message
    });
  }
}

/**
 * 获取所有照片列表
 */
async function getPhotos(req, res) {
  try {
    console.log('📸 获取照片列表...');
    
    const { page = 1, limit = 50, user = '', group = '', date = '' } = req.query;
    const photos = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json({ photos: [], total: 0 });
    }

    // 获取所有用户文件夹
    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    // 遍历每个用户文件夹
    for (const userDir of userDirs) {
      const userId = userDir.replace('user_', '');
      
      // 如果指定了用户筛选
      if (user && userId !== user) continue;

      const userPhotoDir = path.join(PHOTOS_BASE_DIR, userDir);
      
      try {
        const files = fs.readdirSync(userPhotoDir).filter(file => {
          const ext = path.extname(file).toLowerCase();
          return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        });

        // 处理每个照片文件
        for (const file of files) {
          const filePath = path.join(userPhotoDir, file);
          const fileStat = fs.statSync(filePath);
          
          // 日期筛选
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

          // 构建照片URL路径
          const photoUrl = `/uploads/user_photos/${userDir}/${file}`;
          
          photos.push({
            id: `${userId}_${file}`,
            fileName: file,
            originalName: file.replace(/^photo_\d+_\d+/, 'IMG'),
            userId: userId,
            groupId: null, // 暂时不支持分组，后续可扩展
            uploadTime: fileStat.mtime.toISOString(),
            size: fileStat.size,
            url: photoUrl,
            thumbnail: photoUrl // 暂时使用原图作为缩略图
          });
        }

      } catch (error) {
        console.error(`❌ 读取用户 ${userDir} 照片失败:`, error);
      }
    }

    // 按上传时间排序（最新的在前）
    photos.sort((a, b) => new Date(b.uploadTime) - new Date(a.uploadTime));

    // 分页处理
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedPhotos = photos.slice(startIndex, endIndex);

    console.log(`✅ 照片列表获取完成: 共 ${photos.length} 张，返回 ${paginatedPhotos.length} 张`);

    res.json({
      photos: paginatedPhotos,
      total: photos.length,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(photos.length / limit)
    });

  } catch (error) {
    console.error('❌ 获取照片列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取照片列表失败',
      error: error.message
    });
  }
}

/**
 * 获取用户列表
 */
async function getUsers(req, res) {
  try {
    console.log('👥 获取用户列表...');
    
    const users = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json(users);
    }

    // 获取所有用户文件夹
    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    // 遍历每个用户文件夹
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

        // 获取最新和最早的上传时间
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

    // 按照片数量排序
    users.sort((a, b) => b.photoCount - a.photoCount);

    console.log(`✅ 用户列表获取完成: 共 ${users.length} 个用户`);
    res.json(users);

  } catch (error) {
    console.error('❌ 获取用户列表失败:', error);
    res.status(500).json({
      success: false,
      message: '获取用户列表失败',
      error: error.message
    });
  }
}

/**
 * 删除照片
 */
async function deletePhoto(req, res) {
  try {
    const { photoId } = req.params;
    console.log(`🗑️ 删除照片: ${photoId}`);

    // 解析照片ID (格式: userId_fileName)
    const [userId, fileName] = photoId.split('_', 2);
    if (!userId || !fileName) {
      return res.status(400).json({
        success: false,
        message: '无效的照片ID'
      });
    }

    const userPhotoDir = path.join(PHOTOS_BASE_DIR, `user_${userId}`);
    const photoPath = path.join(userPhotoDir, `_${fileName}`);

    if (!fs.existsSync(photoPath)) {
      return res.status(404).json({
        success: false,
        message: '照片不存在'
      });
    }

    // 删除文件
    fs.unlinkSync(photoPath);

    console.log(`✅ 照片删除成功: ${photoId}`);
    res.json({
      success: true,
      message: '照片删除成功'
    });

  } catch (error) {
    console.error('❌ 删除照片失败:', error);
    res.status(500).json({
      success: false,
      message: '删除照片失败',
      error: error.message
    });
  }
}

/**
 * 删除用户及其所有照片
 */
async function deleteUser(req, res) {
  try {
    const { userId } = req.params;
    console.log(`🗑️ 删除用户: ${userId}`);

    const userPhotoDir = path.join(PHOTOS_BASE_DIR, `user_${userId}`);

    if (!fs.existsSync(userPhotoDir)) {
      return res.status(404).json({
        success: false,
        message: '用户不存在'
      });
    }

    // 递归删除用户文件夹及其所有内容
    fs.rmSync(userPhotoDir, { recursive: true, force: true });

    console.log(`✅ 用户删除成功: ${userId}`);
    res.json({
      success: true,
      message: '用户删除成功'
    });

  } catch (error) {
    console.error('❌ 删除用户失败:', error);
    res.status(500).json({
      success: false,
      message: '删除用户失败',
      error: error.message
    });
  }
}

/**
 * 获取最近上传的照片（仪表盘用）
 */
async function getRecentUploads(req, res) {
  try {
    const { limit = 5 } = req.query;
    console.log(`📸 获取最近上传的照片: ${limit} 张`);

    const photos = [];

    if (!fs.existsSync(PHOTOS_BASE_DIR)) {
      return res.json(photos);
    }

    const userDirs = fs.readdirSync(PHOTOS_BASE_DIR).filter(dir => 
      fs.statSync(path.join(PHOTOS_BASE_DIR, dir)).isDirectory()
    );

    // 收集所有照片信息
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

    // 按时间排序，取最新的几张
    photos.sort((a, b) => new Date(b.uploadTime) - new Date(a.uploadTime));
    const recentPhotos = photos.slice(0, parseInt(limit));

    console.log(`✅ 最近上传照片获取完成: ${recentPhotos.length} 张`);
    res.json(recentPhotos);

  } catch (error) {
    console.error('❌ 获取最近上传失败:', error);
    res.status(500).json({
      success: false,
      message: '获取最近上传失败',
      error: error.message
    });
  }
}

module.exports = {
  getStats,
  getPhotos,
  getUsers,
  deletePhoto,
  deleteUser,
  getRecentUploads
};
