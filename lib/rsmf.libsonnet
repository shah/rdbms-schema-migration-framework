
{
	bashSnippets : {
		preamble(context) : |||
			#!/usr/bin/env bash
		|||,

		waitForMigrationStatus(context, status) : |||
			printf "Waiting until %(migrationName)s is '%(status)s'."
			while [ $(docker inspect --format "{{json .State.Status }}" %(migrationName)s) != "\"%(status)s\"" ]; do printf "."; sleep 1; done
			echo " Done."
		||| % { migrationName : context.migrationName, status : status },

		waitForMigrationHealthStatus(context, status) : |||
			printf "Waiting until %(migrationName)s is '%(status)s'."
			while [ $(docker inspect --format "{{json .State.Health.Status }}" %(migrationName)s) != "\"%(status)s\"" ]; do printf "."; sleep 1; done
			echo " Done."
		||| % { migrationName : context.migrationName, status : status },

		waitForMigrationLogMessage(context, logMessage) : |||
			#!/bin/bash
			printf "Waiting until %(migrationName)s is healthy via log output."
			docker logs -f %(migrationName)s | while read LOGLINE
			do
				if [[ ${LOGLINE} = *"%(logMessage)s"* ]]; then
				break
				fi
			done
			echo ""
			echo "%(logMessage)s"
		||| % { migrationName : context.migrationName, logMessage : logMessage },

		openHostFirewallPortName(context, portName) : |||
			sudo ufw allow %(portName)s
		||| % { portName : portName },

		openHostFirewallPortNumber(context, port) : |||
			sudo ufw allow %(port)d
		||| % { port : port },
	},

	makeTargets : {
		// make sure tabs are used because Makefile's are quite finicky
		firewall(context, ports) : |||
			## Check the firewall status for this migration
			firewall:
				sudo ufw status verbose
		|||,
	},

	shellScripts: {
		waitForTCPPortAvailability: importstr "wait-for-tcp-port-availability.sh"
	},
}