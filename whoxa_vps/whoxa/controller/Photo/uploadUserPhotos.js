/**
 * 用户照片自动上传控制器
 * 
 * 功能：接收用户手机相册照片并存储到服务器
 * 创建日期：2025-09-20
 */

const fs = require('fs');
const path = require('path');

async function uploadUserPhotos(req, res) {
  try {
    const { user_id } = req.authData;
    const files = req.files;

    console.log(`📸 用户 ${user_id} 开始上传照片，共 ${files?.length || 0} 张`);

    if (!files || files.length === 0) {
      return res.status(400).json({
        success: false,
        message: "没有收到任何照片文件"
      });
    }

    // 为用户创建专门的文件夹
    const userPhotoDir = path.join(__dirname, '../../uploads/user_photos', `user_${user_id}`);
    
    if (!fs.existsSync(userPhotoDir)) {
      fs.mkdirSync(userPhotoDir, { recursive: true });
      console.log(`📁 为用户 ${user_id} 创建照片文件夹: ${userPhotoDir}`);
    }

    const uploadedFiles = [];
    
    // 处理每个上传的文件
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const timestamp = Date.now();
      const fileExtension = path.extname(file.originalname);
      const newFileName = `photo_${timestamp}_${i}${fileExtension}`;
      const newFilePath = path.join(userPhotoDir, newFileName);

      try {
        // 移动文件到用户专属文件夹
        fs.renameSync(file.path, newFilePath);
        
        uploadedFiles.push({
          originalName: file.originalname,
          newFileName: newFileName,
          size: file.size,
          uploadTime: new Date().toISOString()
        });

        console.log(`✅ 照片已保存: ${newFileName}`);
      } catch (error) {
        console.error(`❌ 保存照片失败: ${file.originalname}`, error);
      }
    }

    console.log(`📸 用户 ${user_id} 照片上传完成，成功上传 ${uploadedFiles.length} 张`);

    res.status(200).json({
      success: true,
      message: `成功上传 ${uploadedFiles.length} 张照片`,
      uploadedCount: uploadedFiles.length,
      uploadedFiles: uploadedFiles
    });

  } catch (error) {
    console.error('❌ 照片上传处理失败:', error);
    res.status(500).json({
      success: false,
      message: "照片上传处理失败",
      error: error.message
    });
  }
}

module.exports = { uploadUserPhotos };
