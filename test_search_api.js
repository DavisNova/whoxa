const axios = require('axios');

// 测试搜索API
async function testSearchAPI() {
  try {
    const response = await axios.post('http://195.86.16.16:3000/api/search-user', {
      user_name: 'da'
    }, {
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbF9pZCI6IiIsImZpcnN0X25hbWUiOiIiLCJsYXN0X25hbWUiOiIiLCJkZXZpY2VfdG9rZW4iOiIiLCJvbmVfc2lnbmFsX3BsYXllcl9pZCI6IiIsInVzZXJfbmFtZSI6IiIsImJpbyI6IkF2YWlsYWJsZSIsImRvYiI6IiIsInBhc3N3b3JkIjoiIiwibGFzdF9zZWVuIjowLCJnZW5kZXIiOiIiLCJwcm9maWxlX2ltYWdlIjoiIiwiQmxvY2tlZF9ieV9hZG1pbiI6ZmFsc2UsInZpZXdlZF9ieV9hZG1pbiI6ZmFsc2UsImF2YXRhcl9pZCI6MCwiaXNfYWNjb3VudF9kZWxldGVkIjpmYWxzZSwiaXNfbW9iaWxlIjpmYWxzZSwiaXNfd2ViIjpmYWxzZSwidXNlcl9pZCI6MiwicGhvbmVfbnVtYmVyIjoiMTExMTExMSIsIm90cCI6MTIzNDU2LCJjb3VudHJ5X2NvZGUiOiIrMSIsImNvdW50cnkiOiJVUyIsImNvdW50cnlfZnVsbF9uYW1lIjoiVW5pdGVkIFN0YXRlcyIsInVwZGF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImNyZWF0ZWRBdCI6IjIwMjUtMDktMjBUMDM6NTE6MDAuMTUyWiIsImlhdCI6MTc1ODM0MDI2MH0.AbHOETnBqKrHkKdkgvp8HbO8kxE_5-u4hFKxLLDvPc8',
        'Content-Type': 'application/json'
      }
    });
    
    console.log('搜索API测试成功:');
    console.log('状态码:', response.status);
    console.log('响应数据:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('搜索API测试失败:');
    console.error('错误信息:', error.message);
    if (error.response) {
      console.error('状态码:', error.response.status);
      console.error('响应数据:', error.response.data);
    }
  }
}

testSearchAPI();
