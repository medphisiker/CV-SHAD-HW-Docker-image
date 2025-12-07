# CV SHAD HW Docker image

Docker-образ представляет собой среду для запуска скриптов домашних заданий по курсу от ШАД "Компьютерное зрение" 2025 осень.

Не содежит исходных скриптов с файлами домашних заданий.

Представляет собой только удобную среду для запуска скриптов из примонтированной папки.

Предназначен для домашних работ:
- HW 5
- HW 6
- HW 7
- HW 8
- HW 9
- HW 10
- HW 11

В Docker-образе:
- реализована поддержка GPU.
- есть `uv venv` (`/opt/.venv`) в котором установлены все необходимые зависимости для проекта.

### Сборка образа

```bash
docker build -t cv-shad-hw5 .
```

Есть готовый образ на DockerHub:
```bash
docker pull medphisiker/cv-shad-hw5:latest
```

### Запуск проекта

```bash
# С GPU и монтированием текущей директории для разработки

# Windows PowerShell
docker run --gpus all -p 6006:6006 --shm-size=2g --rm -it -v "${PWD}:/app" medphisiker/cv-shad-hw5 sh

# Linux bash
docker run --gpus all -p 6006:6006 --shm-size=2g --rm -it -v "$(pwd):/app" medphisiker/cv-shad-hw5 sh
```

## Запуск unit-тестов

Запускаем Docker-контейнер и подключаемся к терминалу внутри него.

Рабочая директория у нас это `/app`.

Запуски тестов будут происходить из глобального python установленного в контейнере:
```
python run.py unittest <test_name>
```

Запуски скриптов:
```
python <scrypt_name>.py
```

### Запуск TensorBoard

Для просмотра на хосте используйте `http://localhost:6006` (порт публикуется с `-p 6006:6006`).

```
# запускаем tensorboard
tensorboard --load_fast=false --logdir=/app/experiments --host=0.0.0.0 --port=6006
```

На хосте откройте: http://localhost:6006

## Подключение как Git submodule

Этот репозиторий можно подключить как Git submodule в другие проекты для централизованного управления Docker-образом.

### Инструкция по подключению

1. Добавить submodule в ваш проект:
```bash
git submodule add git@github.com:medphisiker/CV-SHAD-HW-Docker-image.git projects_docker
```

2. Инициализировать и обновить submodule:
```bash
git submodule update --init --recursive
```

3. Для обновления submodule до последней версии:
```bash
cd projects_docker
git pull origin master
cd ..
git add projects_docker
git commit -m "Update projects_docker submodule"
```

### Преимущества использования submodule

- Централизованное управление Docker-образом
- Возможность обновления образа во всех проектах одновременно
- Сохранение истории изменений Docker-конфигурации
- Удобное переиспользование в разных проектах

### Отключение submodule

Если вам нужно удалить submodule из проекта:

```bash
# Удалить запись о submodule из .gitmodules
git submodule deinit -f projects_docker
git rm -f projects_docker
rm -rf .git/modules/projects_docker

# Удалить кэш submodule (опционально)
git rm --cached projects_docker
```