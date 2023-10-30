FROM mambaorg/micromamba:1.5

WORKDIR /app
COPY . /app
RUN micromamba install -y -n base -f /app/requirements.yml && \
    micromamba clean --all --yes

EXPOSE 5000

CMD ["python3", "server.py"]
