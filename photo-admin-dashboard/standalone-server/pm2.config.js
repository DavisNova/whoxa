module.exports = {
  apps: [{
    name: 'photo-manager',
    script: 'photo-manager-app.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    env_development: {
      NODE_ENV: 'development',
      PORT: 3001
    },
    log_file: '/var/log/pm2/photo-manager.log',
    error_file: '/var/log/pm2/photo-manager-error.log',
    out_file: '/var/log/pm2/photo-manager-out.log',
    time: true
  }]
};
