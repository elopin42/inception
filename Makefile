
FOLDERS = $(home)/data/mariadb $(home)/data/wordpress
COMPOSE = docker-compose -f srcs/docker-compose.yml

.PHONY: all run logs clean fclean re dirs 

dirs: $(FOLDERS)

$(FOLDERS):
	mkdir -p $@

all: dirs
	$(COMPOSE) up --build

run:$(FOLDERS)
	$(COMPOSE) up -d

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v

flcnan: clean
	rm -rf $(FOLDERS)

re : fclean all
