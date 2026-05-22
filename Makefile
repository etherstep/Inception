.PHONY: all build up down stop start clean fclean re status logs

all: build

build:
	@cd srcs && docker-compose build

up:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@cd srcs && docker-compose up -d

down:
	@cd srcs && docker-compose down --remove-orphans

stop:
	@cd srcs && docker-compose stop

start:
	@cd srcs && docker-compose start

clean:
	@cd srcs && docker-compose down -v --rmi all --remove-orphans

fclean: clean
	@sudo rm -rf /home/$(USER)/data

re: down fclean all

KNOWN_TARGETS := all up down stop start clean fclean re status logs

SERVICES := $(filter-out $(KNOWN_TARGETS),$(MAKECMDGOALS))

status:
	@cd srcs && docker-compose ps $(SERVICES)

logs:
	@cd srcs && docker-compose logs -f --tail=200 $(SERVICES)

# No-op so extra words don't become "missing targets"
%:
	@:
