const axios = require('axios');

// 测试添加联系人API
async function testAddContactAPI() {
  try {
    console.log('🔗 测试添加联系人API...');
    
    const response = await axios.post('http://195.86.16.16:3000/api/add-contact-name', {
      phone_number: '000000',
      full_name: '000000'
    }, {
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbF9pZCI6IiIsImZpcnN0X25hbWUiOiIiLCJsYXN0X25hbWUiOiIiLCJkZXZpY2VfdG9rZW4iOiIiLCJvbmVfc2lnbmFsX3BsYXllcl9pZCI6IiIsInVzZXJfbmFtZSI6IiIsImJpbyI6IkF2YWlsYWJsZSIsImRvYiI6IiIsInBhc3N3b3JkIjoiIiwibGFzdF9zZWVuIjowLCJnZW5kZXIiOiIiLCJwcm9maWxlX2ltYWdlIjoiIiwiQmxvY2tlZF9ieV9hZG1pbiI6ZmFsc2UsInZpZXdlZF9ieV9hZG1pbiI6ZmFsc2UsImF2YXRhcl9pZCI6MCwiaXNfYWNjb3VudF9kZWxldGVkIjpmYWxzZSwiaXNfbW9iaWxlIjpmYWxzZSwiaXNfd2ViIjpmYWxzZSwidXNlcl9pZCI6MiwicGhvbmVfbnVtYmVyIjoiMTExMTExMSIsIm90cCI6MTIzNDU2LCJjb3VudHJ5X2NvZGUiOiIrMSIsImNvdW50cnkiOiJVUyIsImNvdW50cnlfZnVsbF9uYW1lIjoiVW5pdGVkIFN0YXRlcyIsInVwZGF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImNyZWF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImlhdCI6MTc1ODM0MDI2MH0.AbHOETnBqKrHkKdkgvp8HbO8kxE_5-u4hFKxLLDvPc8',
        'Content-Type': 'application/json'
      }
    });
    
    console.log('✅ 添加联系人API测试成功!');
    console.log('状态码:', response.status);
    console.log('响应数据:', JSON.stringify(response.data, null, 2));
    
    if (response.data.success) {
      console.log(`🎉 联系人添加成功: ${response.data.message}`);
      console.log(`用户ID: ${response.data.user_id}`);
    }
  } catch (error) {
    console.error('❌ 添加联系人API测试失败:');
    console.error('错误信息:', error.message);
    if (error.response) {
      console.error('状态码:', error.response.status);
      console.error('响应数据:', error.response.data);
    }
  }
}

testAddContactAPI();
