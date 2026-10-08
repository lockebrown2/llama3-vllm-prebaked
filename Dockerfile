FROM vllm/vllm-openai:latest

# Install Hugging Face download tools
RUN pip install huggingface_hub[hf_transfer]

# Enable high-speed parallel chunk streaming
ENV HF_HUB_ENABLE_HF_TRANSFER=1

# Inject your token at build-time to pass the Llama-3 gate authorization
ARG HF_TOKEN
ENV HF_TOKEN=${HF_TOKEN}

# Pre-download the unquantized model layers straight into the Docker image filesystem
RUN python3 -c "from huggingface_hub import snapshot_download; \
    snapshot_download(repo_id='neuralmagic/Meta-Llama-3-8B-Instruct-FP8', local_dir='/app/model')"

# Tell the container to immediately host the model on port 8000 when booted
ENTRYPOINT ["python3", "-m vllm.entrypoints.openai.api_server", "--model", "/app/model", "--port", "8000"]
