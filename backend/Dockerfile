# flask_app/Dockerfile

# 使用一个官方的Python运行时作为父镜像
FROM python:3.9-slim-buster

# 设置工作目录
WORKDIR /app

# 将当前目录内容复制到容器的工作目录
COPY . /app

# 安装你需要的任何包
RUN pip install --no-cache-dir -r requirements.txt

# 让外界能够访问到你的应用，Flask默认监听的端口是5000
EXPOSE 5000

# 定义环境变量
ENV FLASK_APP=run.py

# 运行你的应用
CMD ["flask", "run", "--host=0.0.0.0"]
