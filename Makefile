.PHONY: all up down stop start clean fclean re

all: up

up:
	@mkdir -p /home/inception/data/wordpress
	@mkdir -p /home/inception/data/mariadb
	@cd srcs && docker-compose up -d --build

down:
	@cd srcs && docker-compose down --remove-orphans

stop:
	@cd srcs && docker-compose stop

start:
	@cd srcs && docker-compose start

clean:
	@cd srcs && docker-compose down --rmi all --remove-orphans

fclean: clean
	@sudo rm -rf /home/inception/data

re: fclean all

