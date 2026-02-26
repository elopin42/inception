COMPOSE = docker-compose -f srcs/docker-compose.yml
FOLDERS = $(HOME)/data/mariadb $(HOME)/data/wordpress
HOST_ENTRY = 127.0.0.1 $(DOMAIN_NAME)

.PHONY: all run logs clean fclean re dirs hosts

all: dirs hosts
	$(COMPOSE) up --build

dirs: $(FOLDERS)

$(FOLDERS):
	mkdir -p $@

hosts:
	@grep -qF "$(HOST_ENTRY)" /etc/hosts || echo "$(HOST_ENTRY)" | sudo tee -a /etc/hosts

run: dirs
	$(COMPOSE) up -d

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v

fclean: clean
	sudo rm -rf $(FOLDERS)

re: fclean all
