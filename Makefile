# Operation recipes for managing the projects and execution environment.
#
# This file is part of Enasis Network software eco-system. Distribution
# is permitted, for more information consult the project license file.
#
# This file is present within multiple projects, simplifying dependencies.



-include workspace.env



MAKE_PYTHON ?= /usr/bin/env python3

MAKE_COLOR ?= 6
MAKE_PRINT1 = @COLOR=$(MAKE_COLOR) $(MAKE_PYTHON) \
	-Bc 'import makefile; makefile.makeout("$(1)");'

MAKE_PRINT2 = $(call MAKE_PRINT1,<cD>><cL>>><cZ> $1)
MAKE_PRINT3 = $(call MAKE_PRINT1,  <cL>●<cZ>$1)
MAKE_PRINT4 = $(call MAKE_PRINT1,   $1)



.PHONY: help
help:
	@## Construct this helpful menu of recipes
	$(call MAKE_PRINT1,\n)
	@COLOR=$(MAKE_COLOR) ${MAKE_PYTHON} -B makefile.py
	$(call MAKE_PRINT1,\n)



-include Recipes/*/*.mk
-include Recipes/*.mk
-include workspace.mk



.PHONY: setup
setup:
	@## Setup relevant directories for projects
	@#
	$(call MAKE_PRINT2,<cD>make <cL>setup<cZ>\n)
	@#
	$(call MAKE_PRINT3,\
		<c37>Creating standard directories..<cZ>\n)
	@mkdir -p Configure
	@mkdir -p Execution
	@mkdir -p Override
	@mkdir -p Persistent
	@mkdir -p Projects
	@mkdir -p Temporary
	$(call MAKE_PRINT4, <cL>DONE<cZ>\n)
	@#
	$(MAKE) pyenv-install pyenv_version=3.9.13
	@ln -sr Execution/PyEnv/versions/3.9.13 \
		Execution/python39
	@#
	$(MAKE) pyenv-install pyenv_version=3.10.11
	@ln -sr Execution/PyEnv/versions/3.10.11 \
		Execution/python310
	@#
	$(MAKE) pyenv-install pyenv_version=3.11.4
	@ln -sr Execution/PyEnv/versions/3.11.4 \
		Execution/python311



.PHONY: pyenv-clone
pyenv-clone:
	@## Clone PyEnv repository to local directory
	@#
	$(call MAKE_PRINT2,<cD>make <cL>pyenv-clone<cZ>\n)
	@#
	$(call MAKE_PRINT3,\
		<c37>Cloning <c90>PyEnv<c37>..<cZ>\n)
	@if [ ! -d 'Execution/PyEnv' ]; then \
		git clone https://github.com/pyenv/pyenv.git \
		Execution/PyEnv 2>/dev/null; \
	fi
	$(call MAKE_PRINT4, <cL>DONE<cZ>\n)



.PHONY: pyenv-update
pyenv-update:
	@## Update local copy of PyEnv repository
	@#
	$(MAKE) pyenv-clone
	@#
	$(call MAKE_PRINT2,<cD>make <cL>pyenv-update<cZ>\n)
	@#
	$(call MAKE_PRINT3,\
		<c37>Updating <c90>PyEnv<c37>..<cZ>\n)
	@cd Execution/PyEnv \
		&& git remote update 1>/dev/null \
		&& git pull --rebase 1>/dev/null
	$(call MAKE_PRINT4, <cL>DONE<cZ>\n)



.PHONY: pyenv-remove
pyenv-remove:
	@## Remove local copy of PyEnv repository
	@#
	$(call MAKE_PRINT2,<cD>make <cL>pyenv-remove<cZ>\n)
	@#
	$(call MAKE_PRINT3,\
		<c37>Removing <c90>PyEnv<c37>..<cZ>\n)
	@rm -rf Execution/PyEnv
	$(call MAKE_PRINT4, <cL>DONE<cZ>\n)



.PHONY: pyenv-install
pyenv-install:
	@## Download and compile Python version
	@#
	$(MAKE) pyenv-update
	@#
	$(call MAKE_PRINT2,<cD>make <cL>pyenv-install<cZ>\n)
	@#
ifndef pyenv_version
	$(error pyenv_version variable is not defined)
endif
	@PYENV_ROOT=Execution/PyEnv \
		Execution/PyEnv/bin/pyenv \
		install $(pyenv_version)
	@Execution/PyEnv/versions/$(pyenv_version)/bin/python \
		-m pip install --upgrade pip
	@Execution/PyEnv/versions/$(pyenv_version)/bin/python \
		-m pip install pyyaml selinux



WKSP_BASE = $(WKSP_$(subst -,_,$(1))_BASE)
WKSP_PATH = $(WKSP_$(subst -,_,$(1))_PATH)
WKSP_FULL = $(call WKSP_BASE,$(1))/$(call WKSP_PATH,$(1))
WKSP_GITR = $(WKSP_$(subst -,_,$(1))_GITR)
WKSP_GITB = $(WKSP_$(subst -,_,$(1))_GITB)



define WKSP_MAKE

.PHONY: $(call WKSP_PATH,$(1))-make
$(call WKSP_PATH,$(1))-make: \
	.check-$(call WKSP_PATH,$(1))-make
	$(call MAKE_PRINT2,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-make<cZ>\n)
ifndef make_args
	@echo 'ERROR: make_args variable is not defined' >&2; exit 1
endif
	@cd $(call WKSP_FULL,$(1)) \
		&& MAKE_COLOR=$(MAKE_COLOR) \
			$(MAKE) $(make_args)

.check-$(call WKSP_PATH,$(1))-make: \
	$(call WKSP_FULL,$(1))/Makefile

endef



define WKSP_GIT_BASE

.PHONY: $(call WKSP_PATH,$(1))-git
$(call WKSP_PATH,$(1))-git: \
	.check-$(call WKSP_PATH,$(1))-git
	$(call MAKE_PRINT2,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-git<cZ>\n)
ifndef git_args
	@echo 'ERROR: git_args variable is not defined' >&2; exit 1
endif
	@cd $(call WKSP_FULL,$(1)) \
		&& git $(git_args)

.check-$(call WKSP_PATH,$(1))-git: \
	$(call WKSP_FULL,$(1))/.git

endef



define WKSP_GIT_REPO

.PHONY: $(call WKSP_PATH,$(1))-clone
$(call WKSP_PATH,$(1))-clone:
	$(call MAKE_PRINT2,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-clone<cZ>\n)
	@git clone\
		$(if $(call WKSP_GITB,$(1)),\
			-b $(call WKSP_GITB,$(1)))\
		$(call WKSP_GITR,$(1))\
		$(call WKSP_FULL,$(1))

.PHONY: $(call WKSP_PATH,$(1))-remove
$(call WKSP_PATH,$(1))-remove: \
	.check-$(call WKSP_PATH,$(1))-git
	$(call MAKE_PRINT2,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-remove<cZ>\n)
	@$(MAKE_PYTHON) -Bc 'if 1:\
		confirm = input("Are you sure? [y/N] ");\
		assert confirm == "y";'
	@rm -rf "$(call WKSP_FULL,$(1))"

endef



$(eval $(foreach x, \
		$(filter $(WKSP_PROJKEY),\
				$(WKSP_MEXTEND)), \
			$(call WKSP_MAKE,$(x))))

$(eval \
	$(foreach x,$(WKSP_PROJKEY), \
		$(if $(or $(call WKSP_GITB,$(x)),\
				$(call WKSP_GITR,$(x))),\
			$(call WKSP_GIT_BASE,$(x)))))

$(eval \
	$(foreach x,$(WKSP_PROJKEY), \
		$(if $(call WKSP_GITR,$(x)),\
			$(call WKSP_GIT_REPO,$(x)))))
