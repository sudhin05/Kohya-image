FROM vastai/pytorch:latest

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /mnt/azureml/code

# --- system deps ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    ffmpeg \
    build-essential \
    bzip2 \
    python3 \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# --- install Miniconda so AzureML "build on compute" (mutated_conda_dependencies.yml) works ---
# AzureML auto-generated Dockerfile will run:
#   conda --version
#   conda env create ...
# so conda MUST exist in the base image.
ENV CONDA_DIR=/opt/conda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm -f /tmp/miniconda.sh && \
    ${CONDA_DIR}/bin/conda config --set channel_priority strict && \
    ${CONDA_DIR}/bin/conda clean -ay
ENV PATH=${CONDA_DIR}/bin:$PATH

# --- pip tooling (keep using pip for your deps as before) ---
RUN python -m pip install --upgrade pip setuptools wheel

COPY requirements.gpu.txt /opt/requirements.gpu.txt
COPY requirements.app.txt /opt/requirements.app.txt

# GPU/runtime deps
RUN pip install --no-cache-dir -r /opt/requirements.gpu.txt

# (Optional) If you actually need app deps in the image, uncomment:
RUN pip install --no-cache-dir -r /opt/requirements.app.txt

# --- kohya setup ---
RUN git clone https://github.com/FurkanGozukara/kohya_ss /opt/kohya_ss && \
    cd /opt/kohya_ss && git reset --hard && git pull && \
    git clone https://github.com/kohya-ss/sd-scripts /opt/kohya_ss/sd-scripts && \
    cd /opt/kohya_ss/sd-scripts && git reset --hard && git checkout sd3 && git pull

# quick sanity output
CMD ["bash", "-lc", "python --version && conda --version && nvidia-smi || true && ls -la /opt/kohya_ss | head"]

