# 使用官方 Python 基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件并安装 Python 包
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目所有文件
COPY . .

# 创建模型目录并下载模型
# 注意：模型文件较大，建议放在 Docker 卷中缓存，或使用官方构建缓存
RUN mkdir -p /app/src/model
# 下载 RMBG 模型（可在此添加其他模型的下载命令）
# 这里仅为示例，具体链接请参考项目 README
ADD https://github.com/brunoos/BRIA-RMBG-1.4/raw/main/model.pth /app/src/model/RMBG-1.4.pth

# 暴露 WebUI 端口
EXPOSE 7860

# 健康检查（可选）
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl --fail http://localhost:7860 || exit 1

# 启动命令
CMD ["python", "src/webui/app.py"]
