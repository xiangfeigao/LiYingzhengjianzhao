FROM ubuntu:22.04

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    git \
    wget \
    unzip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 模型下载（如果需要）
# 可以保持原来的多阶段下载，也可以让用户手动挂载

# 暴露端口
EXPOSE 7860

# 启动命令
CMD ["python3", "src/webui/app.py"]
