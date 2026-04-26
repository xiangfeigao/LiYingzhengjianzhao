FROM ubuntu:22.04

# 安装系统依赖（包含 OpenCV 所需的所有图形库）
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3-pip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 创建 Python 软链接
RUN ln -s /usr/bin/python3.11 /usr/bin/python

WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 暴露端口
EXPOSE 7860

# 启动命令
CMD ["python3", "src/webui/app.py", "--server_name", "0.0.0.0", "--server_port", "7860"]
