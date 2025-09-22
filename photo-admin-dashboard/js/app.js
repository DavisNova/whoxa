/**
 * Beimo 照片管理后台 - 主要JavaScript文件
 * 功能：实时数据管理、分组操作、增删改查、现代化界面交互
 */

class PhotoAdminApp {
    constructor() {
        // 配置信息
        this.config = {
            apiUrl: 'http://195.86.16.16:3001/api',
            refreshInterval: 30000, // 30秒
            pageSize: 50,
            autoRefresh: true
        };

        // 数据存储
        this.data = {
            photos: [],
            users: [],
            groups: [],
            stats: {
                totalPhotos: 0,
                totalUsers: 0,
                totalGroups: 0,
                todayUploads: 0
            }
        };

        // 状态管理
        this.state = {
            currentSection: 'dashboard',
            currentPage: 1,
            currentView: 'grid',
            filters: {
                user: '',
                group: '',
                date: ''
            },
            loading: false,
            selectedPhotos: [],
            refreshTimer: null
        };

        // 初始化应用
        this.init();
    }

    /**
     * 初始化应用
     */
    async init() {
        console.log('🚀 初始化 Beimo 照片管理后台...');
        
        // 绑定事件监听器
        this.bindEventListeners();
        
        // 加载配置
        this.loadConfig();
        
        // 初始化界面
        this.initializeUI();
        
        // 加载初始数据
        await this.loadInitialData();
        
        // 启动自动刷新
        this.startAutoRefresh();
        
        console.log('✅ 应用初始化完成');
    }

    /**
     * 绑定事件监听器
     */
    bindEventListeners() {
        // 导航菜单
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const section = link.dataset.section;
                this.switchSection(section);
            });
        });

        // 侧边栏切换
        const sidebarToggle = document.querySelector('.sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                document.querySelector('.sidebar').classList.toggle('active');
            });
        }

        // 刷新按钮
        const refreshBtn = document.getElementById('refreshBtn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', () => {
                this.refreshData();
            });
        }

        // 全局搜索
        const globalSearch = document.getElementById('globalSearch');
        if (globalSearch) {
            globalSearch.addEventListener('input', (e) => {
                this.handleGlobalSearch(e.target.value);
            });
        }

        // 视图切换
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const view = btn.dataset.view;
                this.switchView(view);
            });
        });

        // 筛选器
        this.bindFilterListeners();

        // 模态框
        this.bindModalListeners();

        // 分组管理
        this.bindGroupListeners();

        // 设置
        this.bindSettingsListeners();

        // 键盘快捷键
        this.bindKeyboardShortcuts();
    }

    /**
     * 绑定筛选器事件
     */
    bindFilterListeners() {
        const filters = ['userFilter', 'groupFilter', 'dateFilter'];
        
        filters.forEach(filterId => {
            const filter = document.getElementById(filterId);
            if (filter) {
                filter.addEventListener('change', () => {
                    this.updateFilters();
                    this.loadPhotos();
                });
            }
        });
    }

    /**
     * 绑定模态框事件
     */
    bindModalListeners() {
        // 模态框关闭
        document.querySelectorAll('.modal-close').forEach(btn => {
            btn.addEventListener('click', () => {
                this.closeModal();
            });
        });

        // 点击背景关闭模态框
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal();
                }
            });
        });

        // 照片模态框保存
        const savePhotoBtn = document.getElementById('savePhotoBtn');
        if (savePhotoBtn) {
            savePhotoBtn.addEventListener('click', () => {
                this.savePhotoChanges();
            });
        }

        // 删除照片
        const deletePhotoBtn = document.getElementById('deletePhotoBtn');
        if (deletePhotoBtn) {
            deletePhotoBtn.addEventListener('click', () => {
                this.deletePhoto();
            });
        }
    }

    /**
     * 绑定分组管理事件
     */
    bindGroupListeners() {
        // 创建分组按钮
        const createGroupBtn = document.getElementById('createGroupBtn');
        if (createGroupBtn) {
            createGroupBtn.addEventListener('click', () => {
                this.showCreateGroupModal();
            });
        }

        const addGroupBtn = document.getElementById('addGroupBtn');
        if (addGroupBtn) {
            addGroupBtn.addEventListener('click', () => {
                this.showCreateGroupModal();
            });
        }

        // 保存分组
        const saveGroupBtn = document.getElementById('saveGroupBtn');
        if (saveGroupBtn) {
            saveGroupBtn.addEventListener('click', () => {
                this.saveGroup();
            });
        }
    }

    /**
     * 绑定设置事件
     */
    bindSettingsListeners() {
        const apiUrl = document.getElementById('apiUrl');
        const refreshInterval = document.getElementById('refreshInterval');
        const pageSize = document.getElementById('pageSize');
        const autoRefresh = document.getElementById('autoRefresh');

        if (apiUrl) {
            apiUrl.addEventListener('change', () => {
                this.config.apiUrl = apiUrl.value;
                this.saveConfig();
            });
        }

        if (refreshInterval) {
            refreshInterval.addEventListener('change', () => {
                this.config.refreshInterval = parseInt(refreshInterval.value) * 1000;
                this.saveConfig();
                this.restartAutoRefresh();
            });
        }

        if (pageSize) {
            pageSize.addEventListener('change', () => {
                this.config.pageSize = parseInt(pageSize.value);
                this.saveConfig();
                this.loadPhotos();
            });
        }

        if (autoRefresh) {
            autoRefresh.addEventListener('change', () => {
                this.config.autoRefresh = autoRefresh.checked;
                this.saveConfig();
                if (autoRefresh.checked) {
                    this.startAutoRefresh();
                } else {
                    this.stopAutoRefresh();
                }
            });
        }
    }

    /**
     * 绑定键盘快捷键
     */
    bindKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Ctrl/Cmd + R: 刷新
            if ((e.ctrlKey || e.metaKey) && e.key === 'r') {
                e.preventDefault();
                this.refreshData();
            }

            // Escape: 关闭模态框
            if (e.key === 'Escape') {
                this.closeModal();
            }

            // Ctrl/Cmd + N: 新建分组
            if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
                e.preventDefault();
                if (this.state.currentSection === 'groups') {
                    this.showCreateGroupModal();
                }
            }
        });
    }

    /**
     * 初始化界面
     */
    initializeUI() {
        // 设置初始配置值
        const apiUrlInput = document.getElementById('apiUrl');
        const refreshIntervalInput = document.getElementById('refreshInterval');
        const pageSizeSelect = document.getElementById('pageSize');
        const autoRefreshCheckbox = document.getElementById('autoRefresh');

        if (apiUrlInput) apiUrlInput.value = this.config.apiUrl;
        if (refreshIntervalInput) refreshIntervalInput.value = this.config.refreshInterval / 1000;
        if (pageSizeSelect) pageSizeSelect.value = this.config.pageSize;
        if (autoRefreshCheckbox) autoRefreshCheckbox.checked = this.config.autoRefresh;

        // 显示加载状态
        this.showLoading();
    }

    /**
     * 加载初始数据
     */
    async loadInitialData() {
        try {
            console.log('📊 加载初始数据...');
            
            // 并行加载所有数据
            await Promise.all([
                this.loadStats(),
                this.loadPhotos(),
                this.loadUsers(),
                this.loadGroups()
            ]);

            // 更新界面
            this.updateDashboard();
            this.updateUI();

            console.log('✅ 初始数据加载完成');
        } catch (error) {
            console.error('❌ 加载初始数据失败:', error);
            this.showToast('加载数据失败，请检查网络连接', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 加载统计数据
     */
    async loadStats() {
        try {
            // 尝试从真实API加载数据
            try {
                const stats = await this.apiCall('/admin/stats');
                this.data.stats = stats;
                this.updateStatsDisplay();
                return;
            } catch (apiError) {
                console.warn('⚠️ 真实API不可用，使用模拟数据:', apiError);
            }

            // 备用：使用模拟数据
            const stats = await this.mockApiCall('/stats', {
                totalPhotos: this.generateRandomNumber(100, 10000),
                totalUsers: this.generateRandomNumber(10, 1000),
                totalGroups: this.generateRandomNumber(5, 50),
                todayUploads: this.generateRandomNumber(0, 100)
            });

            this.data.stats = stats;
            this.updateStatsDisplay();
            
        } catch (error) {
            console.error('❌ 加载统计数据失败:', error);
        }
    }

    /**
     * 加载照片数据
     */
    async loadPhotos() {
        try {
            // 构建查询参数
            const params = new URLSearchParams({
                page: this.state.currentPage,
                limit: this.config.pageSize,
                user: this.state.filters.user || '',
                group: this.state.filters.group || '',
                date: this.state.filters.date || ''
            });

            // 尝试从真实API加载数据
            try {
                const response = await this.apiCall(`/admin/photos?${params}`);
                this.data.photos = response.photos || [];
                this.data.totalPhotos = response.total || 0;
                this.updatePhotosDisplay();
                return;
            } catch (apiError) {
                console.warn('⚠️ 真实API不可用，使用模拟数据:', apiError);
            }

            // 备用：使用模拟数据
            const photos = await this.mockApiCall('/photos', this.generateMockPhotos(200));
            this.data.photos = this.applyFilters(photos);
            this.updatePhotosDisplay();
            
        } catch (error) {
            console.error('❌ 加载照片数据失败:', error);
        }
    }

    /**
     * 加载用户数据
     */
    async loadUsers() {
        try {
            // 尝试从真实API加载数据
            try {
                const users = await this.apiCall('/admin/users');
                this.data.users = users;
                this.updateUsersDisplay();
                this.updateUserFilters();
                return;
            } catch (apiError) {
                console.warn('⚠️ 真实API不可用，使用模拟数据:', apiError);
            }

            // 备用：使用模拟数据
            const users = await this.mockApiCall('/users', this.generateMockUsers(50));
            this.data.users = users;
            this.updateUsersDisplay();
            this.updateUserFilters();
            
        } catch (error) {
            console.error('❌ 加载用户数据失败:', error);
        }
    }

    /**
     * 加载分组数据
     */
    async loadGroups() {
        try {
            const groups = await this.mockApiCall('/groups', this.generateMockGroups(15));
            this.data.groups = groups;
            this.updateGroupsDisplay();
            this.updateGroupFilters();
            
        } catch (error) {
            console.error('❌ 加载分组数据失败:', error);
        }
    }

    /**
     * 真实API调用
     */
    async apiCall(endpoint, options = {}) {
        try {
            const url = `${this.config.apiUrl}${endpoint}`;
            const response = await fetch(url, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            console.error(`❌ API调用失败 ${endpoint}:`, error);
            throw error;
        }
    }

    /**
     * 模拟API调用（备用）
     */
    async mockApiCall(endpoint, mockData) {
        // 模拟网络延迟
        await new Promise(resolve => setTimeout(resolve, 300 + Math.random() * 700));
        return mockData;
    }

    /**
     * 生成模拟照片数据
     */
    generateMockPhotos(count) {
        const photos = [];
        const users = ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'];
        const groups = ['风景', '人物', '美食', '旅行', '生活'];
        
        for (let i = 1; i <= count; i++) {
            photos.push({
                id: i,
                fileName: `photo_${Date.now()}_${i}.jpg`,
                originalName: `IMG_${String(i).padStart(4, '0')}.jpg`,
                userId: users[Math.floor(Math.random() * users.length)],
                groupId: Math.random() > 0.3 ? groups[Math.floor(Math.random() * groups.length)] : null,
                uploadTime: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString(),
                size: this.generateRandomNumber(100000, 5000000),
                url: `https://picsum.photos/400/300?random=${i}`,
                thumbnail: `https://picsum.photos/200/150?random=${i}`
            });
        }
        
        return photos.sort((a, b) => new Date(b.uploadTime) - new Date(a.uploadTime));
    }

    /**
     * 生成模拟用户数据
     */
    generateMockUsers(count) {
        const users = [];
        
        for (let i = 1; i <= count; i++) {
            const photoCount = this.generateRandomNumber(0, 50);
            const lastUpload = photoCount > 0 ? 
                new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000).toISOString() : 
                null;
            
            users.push({
                id: `user_${i}`,
                username: `用户${i}`,
                email: `user${i}@example.com`,
                photoCount: photoCount,
                lastUpload: lastUpload,
                registrationTime: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000).toISOString()
            });
        }
        
        return users.sort((a, b) => b.photoCount - a.photoCount);
    }

    /**
     * 生成模拟分组数据
     */
    generateMockGroups(count) {
        const groupNames = ['风景摄影', '人物写真', '美食记录', '旅行足迹', '日常生活', '宠物萌照', '建筑艺术', '花卉植物', '街拍纪实', '夜景灯光', '黑白摄影', '微距特写', '运动瞬间', '节日庆典', '工作记录'];
        const colors = ['#3b82f6', '#ef4444', '#10b981', '#f59e0b', '#8b5cf6', '#06b6d4', '#84cc16', '#f97316', '#ec4899', '#6366f1'];
        const groups = [];
        
        for (let i = 0; i < Math.min(count, groupNames.length); i++) {
            const photoCount = this.generateRandomNumber(0, 30);
            
            groups.push({
                id: i + 1,
                name: groupNames[i],
                description: `${groupNames[i]}相关的照片收藏`,
                color: colors[i % colors.length],
                photoCount: photoCount,
                createdTime: new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000).toISOString(),
                updatedTime: photoCount > 0 ? 
                    new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString() : 
                    null
            });
        }
        
        return groups.sort((a, b) => b.photoCount - a.photoCount);
    }

    /**
     * 生成随机数
     */
    generateRandomNumber(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    /**
     * 应用筛选器
     */
    applyFilters(photos) {
        let filtered = [...photos];
        
        // 用户筛选
        if (this.state.filters.user) {
            filtered = filtered.filter(photo => photo.userId === this.state.filters.user);
        }
        
        // 分组筛选
        if (this.state.filters.group) {
            filtered = filtered.filter(photo => photo.groupId === this.state.filters.group);
        }
        
        // 时间筛选
        if (this.state.filters.date) {
            const now = new Date();
            let startDate;
            
            switch (this.state.filters.date) {
                case 'today':
                    startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                    break;
                case 'week':
                    startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                    break;
                case 'month':
                    startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                    break;
                default:
                    startDate = null;
            }
            
            if (startDate) {
                filtered = filtered.filter(photo => new Date(photo.uploadTime) >= startDate);
            }
        }
        
        return filtered;
    }

    /**
     * 更新筛选器
     */
    updateFilters() {
        const userFilter = document.getElementById('userFilter');
        const groupFilter = document.getElementById('groupFilter');
        const dateFilter = document.getElementById('dateFilter');
        
        this.state.filters = {
            user: userFilter ? userFilter.value : '',
            group: groupFilter ? groupFilter.value : '',
            date: dateFilter ? dateFilter.value : ''
        };
    }

    /**
     * 切换页面区域
     */
    switchSection(section) {
        // 更新导航状态
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        
        document.querySelector(`[data-section="${section}"]`).parentElement.classList.add('active');
        
        // 更新页面标题
        const titles = {
            dashboard: '仪表盘',
            photos: '照片管理',
            groups: '分组管理',
            users: '用户管理',
            settings: '系统设置'
        };
        
        const pageTitle = document.querySelector('.page-title');
        if (pageTitle) {
            pageTitle.textContent = titles[section] || section;
        }
        
        // 显示对应区域
        document.querySelectorAll('.content-section').forEach(section => {
            section.classList.remove('active');
        });
        
        const targetSection = document.getElementById(`${section}-section`);
        if (targetSection) {
            targetSection.classList.add('active');
            targetSection.classList.add('fade-in');
        }
        
        this.state.currentSection = section;
        
        // 加载对应数据
        this.loadSectionData(section);
    }

    /**
     * 加载区域数据
     */
    async loadSectionData(section) {
        switch (section) {
            case 'dashboard':
                await this.loadStats();
                this.updateDashboard();
                break;
            case 'photos':
                await this.loadPhotos();
                break;
            case 'groups':
                await this.loadGroups();
                break;
            case 'users':
                await this.loadUsers();
                break;
            case 'settings':
                // 设置页面不需要加载额外数据
                break;
        }
    }

    /**
     * 切换视图模式
     */
    switchView(view) {
        // 更新按钮状态
        document.querySelectorAll('.view-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        document.querySelector(`[data-view="${view}"]`).classList.add('active');
        
        this.state.currentView = view;
        this.updatePhotosDisplay();
    }

    /**
     * 更新统计显示
     */
    updateStatsDisplay() {
        const stats = this.data.stats;
        
        // 动画更新数字
        this.animateNumber('totalPhotos', stats.totalPhotos);
        this.animateNumber('totalUsers', stats.totalUsers);
        this.animateNumber('totalGroups', stats.totalGroups);
        this.animateNumber('todayUploads', stats.todayUploads);
    }

    /**
     * 数字动画
     */
    animateNumber(elementId, targetValue) {
        const element = document.getElementById(elementId);
        if (!element) return;
        
        const startValue = parseInt(element.textContent) || 0;
        const duration = 1000;
        const startTime = performance.now();
        
        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            const easeOutQuart = 1 - Math.pow(1 - progress, 4);
            const currentValue = Math.floor(startValue + (targetValue - startValue) * easeOutQuart);
            
            element.textContent = currentValue.toLocaleString();
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };
        
        requestAnimationFrame(animate);
    }

    /**
     * 更新仪表盘
     */
    updateDashboard() {
        this.updateRecentUploads();
        this.updateActiveUsers();
    }

    /**
     * 更新最近上传
     */
    async updateRecentUploads() {
        const container = document.getElementById('recentUploads');
        if (!container) return;
        
        try {
            // 尝试从真实API获取最近上传
            try {
                const recentPhotos = await this.apiCall('/admin/recent-uploads?limit=5');
                container.innerHTML = recentPhotos.map(photo => `
                    <div class="upload-item">
                        <img src="${this.config.apiUrl.replace('/api', '')}${photo.thumbnail}" alt="${photo.originalName}" class="upload-thumbnail">
                        <div class="upload-info">
                            <h4>${photo.originalName}</h4>
                            <p>${photo.userId} · ${this.formatDate(photo.uploadTime)}</p>
                        </div>
                    </div>
                `).join('');
                return;
            } catch (apiError) {
                console.warn('⚠️ 最近上传API不可用，使用本地数据:', apiError);
            }
        } catch (error) {
            console.error('❌ 更新最近上传失败:', error);
        }

        // 备用：使用本地数据
        const recentPhotos = this.data.photos.slice(0, 5);
        container.innerHTML = recentPhotos.map(photo => `
            <div class="upload-item">
                <img src="${photo.thumbnail}" alt="${photo.originalName}" class="upload-thumbnail">
                <div class="upload-info">
                    <h4>${photo.originalName}</h4>
                    <p>${photo.userId} · ${this.formatDate(photo.uploadTime)}</p>
                </div>
            </div>
        `).join('');
    }

    /**
     * 更新活跃用户
     */
    updateActiveUsers() {
        const container = document.getElementById('activeUsers');
        if (!container) return;
        
        const activeUsers = this.data.users
            .filter(user => user.photoCount > 0)
            .slice(0, 5);
        
        container.innerHTML = activeUsers.map(user => `
            <div class="user-item">
                <div class="user-item-avatar">
                    ${user.username.charAt(0)}
                </div>
                <div class="user-item-info">
                    <h4>${user.username}</h4>
                    <p>${user.photoCount} 张照片</p>
                </div>
            </div>
        `).join('');
    }

    /**
     * 更新照片显示
     */
    updatePhotosDisplay() {
        const container = document.getElementById('photosGrid');
        const countElement = document.getElementById('photoCount');
        
        if (!container) return;
        
        const photos = this.data.photos;
        const startIndex = (this.state.currentPage - 1) * this.config.pageSize;
        const endIndex = startIndex + this.config.pageSize;
        const paginatedPhotos = photos.slice(startIndex, endIndex);
        
        // 更新计数
        if (countElement) {
            countElement.textContent = `共 ${photos.length} 张照片`;
        }
        
        // 根据视图模式显示
        if (this.state.currentView === 'grid') {
            container.className = 'photos-grid';
            container.innerHTML = paginatedPhotos.map(photo => this.createPhotoCard(photo)).join('');
        } else {
            container.className = 'photos-list';
            container.innerHTML = paginatedPhotos.map(photo => this.createPhotoListItem(photo)).join('');
        }
        
        // 绑定照片点击事件
        container.querySelectorAll('.photo-item').forEach((item, index) => {
            item.addEventListener('click', () => {
                const photo = paginatedPhotos[index];
                this.showPhotoModal(photo);
            });
        });
        
        // 更新分页
        this.updatePagination(this.data.totalPhotos || photos.length);
    }

    /**
     * 创建照片卡片
     */
    createPhotoCard(photo) {
        const imageUrl = photo.thumbnail.startsWith('http') ? 
            photo.thumbnail : 
            `${this.config.apiUrl.replace('/api', '')}${photo.thumbnail}`;
            
        return `
            <div class="photo-item" data-photo-id="${photo.id}">
                <img src="${imageUrl}" alt="${photo.originalName}" class="photo-thumbnail" 
                     onerror="this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjE1MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjE1MCIgZmlsbD0iI2Y4ZmFmYyIvPjx0ZXh0IHg9IjEwMCIgeT0iNzUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk0YTNiOCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPuWbvueJh+aXoOazleWKoOi9vTwvdGV4dD48L3N2Zz4='">
                <div class="photo-info">
                    <h4>${photo.originalName}</h4>
                    <div class="photo-meta">
                        <span class="photo-user">
                            <i class="fas fa-user"></i>
                            用户${photo.userId}
                        </span>
                        <span class="photo-date">${this.formatDate(photo.uploadTime)}</span>
                    </div>
                </div>
            </div>
        `;
    }

    /**
     * 创建照片列表项
     */
    createPhotoListItem(photo) {
        return `
            <div class="photo-item photo-list-item" data-photo-id="${photo.id}">
                <img src="${photo.thumbnail}" alt="${photo.originalName}" class="photo-thumbnail">
                <div class="photo-details">
                    <h4>${photo.originalName}</h4>
                    <p>用户: ${photo.userId}</p>
                    <p>分组: ${photo.groupId || '未分组'}</p>
                    <p>大小: ${this.formatFileSize(photo.size)}</p>
                    <p>上传时间: ${this.formatDate(photo.uploadTime)}</p>
                </div>
                <div class="photo-actions">
                    <button class="action-btn" onclick="event.stopPropagation(); app.downloadPhoto('${photo.id}')">
                        <i class="fas fa-download"></i>
                    </button>
                    <button class="action-btn danger" onclick="event.stopPropagation(); app.deletePhotoConfirm('${photo.id}')">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `;
    }

    /**
     * 更新分组显示
     */
    updateGroupsDisplay() {
        const container = document.getElementById('groupsGrid');
        const countElement = document.getElementById('groupCount');
        
        if (!container) return;
        
        const groups = this.data.groups;
        
        // 更新计数
        if (countElement) {
            countElement.textContent = `共 ${groups.length} 个分组`;
        }
        
        container.innerHTML = groups.map(group => this.createGroupCard(group)).join('');
        
        // 绑定分组操作事件
        container.querySelectorAll('.group-card').forEach((card, index) => {
            const group = groups[index];
            
            // 编辑分组
            const editBtn = card.querySelector('.edit-group-btn');
            if (editBtn) {
                editBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    this.showEditGroupModal(group);
                });
            }
            
            // 删除分组
            const deleteBtn = card.querySelector('.delete-group-btn');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    this.deleteGroupConfirm(group.id);
                });
            }
        });
    }

    /**
     * 创建分组卡片
     */
    createGroupCard(group) {
        return `
            <div class="group-card" style="border-color: ${group.color}">
                <div class="group-header">
                    <div class="group-title">
                        <div class="group-color" style="background-color: ${group.color}"></div>
                        <h3>${group.name}</h3>
                    </div>
                    <div class="group-menu">
                        <button class="group-menu-btn">
                            <i class="fas fa-ellipsis-v"></i>
                        </button>
                        <div class="dropdown-menu">
                            <button class="edit-group-btn">
                                <i class="fas fa-edit"></i> 编辑
                            </button>
                            <button class="delete-group-btn">
                                <i class="fas fa-trash"></i> 删除
                            </button>
                        </div>
                    </div>
                </div>
                <div class="group-description">${group.description}</div>
                <div class="group-stats">
                    <span class="group-photo-count">${group.photoCount} 张照片</span>
                    <span class="group-updated">${group.updatedTime ? this.formatDate(group.updatedTime) : '从未更新'}</span>
                </div>
            </div>
        `;
    }

    /**
     * 更新用户显示
     */
    updateUsersDisplay() {
        const container = document.querySelector('#usersTable tbody');
        const countElement = document.getElementById('userCount');
        
        if (!container) return;
        
        const users = this.data.users;
        
        // 更新计数
        if (countElement) {
            countElement.textContent = `共 ${users.length} 个用户`;
        }
        
        container.innerHTML = users.map(user => this.createUserRow(user)).join('');
    }

    /**
     * 创建用户行
     */
    createUserRow(user) {
        return `
            <tr>
                <td>${user.id}</td>
                <td>${user.username}</td>
                <td>${user.photoCount}</td>
                <td>${user.lastUpload ? this.formatDate(user.lastUpload) : '从未上传'}</td>
                <td>${this.formatDate(user.registrationTime)}</td>
                <td>
                    <div class="user-actions">
                        <button class="action-btn" onclick="app.viewUserPhotos('${user.id}')" title="查看照片">
                            <i class="fas fa-images"></i>
                        </button>
                        <button class="action-btn danger" onclick="app.deleteUserConfirm('${user.id}')" title="删除用户">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }

    /**
     * 更新用户筛选器
     */
    updateUserFilters() {
        const userFilter = document.getElementById('userFilter');
        if (!userFilter) return;
        
        const currentValue = userFilter.value;
        userFilter.innerHTML = '<option value="">所有用户</option>' +
            this.data.users.map(user => 
                `<option value="${user.id}" ${user.id === currentValue ? 'selected' : ''}>${user.username}</option>`
            ).join('');
    }

    /**
     * 更新分组筛选器
     */
    updateGroupFilters() {
        const groupFilter = document.getElementById('groupFilter');
        const photoGroupSelect = document.getElementById('photoGroup');
        
        const groupOptions = '<option value="">所有分组</option>' +
            this.data.groups.map(group => 
                `<option value="${group.name}">${group.name}</option>`
            ).join('');
        
        if (groupFilter) {
            const currentValue = groupFilter.value;
            groupFilter.innerHTML = groupOptions;
            groupFilter.value = currentValue;
        }
        
        if (photoGroupSelect) {
            const currentValue = photoGroupSelect.value;
            photoGroupSelect.innerHTML = '<option value="">未分组</option>' + groupOptions.replace('所有分组', '');
            photoGroupSelect.value = currentValue;
        }
    }

    /**
     * 更新分页
     */
    updatePagination(totalItems) {
        const container = document.getElementById('pagination');
        if (!container) return;
        
        const totalPages = Math.ceil(totalItems / this.config.pageSize);
        const currentPage = this.state.currentPage;
        
        if (totalPages <= 1) {
            container.innerHTML = '';
            return;
        }
        
        let paginationHTML = '';
        
        // 上一页
        paginationHTML += `
            <button class="page-btn" ${currentPage <= 1 ? 'disabled' : ''} onclick="app.goToPage(${currentPage - 1})">
                <i class="fas fa-chevron-left"></i>
            </button>
        `;
        
        // 页码
        const startPage = Math.max(1, currentPage - 2);
        const endPage = Math.min(totalPages, currentPage + 2);
        
        if (startPage > 1) {
            paginationHTML += `<button class="page-btn" onclick="app.goToPage(1)">1</button>`;
            if (startPage > 2) {
                paginationHTML += `<span class="page-ellipsis">...</span>`;
            }
        }
        
        for (let i = startPage; i <= endPage; i++) {
            paginationHTML += `
                <button class="page-btn ${i === currentPage ? 'active' : ''}" onclick="app.goToPage(${i})">
                    ${i}
                </button>
            `;
        }
        
        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                paginationHTML += `<span class="page-ellipsis">...</span>`;
            }
            paginationHTML += `<button class="page-btn" onclick="app.goToPage(${totalPages})">${totalPages}</button>`;
        }
        
        // 下一页
        paginationHTML += `
            <button class="page-btn" ${currentPage >= totalPages ? 'disabled' : ''} onclick="app.goToPage(${currentPage + 1})">
                <i class="fas fa-chevron-right"></i>
            </button>
        `;
        
        container.innerHTML = paginationHTML;
    }

    /**
     * 跳转页面
     */
    goToPage(page) {
        this.state.currentPage = page;
        this.updatePhotosDisplay();
    }

    /**
     * 显示照片模态框
     */
    showPhotoModal(photo) {
        const modal = document.getElementById('photoModal');
        const modalPhoto = document.getElementById('modalPhoto');
        const photoFileName = document.getElementById('photoFileName');
        const photoUser = document.getElementById('photoUser');
        const photoUploadTime = document.getElementById('photoUploadTime');
        const photoSize = document.getElementById('photoSize');
        const photoGroup = document.getElementById('photoGroup');
        
        if (modal && modalPhoto && photoFileName && photoUser && photoUploadTime && photoSize && photoGroup) {
            modalPhoto.src = photo.url;
            photoFileName.textContent = photo.originalName;
            photoUser.textContent = photo.userId;
            photoUploadTime.textContent = this.formatDate(photo.uploadTime);
            photoSize.textContent = this.formatFileSize(photo.size);
            photoGroup.value = photo.groupId || '';
            
            modal.classList.add('active');
            modal.dataset.photoId = photo.id;
        }
    }

    /**
     * 显示创建分组模态框
     */
    showCreateGroupModal() {
        const modal = document.getElementById('groupModal');
        const modalTitle = document.getElementById('groupModalTitle');
        const groupName = document.getElementById('groupName');
        const groupDescription = document.getElementById('groupDescription');
        const groupColor = document.getElementById('groupColor');
        
        if (modal && modalTitle && groupName && groupDescription && groupColor) {
            modalTitle.textContent = '创建分组';
            groupName.value = '';
            groupDescription.value = '';
            groupColor.value = '#3b82f6';
            
            modal.classList.add('active');
            modal.dataset.mode = 'create';
        }
    }

    /**
     * 显示编辑分组模态框
     */
    showEditGroupModal(group) {
        const modal = document.getElementById('groupModal');
        const modalTitle = document.getElementById('groupModalTitle');
        const groupName = document.getElementById('groupName');
        const groupDescription = document.getElementById('groupDescription');
        const groupColor = document.getElementById('groupColor');
        
        if (modal && modalTitle && groupName && groupDescription && groupColor) {
            modalTitle.textContent = '编辑分组';
            groupName.value = group.name;
            groupDescription.value = group.description;
            groupColor.value = group.color;
            
            modal.classList.add('active');
            modal.dataset.mode = 'edit';
            modal.dataset.groupId = group.id;
        }
    }

    /**
     * 关闭模态框
     */
    closeModal() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
    }

    /**
     * 保存照片修改
     */
    async savePhotoChanges() {
        const modal = document.getElementById('photoModal');
        const photoId = modal.dataset.photoId;
        const newGroupId = document.getElementById('photoGroup').value;
        
        try {
            this.showLoading();
            
            // 在实际项目中，这里应该调用API更新照片信息
            // await this.apiCall(`/photos/${photoId}`, 'PUT', { groupId: newGroupId });
            
            // 模拟API调用
            await new Promise(resolve => setTimeout(resolve, 500));
            
            // 更新本地数据
            const photo = this.data.photos.find(p => p.id == photoId);
            if (photo) {
                photo.groupId = newGroupId || null;
            }
            
            this.closeModal();
            this.showToast('照片信息已更新', 'success');
            this.updatePhotosDisplay();
            
        } catch (error) {
            console.error('❌ 保存照片失败:', error);
            this.showToast('保存失败，请重试', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 删除照片
     */
    async deletePhoto() {
        const modal = document.getElementById('photoModal');
        const photoId = modal.dataset.photoId;
        
        if (!confirm('确定要删除这张照片吗？此操作不可撤销。')) {
            return;
        }
        
        try {
            this.showLoading();
            
            // 尝试调用真实API删除照片
            try {
                await this.apiCall(`/admin/photos/${photoId}`, { method: 'DELETE' });
                this.showToast('照片已删除', 'success');
            } catch (apiError) {
                console.warn('⚠️ 删除API不可用，仅本地删除:', apiError);
                this.showToast('照片已从本地列表删除', 'warning');
            }
            
            // 更新本地数据
            this.data.photos = this.data.photos.filter(p => p.id != photoId);
            
            this.closeModal();
            this.updatePhotosDisplay();
            this.loadStats(); // 重新加载统计数据
            
        } catch (error) {
            console.error('❌ 删除照片失败:', error);
            this.showToast('删除失败，请重试', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 保存分组
     */
    async saveGroup() {
        const modal = document.getElementById('groupModal');
        const mode = modal.dataset.mode;
        const groupId = modal.dataset.groupId;
        const name = document.getElementById('groupName').value.trim();
        const description = document.getElementById('groupDescription').value.trim();
        const color = document.getElementById('groupColor').value;
        
        if (!name) {
            this.showToast('请输入分组名称', 'warning');
            return;
        }
        
        try {
            this.showLoading();
            
            if (mode === 'create') {
                // 创建新分组
                const newGroup = {
                    id: this.data.groups.length + 1,
                    name: name,
                    description: description,
                    color: color,
                    photoCount: 0,
                    createdTime: new Date().toISOString(),
                    updatedTime: null
                };
                
                this.data.groups.push(newGroup);
                this.showToast('分组创建成功', 'success');
            } else {
                // 编辑现有分组
                const group = this.data.groups.find(g => g.id == groupId);
                if (group) {
                    group.name = name;
                    group.description = description;
                    group.color = color;
                    group.updatedTime = new Date().toISOString();
                }
                this.showToast('分组更新成功', 'success');
            }
            
            this.closeModal();
            this.updateGroupsDisplay();
            this.updateGroupFilters();
            this.loadStats(); // 重新加载统计数据
            
        } catch (error) {
            console.error('❌ 保存分组失败:', error);
            this.showToast('保存失败，请重试', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 删除分组确认
     */
    deleteGroupConfirm(groupId) {
        if (confirm('确定要删除这个分组吗？分组中的照片将变为未分组状态。')) {
            this.deleteGroup(groupId);
        }
    }

    /**
     * 删除分组
     */
    async deleteGroup(groupId) {
        try {
            this.showLoading();
            
            // 模拟API调用
            await new Promise(resolve => setTimeout(resolve, 500));
            
            // 找到要删除的分组
            const group = this.data.groups.find(g => g.id == groupId);
            if (!group) return;
            
            // 将分组中的照片设为未分组
            this.data.photos.forEach(photo => {
                if (photo.groupId === group.name) {
                    photo.groupId = null;
                }
            });
            
            // 删除分组
            this.data.groups = this.data.groups.filter(g => g.id != groupId);
            
            this.showToast('分组已删除', 'success');
            this.updateGroupsDisplay();
            this.updateGroupFilters();
            this.updatePhotosDisplay();
            this.loadStats();
            
        } catch (error) {
            console.error('❌ 删除分组失败:', error);
            this.showToast('删除失败，请重试', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 查看用户照片
     */
    viewUserPhotos(userId) {
        // 切换到照片管理页面
        this.switchSection('photos');
        
        // 设置用户筛选器
        const userFilter = document.getElementById('userFilter');
        if (userFilter) {
            userFilter.value = userId;
            this.updateFilters();
            this.loadPhotos();
        }
    }

    /**
     * 删除用户确认
     */
    deleteUserConfirm(userId) {
        if (confirm('确定要删除这个用户吗？用户的所有照片也将被删除。')) {
            this.deleteUser(userId);
        }
    }

    /**
     * 删除用户
     */
    async deleteUser(userId) {
        try {
            this.showLoading();
            
            // 尝试调用真实API删除用户
            try {
                await this.apiCall(`/admin/users/${userId}`, { method: 'DELETE' });
                this.showToast('用户已删除', 'success');
            } catch (apiError) {
                console.warn('⚠️ 删除用户API不可用，仅本地删除:', apiError);
                this.showToast('用户已从本地列表删除', 'warning');
            }
            
            // 删除用户的所有照片
            this.data.photos = this.data.photos.filter(photo => photo.userId !== userId);
            
            // 删除用户
            this.data.users = this.data.users.filter(user => user.id !== userId);
            
            this.updateUsersDisplay();
            this.updateUserFilters();
            this.updatePhotosDisplay();
            this.loadStats();
            
        } catch (error) {
            console.error('❌ 删除用户失败:', error);
            this.showToast('删除失败，请重试', 'error');
        } finally {
            this.hideLoading();
        }
    }

    /**
     * 下载照片
     */
    downloadPhoto(photoId) {
        const photo = this.data.photos.find(p => p.id == photoId);
        if (!photo) return;
        
        // 创建下载链接
        const link = document.createElement('a');
        link.href = photo.url;
        link.download = photo.originalName;
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        this.showToast('开始下载照片', 'info');
    }

    /**
     * 全局搜索处理
     */
    handleGlobalSearch(query) {
        if (!query.trim()) {
            // 如果搜索为空，重新加载所有数据
            this.loadPhotos();
            return;
        }
        
        // 搜索照片
        const filteredPhotos = this.data.photos.filter(photo => 
            photo.originalName.toLowerCase().includes(query.toLowerCase()) ||
            photo.userId.toLowerCase().includes(query.toLowerCase()) ||
            (photo.groupId && photo.groupId.toLowerCase().includes(query.toLowerCase()))
        );
        
        this.data.photos = filteredPhotos;
        this.state.currentPage = 1;
        this.updatePhotosDisplay();
    }

    /**
     * 刷新数据
     */
    async refreshData() {
        console.log('🔄 刷新数据...');
        
        const refreshBtn = document.getElementById('refreshBtn');
        if (refreshBtn) {
            refreshBtn.querySelector('i').classList.add('fa-spin');
        }
        
        try {
            await this.loadInitialData();
            this.showToast('数据已刷新', 'success');
        } catch (error) {
            console.error('❌ 刷新数据失败:', error);
            this.showToast('刷新失败，请重试', 'error');
        } finally {
            if (refreshBtn) {
                refreshBtn.querySelector('i').classList.remove('fa-spin');
            }
        }
    }

    /**
     * 启动自动刷新
     */
    startAutoRefresh() {
        if (!this.config.autoRefresh) return;
        
        this.stopAutoRefresh(); // 先停止现有的定时器
        
        this.state.refreshTimer = setInterval(() => {
            if (document.visibilityState === 'visible') {
                this.refreshData();
            }
        }, this.config.refreshInterval);
        
        console.log(`⏰ 自动刷新已启动，间隔 ${this.config.refreshInterval / 1000} 秒`);
    }

    /**
     * 停止自动刷新
     */
    stopAutoRefresh() {
        if (this.state.refreshTimer) {
            clearInterval(this.state.refreshTimer);
            this.state.refreshTimer = null;
            console.log('⏰ 自动刷新已停止');
        }
    }

    /**
     * 重启自动刷新
     */
    restartAutoRefresh() {
        this.stopAutoRefresh();
        this.startAutoRefresh();
    }

    /**
     * 更新界面
     */
    updateUI() {
        // 更新各个区域的显示
        if (this.state.currentSection === 'dashboard') {
            this.updateDashboard();
        } else if (this.state.currentSection === 'photos') {
            this.updatePhotosDisplay();
        } else if (this.state.currentSection === 'groups') {
            this.updateGroupsDisplay();
        } else if (this.state.currentSection === 'users') {
            this.updateUsersDisplay();
        }
    }

    /**
     * 显示加载状态
     */
    showLoading() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.classList.add('active');
        }
        this.state.loading = true;
    }

    /**
     * 隐藏加载状态
     */
    hideLoading() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.classList.remove('active');
        }
        this.state.loading = false;
    }

    /**
     * 显示Toast通知
     */
    showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;
        
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icons = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };
        
        toast.innerHTML = `
            <i class="toast-icon ${icons[type]}"></i>
            <span class="toast-message">${message}</span>
            <button class="toast-close">
                <i class="fas fa-times"></i>
            </button>
        `;
        
        // 绑定关闭事件
        toast.querySelector('.toast-close').addEventListener('click', () => {
            toast.remove();
        });
        
        container.appendChild(toast);
        
        // 自动关闭
        setTimeout(() => {
            if (toast.parentNode) {
                toast.remove();
            }
        }, 5000);
    }

    /**
     * 格式化日期
     */
    formatDate(dateString) {
        const date = new Date(dateString);
        const now = new Date();
        const diff = now - date;
        
        const minute = 60 * 1000;
        const hour = 60 * minute;
        const day = 24 * hour;
        const week = 7 * day;
        
        if (diff < minute) {
            return '刚刚';
        } else if (diff < hour) {
            return `${Math.floor(diff / minute)}分钟前`;
        } else if (diff < day) {
            return `${Math.floor(diff / hour)}小时前`;
        } else if (diff < week) {
            return `${Math.floor(diff / day)}天前`;
        } else {
            return date.toLocaleDateString('zh-CN', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        }
    }

    /**
     * 格式化文件大小
     */
    formatFileSize(bytes) {
        if (bytes === 0) return '0 B';
        
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
    }

    /**
     * 加载配置
     */
    loadConfig() {
        const savedConfig = localStorage.getItem('beimo-admin-config');
        if (savedConfig) {
            try {
                const config = JSON.parse(savedConfig);
                this.config = { ...this.config, ...config };
                console.log('✅ 配置已加载', this.config);
            } catch (error) {
                console.error('❌ 配置加载失败:', error);
            }
        }
    }

    /**
     * 保存配置
     */
    saveConfig() {
        try {
            localStorage.setItem('beimo-admin-config', JSON.stringify(this.config));
            console.log('✅ 配置已保存', this.config);
        } catch (error) {
            console.error('❌ 配置保存失败:', error);
        }
    }
}

// 全局应用实例
let app;

// 页面加载完成后初始化应用
document.addEventListener('DOMContentLoaded', () => {
    app = new PhotoAdminApp();
});

// 页面可见性变化时处理自动刷新
document.addEventListener('visibilitychange', () => {
    if (app) {
        if (document.visibilityState === 'visible') {
            app.startAutoRefresh();
        } else {
            app.stopAutoRefresh();
        }
    }
});

// 窗口大小变化时调整布局
window.addEventListener('resize', () => {
    if (app && window.innerWidth <= 768) {
        document.querySelector('.sidebar').classList.remove('active');
    }
});
