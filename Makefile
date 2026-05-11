.PHONY: all up down stop start clean fclean re status logs

all: up

up:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
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
	@sudo rm -rf /home/$(USER)/data

re: fclean all

SERVICES := $(filter-out $@,$(MAKECMDGOALS))

status:
	@cd srcs && docker-compose ps $(SERVICES)

logs:
	@cd srcs && docker-compose logs -f --tail=200 $(SERVICES)

%:
	@:s && docker-compose logs -f --tail=200 $(SERVICE)
