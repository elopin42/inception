
FOLDERS = ~/data/mariadb ~/data/wordpress

$(FOLDERS):
	mkdir -p $@

all:$(FOLDERS)
	docker-compose -f srcs/docker-compose.yml up --build

logs:
	docker-compose -f srcs/docker-compose.yml logs

clean:
	docker-compose -f srcs/docker-compose.yml down -v

re : clean all
