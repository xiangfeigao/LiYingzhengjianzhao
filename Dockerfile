FROM python:3.11-slim

# 替换为清华源，并增加重试
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-glx \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir \
    "onnxruntime>=1.17.0" \
    "orjson>=3.9.15" \
    "gradio>=4.19.2" \
    -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY . .

EXPOSE 7860

CMD ["python", "src/webui/app.py", "--server_name", "0.0.0.0", "--server_port", "7860"]
