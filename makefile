-include config.mk

RPI_UPSTREAM_DIR	= rpi-upstream
RPI_MINIMAL_DIR		= rpi-minimal
RPI_INCUS_DIR		= rpi-incus

usage: 
	@echo "RPi Void Linux image maker by nixsalad"
	@echo "-------------------------------------"
	@echo "This tool uses drist to run the build on a remote server"
	@echo "and copy the image back to the local client"
	@echo ""
	@echo "Tell make what build server to use like so: "
	@echo "  echo \"SERVER=user@build-server\" > config.mk"
	@echo ""
	@echo "Or just specify the build server on the command line: "
	@echo "  make <target> SERVER=user@build-server"
	@echo ""
	@echo "The same goes for embedding ssh keys into images: "
	@echo "  make <target> SERVER=user@build-server SSH_KEY=~.ssh/id_ed25519.pub"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> <SERVER> [SSH_KEY]"
	@echo ""
	@echo "Targets:"
	@echo "  - rpi-upstream, rpi-minimal, rpi-incus"
	@echo ""
	@echo "Examples:"
	@echo "  make rpi-upstream SERVER=void@192.34.56.171"
	@echo "  make rpi-minimal SERVER=void@192.34.56.171"
	@echo "  make rpi-incus SERVER=builder SSH_KEY=~/.ssh/id_ed25519.pub"

rpi-upstream: 
	cd $(RPI3_UPSTREMINIMALAM_DIR) && drist -p -s $(SERVER)
rpi-minimal: 
	cd $(RPI3_MINIMAL_DIR) && drist -p -s $(SERVER)
rpi-incus: 
	mkdir -p $(RPI3_INCUS_DIR)/files/ssh_keys && cp $(SSH_KEY) $(RPI3_INCUS_DIR)/files/ssh_keys/
	cd $(RPI3_INCUS_DIR) && drist -p -s $(SERVER)
	-rm -rf $(RPI3_INCUS_DIR)/files/ssh_keys/

clean: 
	find . -type d -name 'ssh_keys' | xargs rm -rf
	-rm -rf results config.mk 

.PHONY: rpi-upstream rpi-minimal rpi-incus
