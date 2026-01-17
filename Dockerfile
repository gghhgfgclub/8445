FROM python:3.11-slim-bookworm as base

RUN apt-get update &&  \
    apt-get install --no-install-recommends -y \
    libcairo2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --shell /usr/sbin/nologin --create-home -d /opt/modmail modmail

FROM base as builder
COPY requirements.txt .
RUN pip install --root-user-action=ignore --no-cache-dir --upgrade pip wheel && \
    python -m venv /opt/modmail/.venv && \
    . /opt/modmail/.venv/bin/activate && \
    pip install --no-cache-dir --upgrade -r requirements.txt

FROM base
COPY --from=builder --chown=modmail:modmail /opt/modmail/.venv /opt/modmail/.venv
WORKDIR /opt/modmail
USER modmail:modmail
COPY --chown=modmail:modmail . .

# Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/opt/modmail/.venv/bin:$PATH \
    USING_DOCKER=yes \
    PORT=8080 

# Informamos el puerto que el hosting escaneará
EXPOSE 8080

CMD ["python", "bot.py"]
