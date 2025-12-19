FROM vastai/pytorch:latest

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /mnt/azureml/code

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements.gpu.txt /opt/requirements.gpu.txt
COPY requirements.app.txt /opt/requirements.app.txt

RUN pip install --no-cache-dir -r /opt/requirements.gpu.txt

RUN git clone https://github.com/FurkanGozukara/kohya_ss /opt/kohya_ss && \
    cd /opt/kohya_ss && git reset --hard && git pull && \
    git clone https://github.com/kohya-ss/sd-scripts /opt/kohya_ss/sd-scripts && \
    cd /opt/kohya_ss/sd-scripts && git reset --hard && git checkout sd3 && git pull

CMD ["bash", "-lc", "python --version && nvidia-smi || true && ls -la /opt/kohya_ss | head"]
