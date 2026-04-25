# 多阶段构建：下载模型 + 运行环境
# 阶段1：下载模型
FROM alpine:latest AS model-downloader

RUN apk add --no-cache wget unzip

WORKDIR /models

RUN wget -O LiYing_model.zip \
    "https://github.com/aoguai/LiYing/releases/download/v3.2.0/LiYing_model.zip" && \
    unzip LiYing_model.zip && \
    rm LiYing_model.zip && \
    ls -lh

# 阶段2：运行环境
FROM python:3.10-slim

WORKDIR /app

# 只安装最基础的依赖，不装图形库
RUN apt-get update && apt-get install -y \
    curl \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 修改 requirements.txt：将 opencv-python 替换为 opencv-python-headless
# 如果无法修改 requirements.txt，就在这里强制替换
RUN if grep -q "opencv-python" requirements.txt; then \
        sed -i 's/opencv-python/opencv-python-headless/g' requirements.txt; \
    fi

# 复制并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目代码
COPY . .

# 创建模型目录并从下载阶段复制模型
RUN mkdir -p /app/src/model
COPY --from=model-downloader /models/* /app/src/model/

RUN ls -lh /app/src/model/

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:7860 || exit 1

CMD ["python", "src/webui/app.py"]
