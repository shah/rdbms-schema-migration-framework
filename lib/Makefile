# This is considered a "typical" migration Makefile and is designed to be 
# symlink'd from a migration directory as "Makefile"
# All useful variables that can be overridden in the environment start with RSMF_*

RSMF_VERSION := 1.0.0
SHELL := /bin/bash
MAKEFLAGS := silent

CURRENT_DIR_PATH := $(shell echo `pwd`)
CURRENT_DIR_NAME := $(shell basename `pwd`)

MIGRATION_NAME := $(CURRENT_DIR_NAME)
MIGRATION_DEFN_HOME := $(CURRENT_DIR_PATH)

RSMF_HOME ?= /opt/rdbms-schema-migration-framework
RSMF_LOG_LEVEL ?= "NONE"
RSMF_FACTS_FILES ?= $(RSMF_HOME)/etc/common.rsmf-factsgen.jsonnet:$(MIGRATION_DEFN_HOME)/migration.rsmf-factsgen.jsonnet
JSONNET_PATH ?= $(HOME)/.rsmf/secrets:$(HOME)/.rsmf/etc:$(RSMF_HOME)/lib:$(RSMF_HOME)/etc

# This is the primary JSonnet configuration file, it creates all the migration's
# definition and configuration files using Jsonnet -m (multi-file) strategy.
RSMF_MIGRATION_DEFN_JSONNET ?= migration.rsmf-defn.jsonnet

# This file holds the list of files generated by the jsonnet --multi command
MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST := .rsmf_migration.rsmf-defn.jsonnet_generated
DELETE_GENERATED_FILES_SCRIPT := .rsmf_delete_generated_files.sh

CUSTOM_PRE_CONFIGURE_SCRIPT_NAME := ./before_configure.make-plugin.sh
CUSTOM_POST_CONFIGURE_SCRIPT_NAME := ./after_configure.make-plugin.sh
CUSTOM_INCLUDE_FILE := ./migration.make.inc

# This is the "environment facts bootstrap" script which figures out what's in the
# runtime environment and stores that data in the destination path. That destination
# path is then available in JSONNET_PATH for use in migration.rsmf-defn.jsonnet.
RSMF_FACTS_GENERATOR_SCRIPT ?= $(RSMF_HOME)/bin/generate-rsmf-facts.sh
RSMF_FACTS_DEST_PATH ?= $(MIGRATION_DEFN_HOME)/.rsmf_facts
RSMF_FACTS_DEST_PATH_RELATIVE ?= $(shell realpath --relative-to=$(MIGRATION_DEFN_HOME) $(RSMF_FACTS_DEST_PATH))

OSQUERY_CONFIG_PATH ?= /etc/osquery/osquery.conf
OSQUERY_CONFIG_D_PATH ?= /etc/osquery/osquery.conf.d

GREEN    := $(shell tput -Txterm setaf 2)
YELLOW   := $(shell tput -Txterm setaf 3)
WHITE    := $(shell tput -Txterm setaf 7)
RESET    := $(shell tput -Txterm sgr0)
REDFLASH := $(shell tput -Txterm setaf 4)

comma := ,
define logInfo
	if [ "$(RSMF_LOG_LEVEL)" = 'INFO' ]; then
		echo "$1"
	fi
endef

default: help

.ONESHELL:
pre-configure:
	mkdir -p $(RSMF_FACTS_DEST_PATH)
	if [ -f $(CUSTOM_PRE_CONFIGURE_SCRIPT_NAME) ]; then
		$(call logInfo,Running custom pre-configuration script $(GREEN)$(CUSTOM_POST_CONFIGURE_SCRIPT_NAME)$(RESET) for $(GREEN)$(MIGRATION_NAME)$(RESET))
		sudo chmod +x $(CUSTOM_PRE_CONFIGURE_SCRIPT_NAME)
		$(CUSTOM_PRE_CONFIGURE_SCRIPT_NAME) $(MIGRATION_NAME)
	fi

.ONESHELL:
generate-facts: pre-configure
	$(call logInfo,Running $(GREEN)$(RSMF_FACTS_GENERATOR_SCRIPT)$(RESET)$(comma) dest $(YELLOW)$(RSMF_FACTS_DEST_PATH_RELATIVE)$(RESET))
	RSMF_VERSION=$(RSMF_VERSION) RSMF_HOME=$(RSMF_HOME) RSMF_FACTS_FILES=$(RSMF_FACTS_FILES) RSMF_LOG=$(RSMF_LOG) \
	    MIGRATION_DEFN_HOME=$(MIGRATION_DEFN_HOME) MIGRATION_NAME=$(MIGRATION_NAME) \
		RDBMS_ENGINE_TARGET=$(RDBMS_ENGINE_TARGET) RDBMS_DIALECT_TARGET=$(RDBMS_DIALECT_TARGET) \
		MAKEFILE_CUSTOM_PRE_CONFIGURE_SCRIPT_NAME=$(CUSTOM_PRE_CONFIGURE_SCRIPT_NAME) \
		MAKEFILE_CUSTOM_POST_CONFIGURE_SCRIPT_NAME=$(CUSTOM_POST_CONFIGURE_SCRIPT_NAME) \
		MAKEFILE_CUSTOM_INCLUDE_FILE=$(CUSTOM_INCLUDE_FILE) \
		OSQUERY_CONFIG_PATH=$(OSQUERY_CONFIG_PATH) \
		OSQUERY_CONFIG_D_PATH=$(OSQUERY_CONFIG_D_PATH) \
	    JSONNET_PATH="$(JSONNET_PATH)" DEST_PATH=$(RSMF_FACTS_DEST_PATH) \
		bash $(RSMF_FACTS_GENERATOR_SCRIPT)

.ONESHELL:
generate-migration-conf: generate-facts
	JSONNET_PATH="$(JSONNET_PATH)" \
			jsonnet --jpath $(RSMF_FACTS_DEST_PATH) \
					-S --multi . $(RSMF_MIGRATION_DEFN_JSONNET) > $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST)
	
	$(call logInfo,Generated migration definitions from $(GREEN)$(RSMF_MIGRATION_DEFN_JSONNET)$(RESET) (cached in $(YELLOW)$(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST)$(RESET)):)
	if [ "$(RSMF_LOG_LEVEL)" = 'INFO' ]; then
		cat $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST)  | sed 's/^\.\//$(RESET)  > $(YELLOW)/'
		echo "$(RESET)"
	fi
	$(call logInfo,Created $(YELLOW).gitignore$(RESET) to prevent tracking of generated files)
	echo "# Generated by Makefile. DO NOT EDIT" > .gitignore
	echo $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST) >> .gitignore
	echo $(DELETE_GENERATED_FILES_SCRIPT) >> .gitignore
	echo $(RSMF_FACTS_DEST_PATH_RELATIVE) >> .gitignore
	cat $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST) | sed 's/^\.\///' >> .gitignore
	cat $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST) | sed 's/^/rm -f /' > $(DELETE_GENERATED_FILES_SCRIPT)

clean-generated-migration-conf:
	bash $(DELETE_GENERATED_FILES_SCRIPT)
	$(call logInfo,Ran $(YELLOW)$(DELETE_GENERATED_FILES_SCRIPT)$(RESET))
	rm -f $(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST)
	rm -f $(DELETE_GENERATED_FILES_SCRIPT)
	$(call logInfo,Deleted $(YELLOW)$(MIGRATION_DEFN_JSONNET_GENERATED_FILES_LIST)$(RESET) and $(YELLOW)$(DELETE_GENERATED_FILES_SCRIPT)$(RESET))
	rm -rf $(RSMF_FACTS_DEST_PATH)
	$(call logInfo,Deleted $(YELLOW)$(RSMF_FACTS_DEST_PATH_RELATIVE)$(RESET))

.ONESHELL:
## Generate all migration artifacts from Jsonnet config
configure: generate-migration-conf
	if [ -f $(CUSTOM_POST_CONFIGURE_SCRIPT_NAME) ]; then
		$(call logInfo,Running custom post-configuration script $(CUSTOM_POST_CONFIGURE_SCRIPT_NAME) for $(MIGRATION_NAME))
		sudo chmod +x $(CUSTOM_POST_CONFIGURE_SCRIPT_NAME)
		$(CUSTOM_POST_CONFIGURE_SCRIPT_NAME) $(MIGRATION_NAME)
	fi

## Opposite of configure, remove all generated artifacts and "reset" directory
clean: clean-generated-migration-conf

## See if all developer dependencies are installed
check-dependencies: check-jsonnet check-jq check-osquery check-sqlite
	printf "$(GREEN)[*]$(RESET) "
	make -v | head -1
	echo "$(GREEN)[*]$(RESET) Shell: $$SHELL"

JSONNET_INSTALLED := $(shell command -v jsonnet 2> /dev/null)
check-jsonnet:
ifndef JSONNET_INSTALLED
	echo "$(REDFLASH)[ ]$(RESET) Did not find jsonnet, run this to set it up:"
	echo "    sudo ln -s $(RSMF_HOME)/bin/jsonnet-v0.11.2 /usr/bin/jsonnet"
else
	printf "$(GREEN)[*]$(RESET) "
	jsonnet --version
endif

JQ_INSTALLED := $(shell command -v jq 2> /dev/null)
check-jq:
ifndef JQ_INSTALLED
	echo "$(REDFLASH)[ ]$(RESET) Did not find jq, install using:"
	echo "    sudo apt-get install jq"
else
	printf "$(GREEN)[*]$(RESET) "
	jq --version
endif

SQLITE_INSTALLED := $(shell command -v sqlite 2> /dev/null)
SQLITE3_INSTALLED := $(shell command -v sqlite3 2> /dev/null)
check-sqlite:
ifndef SQLITE_INSTALLED
	echo "$(REDFLASH)[ ]$(RESET) Did not find sqlite, install using:"
	echo "    sudo apt-get install sqlite"
else
	printf "$(GREEN)[*]$(RESET) SQLite "
	sqlite -version
endif
ifndef SQLITE3_INSTALLED
	echo "$(REDFLASH)[ ]$(RESET) Did not find sqlite3, install using:"
	echo "    sudo apt-get install sqlite3"
else
	printf "$(GREEN)[*]$(RESET) SQLite3 "
	sqlite3 -version
endif

OSQUERY_INSTALLED := $(shell command -v osqueryd 2> /dev/null)
check-osquery: 
ifndef OSQUERY_INSTALLED
	echo "$(REDFLASH)[ ]$(RESET) Unable to find osquery, install it from https://osquery.io/downloads/official."
else
	printf "$(GREEN)[*]$(RESET) "
	osqueryd --version
	printf "    $(GREEN)[*]$(RESET) "
	osqueryi --version
	if [ -d $(OSQUERY_CONFIG_PATH) ]; then echo "    $(GREEN)[*]$(RESET) $(OSQUERY_CONFIG_PATH) exists"; else echo "    $(REDFLASH)[ ]$(RESET) $(OSQUERY_CONFIG_PATH) does not exist, please setup"; fi
	if [ -d $(OSQUERY_CONFIG_D_PATH) ]; then echo "    $(GREEN)[*]$(RESET) $(OSQUERY_CONFIG_D_PATH) exists"; else printf "    $(REDFLASH)[ ]$(RESET) $(OSQUERY_CONFIG_D_PATH) does not exist, please create directory using:\n        $(YELLOW)sudo mkdir -p $(OSQUERY_CONFIG_D_PATH)$(RESET)\n"; fi
endif

TARGET_MAX_CHAR_NUM=15
# All targets should have a ## Help text above the target and they'll be automatically collected
# Show help, using auto generator from https://gist.github.com/prwhite/8168133
help:
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${WHITE}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''
	@echo "NOTE: targets defined in $(CUSTOM_INCLUDE_FILE) are not shown because that file could be generated."
	@echo ''
	@echo '${YELLOW}JSONNET_PATH${RESET}=${GREEN}$(JSONNET_PATH)${RESET}'
	@echo '${YELLOW}RSMF_HOME${RESET}=${GREEN}$(RSMF_HOME)${RESET}'
	@echo '${YELLOW}RSMF_FACTS_FILES${RESET}=${GREEN}$(RSMF_FACTS_FILES)${RESET}'
	@echo '${YELLOW}RSMF_FACTS_GENERATOR_SCRIPT${RESET}=${GREEN}$(RSMF_FACTS_GENERATOR_SCRIPT)${RESET}'
	@echo '${YELLOW}RSMF_LOG_LEVEL${RESET}=${GREEN}$(RSMF_LOG_LEVEL)${RESET}'

ifneq ("$(wildcard $(CUSTOM_INCLUDE_FILE))","")
include $(CUSTOM_INCLUDE_FILE)
endif

