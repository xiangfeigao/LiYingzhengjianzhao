FROM python:3.11-slim

# 跳过 apt-get，直接用 pip 安装依赖
WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir \
    "onnxruntime>=1.17.0" \
    "orjson>=3.9.15" \
    "gradio>=4.19.2" \
    -r requirements.txt

COPY . .

EXPOSE 7860

CMD ["python", "src/webui/app.py", "--server_name", "0.0.0.0", "--server_port", "7860"]
