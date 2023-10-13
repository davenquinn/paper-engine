INSTALL_DIR := /usr/local/bin

install:
	@echo "Installing..."
	@mkdir -p $(INSTALL_DIR)
	ln -s $(shell pwd)/bin/paper $(INSTALL_DIR)/paper

docker_container:
	@echo "Building docker container..."
	@docker build -t paper-components .
