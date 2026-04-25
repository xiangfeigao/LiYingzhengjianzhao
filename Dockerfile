FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# 强制重新安装，清除缓存，并验证版本
RUN pip3 install --no-cache-dir --force-reinstall -r requirements.txt && \
    pip3 show gradio | grep Version

COPY . .

RUN mkdir -p /app/src/model && \
    wget -O /tmp/models.zip \
    "https://github.com/aoguai/LiYing/releases/download/v3.2.0/LiYing_model.zip" && \
    unzip /tmp/models.zip -d /app/src/model/ && \
    rm /tmp/models.zip

EXPOSE 7860

CMD ["python3", "src/webui/app.py"]
