all:
	docker-compose -f srcs/docker-compose.yml up --build

clean:
	docker-compose -f srcs/docker-compose.yml down -v

re : clean all
