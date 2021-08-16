.PHONY: init
init:
	scripts/prepare.sh $$(pwd)

.PHONY: install
        install:
	scripts/install.sh

.PHONY: destroy
destroy:
	scripts/destroy.sh

.PHONY: test
test:
	scripts/test.sh test/recipes/oisst_recipe.py