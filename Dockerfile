# 多阶段构建：下载模型 + 运行环境
# 阶段1：下载模型
FROM alpine:latest AS model-downloader

RUN apk add --no-cache wget

WORKDIR /models

# 下载 Yunet 模型 (~3 MB)
RUN wget -O face_detection_yunet_2023mar.onnx \
    "https://github.com/opencv/opencv_zoo/raw/main/models/face_detection_yunet/face_detection_yunet_2023mar.onnx"

# 下载 RMBG 模型 (~176 MB)
RUN wget -O RMBG-1.4-model.onnx \
    "https://huggingface.co/brunoais/BRIA-RMBG-1.4/resolve/main/model.onnx"

# 下载 YOLOv8n-pose 模型 (~6.5 MB)
RUN wget -O yolov8n-pose.onnx \
    "https://github.com/ultralytics/assets/releases/download/v8n/yolov8n-pose.onnx"

# 验证下载
RUN ls -lh && \
    echo "Models downloaded successfully"

# 阶段2：运行环境
FROM python:3.10-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
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
