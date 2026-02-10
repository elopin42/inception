COMPOSE = docker-compose -f srcs/docker-compose.yml
FOLDERS = $(HOME)/data/mariadb $(HOME)/data/wordpress

.PHONY: all run logs clean fclean re dirs

dirs: $(FOLDERS)

$(FOLDERS):
	mkdir -p $@

all: dirs
	$(COMPOSE) up --build

run: dirs
	$(COMPOSE) up -d

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v

fclean: clean
	sudo rm -rf $(FOLDERS)

re: fclean all
