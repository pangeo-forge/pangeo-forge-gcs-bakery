.PHONY: init
init:
	/bin/bash -c "source scripts/prepare.sh"

.PHONY: install
        install:
	scripts/install.sh

.PHONY: destroy
destroy:
	scripts/destroy.sh
