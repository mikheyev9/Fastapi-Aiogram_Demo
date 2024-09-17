
# Переменные
DOCKER_COMPOSE_FILE = docker-compose.yml
DOCKER_MIN_VERSION = 20.10

# Проверяем, установлен ли Docker
.PHONY: check_docker
check_docker:
	@echo "Проверка наличия Docker..."
	@if ! [ -x "$$(command -v docker)" ]; then \
		echo "Docker не найден. Установка Docker..."; \
		curl -fsSL https://get.docker.com -o get-docker.sh; \
		sh get-docker.sh; \
		rm get-docker.sh; \
	else \
		echo "Docker установлен."; \
	fi

# Проверяем версию Docker
.PHONY: check_docker_version
check_docker_version: check_docker
	@echo "Проверка версии Docker..."
	@DOCKER_VERSION=$$(docker --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'); \
		if [ $$(echo $$DOCKER_VERSION | cut -d. -f1) -lt $(shell echo $(DOCKER_MIN_VERSION) | cut -d. -f1) ]; then \
			echo "Docker версии $$DOCKER_VERSION слишком старый, обновляем Docker..."; \
			curl -fsSL https://get.docker.com -o get-docker.sh; \
			sh get-docker.sh; \
			rm get-docker.sh; \
		else \
			echo "Docker версии $$DOCKER_VERSION подходит."; \
		fi

# Запускаем Docker Compose с автоперезапуском контейнеров
.PHONY: up
up: check_docker_version
	@echo "Запуск контейнеров с Docker Compose..."
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d --force-recreate --build

# Останавливаем и удаляем контейнеры
.PHONY: down
down:
	@echo "Остановка контейнеров и удаление..."
	docker compose -f $(DOCKER_COMPOSE_FILE) down

# Просмотр логов
.PHONY: logs
logs:
	@echo "Отображение логов контейнеров..."
	docker compose -f $(DOCKER_COMPOSE_FILE) logs -f

# Перезапуск контейнеров
.PHONY: restart
restart:
	@echo "Перезапуск контейнеров..."
	docker compose -f $(DOCKER_COMPOSE_FILE) restart

# Проверка статуса контейнеров
.PHONY: status
status:
	@echo "Статус контейнеров:"
	docker compose -f $(DOCKER_COMPOSE_FILE) ps

# Установка Docker Compose (если отсутствует)
.PHONY: install_compose
install_compose:
	@if ! [ -x "$$(command -v docker-compose)" ]; then \
		echo "Docker Compose не найден. Установка Docker Compose..."; \
		curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose; \
		chmod +x /usr/local/bin/docker-compose; \
	else \
		echo "Docker Compose уже установлен."; \
	fi
