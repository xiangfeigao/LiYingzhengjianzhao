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
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# 下载模型（可选，也可以让用户运行时挂载）
RUN mkdir -p /app/src/model && \
    wget -O /tmp/models.zip \
    "https://github.com/aoguai/LiYing/releases/download/v3.2.0/LiYing_model.zip" && \
    unzip /tmp/models.zip -d /app/src/model/ && \
    rm /tmp/models.zip

EXPOSE 7860

CMD ["python3", "src/webui/app.py"]
