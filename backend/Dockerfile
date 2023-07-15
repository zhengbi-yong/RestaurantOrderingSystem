# backend/Dockerfile

# 使用一个官方的Python运行时作为父镜像
FROM python:3.9-slim-buster
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
    gcc \
    default-mysql-client \
    default-libmysqlclient-dev \
    pkg-config \
    libmariadb-dev-compat \
    vim \
    fonts-arphic-uming

# 设置工作目录
WORKDIR /app/backend

# 将当前目录内容复制到容器的工作目录
COPY . /app/backend

# 安装你需要的任何包
RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
RUN pip install gunicorn gevent gevent-websocket -i https://mirrors.aliyun.com/pypi/simple/

ENV FLASK_APP=run.py

# 让外界能够访问到你的应用，Flask默认监听的端口是5000
EXPOSE 5000

# 运行你的应用
# CMD ["flask", "run", "--host=0.0.0.0"]
CMD ["gunicorn", "-k", "geventwebsocket.gunicorn.workers.GeventWebSocketWorker", "-w", "1", "-b", "0.0.0.0:5000", "run:app"]
