// This is a template for the migration.conf.jsonnet file that is generated
// automatically for each schema migration.
{
	RSMF_VERSION : std.extVar('RSMF_VERSION'),
	RSMF_HOME : std.extVar('RSMF_HOME'),
	RSMF_FACTS_FILES : std.extVar('RSMF_FACTS_FILES'),
	RSMF_FACTS_DEST_PATH : std.extVar('RSMF_FACTS_DEST_PATH'),
	RSMF_LOG_LEVEL : std.extVar('RSMF_LOG_LEVEL'),
	
	GENERATED_ON : std.extVar('GENERATED_ON'),
	JSONNET_PATH : std.extVar('JSONNET_PATH'),

	makeFile : {
		customPreConfigureScriptName : std.extVar('makeFileCustomPreConfigureScriptName'),
		customPostConfigureScriptName : std.extVar('makeFileCustomPostConfigureScriptName'),
		customTargetsIncludeFile : std.extVar('makeFileCustomTargetsIncludeFile'),
	},

	migrationName : std.extVar('migrationName'),
	migrationDefnHome : std.extVar('migrationDefnHome'),

	rdbms : {
		engineTarget : std.extVar('rdbmsEngineTarget'),
		dialectTarget : std.extVar('rdbmsDialectTarget'),
	},

	osQuery : {
		configPath : std.extVar('osQueryConfigPath'),
		configDPath : std.extVar('osQueryConfigDPath'),
	},

	currentUser : {
		name : std.extVar('currentUserName'),
		id : std.extVar('currentUserId'),
		groupId : std.extVar('currentUserGroupId'),
		home : std.extVar('currentUserHome')
	},
}
