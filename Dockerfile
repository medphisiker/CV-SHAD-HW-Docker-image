# Базовый образ с CUDA runtime + заголовками (devel)
FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# stdout/stderr без буферизации — удобно для логов в контейнерах
ENV PYTHONUNBUFFERED=1

ARG UV_VERSION=0.9.3

# явно отключаем компиляцию .py -> .pyc во время uv sync/установки
ENV UV_COMPILE_BYTECODE=0

# Устанавливаем системные утилиты и заголовки, часто нужные при сборке нативных wheel'ов
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates curl wget git build-essential pkg-config \
    ffmpeg \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev liblzma-dev libncurses-dev \
    libjpeg-dev libpng-dev \
    # пакеты, необходимые для сборки pycairo / pygobject / dbus-python
    libcairo2-dev libgirepository1.0-dev gobject-introspection gir1.2-gobject-2.0 \
    libglib2.0-dev libdbus-1-dev \
    # инструменты для meson/ninja/сборки
    meson ninja-build cmake \
    && add-apt-repository -y universe \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

# Установка uv напрямую через официальный install.sh (pin версии)
# Используем URL с версией: https://astral.sh/uv/<version>/install.sh
# запускаем установщик под root и ставим в /usr/local/bin (глобально)
RUN set -x \
    && curl -fsSL "https://astral.sh/uv/${UV_VERSION}/install.sh" -o /tmp/uv-install.sh \
    && chmod +x /tmp/uv-install.sh \
    && UV_INSTALL_DIR="/usr/local/bin" /tmp/uv-install.sh \
    && rm -f /tmp/uv-install.sh

# Убедимся, что uv установлен
RUN uv --version

WORKDIR /app

# копируем только описания зависимостей
COPY pyproject.toml uv.lock ./

# Устанавливаем Python 3.12 через uv и синхронизируем зависимости.
# --default делает python/ python3 исполняемыми в uv-managed python
# Создаём venv сразу в /opt/.venv
RUN uv python install --default 3.12 \
    && uv venv /opt/.venv \
    && UV_PROJECT_ENVIRONMENT=/opt/.venv uv sync --frozen \
    && chmod -R a+rX /opt/.venv

# Экспорт окружения
ENV VIRTUAL_ENV=/opt/.venv
ENV UV_PROJECT_ENVIRONMENT=/opt/.venv
ENV PATH="/opt/.venv/bin:$PATH"

# Файлы проекта не копируем, контейнер просто среда для разработки и тестирования.
# COPY . .

# Будем запускать свои команды
CMD ["sh"]
