# flutter_app/Dockerfile

# 使用官方的Nginx镜像
FROM nginx:stable

# 将构建的网页应用复制到Nginx的默认目录
COPY build/web/ /usr/share/nginx/html

# Nginx监听的端口
EXPOSE 80
