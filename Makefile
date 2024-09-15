# Operation recipes for managing the projects and execution environment.
#
# This file is part of Enasis Network software eco-system. Distribution
# is permitted, for more information consult the project license file.
#
# This file is present within multiple projects, simplifying dependency.



PYTHON ?= /usr/bin/env python3



-include workspace.env



MAKE_COLOR ?= 6

MAKE_PRINT = @COLOR=$(MAKE_COLOR) \
	$(PYTHON) -Bc 'if 1: \
		from makefile import makeout; \
		makeout("$(1)", "$(2)");'

MAKE_PR1NT = $(call MAKE_PRINT,$(1),text)
MAKE_PR2NT = $(call MAKE_PRINT,$(1),base)
MAKE_PR3NT = $(call MAKE_PRINT,$(1),more)



.PHONY: help
help:
	@## Construct this helpful menu of recipes
	$(call MAKE_PRINT)
	@COLOR=$(MAKE_COLOR) \
		$(PYTHON) -B makefile.py
	$(call MAKE_PRINT)



-include Recipes/*/*.mk
-include Recipes/*.mk
-include workspace.mk



.PHONY: setup
setup:
	@## Setup relevant directories for projects
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>setup<c0>)
	@#
	$(call MAKE_PR3NT,\
		<c37>Creating directories..<c0>)
	@mkdir -p Configure
	@mkdir -p Execution
	@mkdir -p Override
	@mkdir -p Persistent
	@mkdir -p Projects
	@mkdir -p Temporary
	$(call MAKE_PR1NT,<cD>DONE<c0>)
	@#
	$(MAKE) pyenv-install pyenv_version=3.9.18
	@ln -sr Execution/PyEnv/versions/3.9.18 \
		Execution/python39
	@#
	$(MAKE) pyenv-install pyenv_version=3.10.13
	@ln -sr Execution/PyEnv/versions/3.10.13 \
		Execution/python310
	@#
	$(MAKE) pyenv-install pyenv_version=3.11.8
	@ln -sr Execution/PyEnv/versions/3.11.8 \
		Execution/python311



.PHONY: pyenv-clone
pyenv-clone:
	@## Clone the PyEnv project into execution
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>pyenv-clone<c0>)
	@#
	$(call MAKE_PR3NT,\
		<c37>Cloning <c90>PyEnv<c37>\
		project repository..<c0>)
	@if [ ! -d 'Execution/PyEnv' ]; then \
		git clone https://github.com/pyenv/pyenv.git \
		Execution/PyEnv 2>/dev/null; \
	fi
	$(call MAKE_PR1NT,<cD>DONE<c0>)



.PHONY: pyenv-update
pyenv-update:
	@## Update local copy of PyEnv repository
	@#
	$(MAKE) pyenv-clone
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>pyenv-update<c0>)
	@#
	$(call MAKE_PR3NT,\
		<c37>Updating <c90>PyEnv<c37>\
		project repository..<c0>)
	@cd Execution/PyEnv \
		&& git remote update 1>/dev/null \
		&& git pull --rebase 1>/dev/null
	$(call MAKE_PR1NT,<cD>DONE<c0>)



.PHONY: pyenv-remove
pyenv-remove:
	@## Remove local copy of PyEnv repository
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>pyenv-remove<c0>)
	@#
	$(call MAKE_PR3NT,\
		<c37>Removing <c90>PyEnv<c37>\
		project repository..<c0>)
	@rm -rf Execution/PyEnv
	$(call MAKE_PR1NT,<cD>DONE<c0>)
	@#
	$(call MAKE_PR3NT,\
		<c37>Removing <c90>PyEnv<c37>\
		symbolic Python links..<c0>)
	@rm Execution/python39
	@rm Execution/python310
	@rm Execution/python311
	$(call MAKE_PR1NT,<cD>DONE<c0>)



.PHONY: pyenv-install
pyenv-install:
	@## Download and compile the Python version
	@#
	$(MAKE) pyenv-update
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>pyenv-install<c0>)
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
	$(call MAKE_PR1NT,<cD>DONE<c0>)



.PHONY: all-git
all-git:
	@## Interact with project Git repository
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>all-git<c0>)
	@#
	$(foreach p,$(WKSP_PROJKEY), \
		$(eval base_dir=$(call WKSP_BASE,$(p))) \
		$(call WKSP_GIT_CMDR,$(base_dir),$(p)))



.PHONY: all-make
all-make:
	@## Interact with project Makefile recipes
	@#
	$(call MAKE_PR2NT,\
		<cD>make <cL>all-make<c0>)
	@#
	$(foreach p,$(WKSP_PROJKEY), \
		$(eval base_dir=$(call WKSP_BASE,$(p))) \
		$(call WKSP_MAKE_CMDR,$(base_dir),$(p)))



WKSP_BASE = $(WKSP_$(subst -,_,$(1))_BASE)
WKSP_PATH = $(WKSP_$(subst -,_,$(1))_PATH)
WKSP_FULL = $(call WKSP_BASE,$(1))/$(call WKSP_PATH,$(1))
WKSP_GITR = $(WKSP_$(subst -,_,$(1))_GITR)
WKSP_GITB = $(WKSP_$(subst -,_,$(1))_GITB)



define WKSP_GIT_CMDR

@if [ -d "$(1)/$(2)/.git" ]; then \
	echo -e "\n\033[0;3$(MAKE_COLOR)m┍$$(printf '%.0s━' {1..63})\033[0m"; \
	echo -e "\033[0;3$(MAKE_COLOR)m│ $(1)/\033[0;9$(MAKE_COLOR)m$(2)\033[0m"; \
	echo -e "\033[0;3$(MAKE_COLOR)m├$$(printf '%.0s─' {1..63})\033[0m\n"; \
	(cd $(1)/$(2) && git $(git_args)); \
	echo -e "\n\033[0;3$(MAKE_COLOR)m┕$$(printf '%.0s━' {1..63})\033[0m\n"; \
fi

endef



define WKSP_MAKE_CMDR

@if [ -f "$(1)/$(2)/Makefile" ]; then \
	echo -e "\n\033[0;3$(MAKE_COLOR)m┍$$(printf '%.0s━' {1..63})\033[0m"; \
	echo -e "\033[0;3$(MAKE_COLOR)m│ $(1)/\033[0;9$(MAKE_COLOR)m$(2)\033[0m"; \
	echo -e "\033[0;3$(MAKE_COLOR)m├$$(printf '%.0s─' {1..63})\033[0m\n"; \
	(cd $(1)/$(2) && make $(make_args)); \
	echo -e "\n\033[0;3$(MAKE_COLOR)m┕$$(printf '%.0s━' {1..63})\033[0m\n"; \
fi

endef



define WKSP_MAKE

.PHONY: $(call WKSP_PATH,$(1))-make
$(call WKSP_PATH,$(1))-make: \
	.check-$(call WKSP_PATH,$(1))-make
	$(call MAKE_PR2NT,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-make<c0>)
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
	$(call MAKE_PR2NT,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-git<c0>)
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
	$(call MAKE_PR2NT,<cD>make\
		<cL>$(call WKSP_PATH,$(1))-clone<c0>)
	@git clone\
		$(if $(call WKSP_GITB,$(1)),\
			-b $(call WKSP_GITB,$(1)))\
		$(call WKSP_GITR,$(1))\
		$(call WKSP_FULL,$(1))

.PHONY: $(call WKSP_PATH,$(1))-remove
$(call WKSP_PATH,$(1))-remove: \
	.check-$(call WKSP_PATH,$(1))-git
	$(call MAKE_PR2NT,\
		<cD>make\
		<cL>$(call WKSP_PATH,$(1))-remove<c0>)
	@$(PYTHON) -Bc 'if 1:\
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
