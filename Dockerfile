# 设置基础映像
FROM python:3.9-slim

# 安装所需的系统依赖项
RUN apt-get update && apt-get install -y libbz2-dev liblzma-dev libsqlite3-dev libssl-dev zlib1g-dev

# 设置工作目录
WORKDIR /app

# 复制应用程序文件到容器中
COPY . /app

# 安装Python依赖项
RUN pip install --no-cache-dir -r requirements.txt

# 构建Flutter应用程序
RUN curl -sL https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.8.1-stable.tar.xz | tar xJ
ENV PATH="/app/flutter/bin:${PATH}"
RUN flutter pub get
RUN flutter build web

# 设置环境变量
ENV FLASK_APP=app.py

# 暴露端口
EXPOSE 5000

# 启动应用程序
CMD ["python", "app.py"]
