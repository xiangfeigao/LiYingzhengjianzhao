# 多阶段构建：下载模型 + 运行环境
# 阶段1：下载模型
FROM alpine:latest AS model-downloader

RUN apk add --no-cache wget unzip

WORKDIR /models

# 下载官方打包的模型压缩包
RUN wget -O LiYing_model.zip \
    "https://github.com/aoguai/LiYing/releases/download/v3.2.0/LiYing_model.zip" && \
    unzip LiYing_model.zip && \
    rm LiYing_model.zip && \
    ls -lh

# 阶段2：运行环境
FROM python:3.10-slim

WORKDIR /app

# 安装 OpenCV 需要的系统依赖（修正：移除不存在的 libxcb-util1）
RUN apt-get update && apt-get install -y \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libxcb1 \
    libxcb-shm0 \
    libxcb-xfixes0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-xinerama0 \
    libxcb-xv0 \
    && rm -rf /var/lib/apt/lists/*

# 复制并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 创建模型目录并从下载阶段复制模型
RUN mkdir -p /app/src/model
COPY --from=model-downloader /models/* /app/src/model/

# 验证模型已经复制到位
RUN ls -lh /app/src/model/

# 暴露端口
EXPOSE 7860

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:7860 || exit 1

# 启动 WebUI
CMD ["python", "src/webui/app.py"]
