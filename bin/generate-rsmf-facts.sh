#!/usr/bin/env bash

# This script is executed by the Makefile before generating the configurations from migration.rsmf-defn.jsonnet
# Expecting environment variables upon entry:
# RSMF_VERSION
# RSMF_HOME
# RSMF_LOG_LEVEL
# RSMF_FACTS_FILES
# RDBMS_ENGINE_TARGET
# RDBMS_DIALECT_TARGET
# MIGRATION_DEFN_HOME
# MIGRATION_NAME
# MAKEFILE_CUSTOM_PRE_CONFIGURE_SCRIPT_NAME
# MAKEFILE_CUSTOM_POST_CONFIGURE_SCRIPT_NAME
# MAKEFILE_CUSTOM_INCLUDE_FILE
# OSQUERY_CONFIG_PATH
# OSQUERY_CONFIG_D_PATH
# JSONNET_PATH
# DEST_PATH

DEST_PATH_RELATIVE=`realpath --relative-to="$MIGRATION_DEFN_HOME" "$DEST_PATH"`
DEST_FILE_EXTN=.rsmf-facts.json
GREEN=`tput -Txterm setaf 2`
YELLOW=`tput -Txterm setaf 3`
WHITE=`tput -Txterm setaf 7`
RESET=`tput -Txterm sgr0`

if [ ! -d "$DEST_PATH" ]; then
    echo "A RSMF migration definition facts destination directory path is expected as DEST_PATH."
    exit 1
fi

logInfo() {
	if [ "$RSMF_LOG_LEVEL" = 'INFO' ]; then
		echo "$1"
	fi
}

osqueryFactsSingleRow() {
    logInfo "Running osQuery single row, saving to ${YELLOW}$DEST_PATH_RELATIVE/$1$DEST_FILE_EXTN${RESET}: ${GREEN}$2${RESET}"
	osqueryi --json "$2" | jq '.[0]' > $DEST_PATH/$1$DEST_FILE_EXTN
}

osqueryFactsMultipleRows() {
    logInfo "Running osQuery multi row, saving to ${YELLOW}$DEST_PATH_RELATIVE/$1$DEST_FILE_EXTN${RESET}: ${GREEN}$2${RESET}"
	osqueryi --json "$2" > $DEST_PATH/$1$DEST_FILE_EXTN
}

shellEvalFacts() {
	destFile=$DEST_PATH/$1$DEST_FILE_EXTN
	touch $destFile
	existingValues=$(<$destFile)
	if [ -z "$existingValues" ]; then
	    logInfo "Running shell eval, saving to ${YELLOW}$DEST_PATH_RELATIVE/$1$DEST_FILE_EXTN${RESET}: ${WHITE}$2${RESET} ${GREEN}$3${RESET}"
		existingValues="{}"
	else
	    logInfo "Running shell eval, appending to ${YELLOW}$DEST_PATH_RELATIVE/$1$DEST_FILE_EXTN${RESET}: ${WHITE}$2${RESET} ${GREEN}$3${RESET}"
	fi
	textValue=`eval $3`;	
	echo $existingValues | jq --arg key "$2" --arg value "$textValue" '. + {($key) : $value}' > $destFile
}

generateFacts() {
	logInfo "Generating facts from ${GREEN}$1${RESET} into ${YELLOW}$DEST_PATH_RELATIVE${RESET} using JSONNET_PATH ${GREEN}$JSONNET_PATH${RESET}"
	jsonnet $1 | jq -r '.osQueries.singleRow[] | "osqueryFactsSingleRow \(.name) \"\(.query)\""' | source /dev/stdin
	jsonnet $1 | jq -r '.osQueries.multipleRows[] | "osqueryFactsMultipleRows \(.name) \"\(.query)\""' | source /dev/stdin
	jsonnet $1 | jq -r '.shellEvals[] | "shellEvalFacts \(.name) \(.key) \"\(.evalAsTextValue)\""' | source /dev/stdin
}

IFS=':' read -ra FF <<< "$RSMF_FACTS_FILES"
 for ff in "${FF[@]}"; do
     if [ -f "$ff" ]; then
         generateFacts "$ff"
     else
         logInfo "Skipping facts file ${YELLOW}$ff${RESET} from RSMF_FACTS_FILES, does not exist."
     fi
 done

CONTEXT_FACTS_JSONNET_TMPL=${CONTEXT_FACTS_JSONNET_TMPL:-$RSMF_HOME/etc/context.rsmf-facts.rsmf-tmpl.jsonnet}
CONTEXT_FACTS_GENERATED_FILE=${CONTEXT_FACTS_GENERATED_FILE:-context.rsmf-facts.json}

jsonnet --ext-str RSMF_VERSION=$RSMF_VERSION \
		--ext-str RSMF_HOME=$RSMF_HOME \
		--ext-str RSMF_LOG_LEVEL=$RSMF_LOG_LEVEL \
		--ext-str RSMF_FACTS_FILES=$RSMF_FACTS_FILES \
		--ext-str RSMF_FACTS_DEST_PATH=$DEST_PATH \
		--ext-str GENERATED_ON="`date`" \
		--ext-str JSONNET_PATH=$JSONNET_PATH \
		--ext-str migrationName=$MIGRATION_NAME \
		--ext-str migrationDefnHome=$MIGRATION_DEFN_HOME \
		--ext-str rdbmsEngineTarget=$RDBMS_ENGINE_TARGET  \
		--ext-str rdbmsDialectTarget=$RDBMS_DIALECT_TARGET  \
		--ext-str makeFileCustomPreConfigureScriptName=$MAKEFILE_CUSTOM_PRE_CONFIGURE_SCRIPT_NAME \
		--ext-str makeFileCustomPostConfigureScriptName=$MAKEFILE_CUSTOM_POST_CONFIGURE_SCRIPT_NAME \
		--ext-str makeFileCustomTargetsIncludeFile=$MAKEFILE_CUSTOM_INCLUDE_FILE \
		--ext-str osQueryConfigPath=$OSQUERY_CONFIG_PATH \
		--ext-str osQueryConfigDPath=$OSQUERY_CONFIG_D_PATH \
		--ext-str currentUserName="`whoami`" \
		--ext-str currentUserId="`id -u`" \
		--ext-str currentUserGroupId="id -g" \
		--ext-str currentUserHome=$HOME \
		--output-file $DEST_PATH/$CONTEXT_FACTS_GENERATED_FILE \
		$CONTEXT_FACTS_JSONNET_TMPL

logInfo "Generated ${YELLOW}$CONTEXT_FACTS_GENERATED_FILE${RESET} from ${GREEN}$CONTEXT_FACTS_JSONNET_TMPL${RESET}"
