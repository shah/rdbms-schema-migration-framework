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

	migrationName : std.extVar('migrationName'),
	migrationDefnHome : std.extVar('migrationDefnHome'),
	rdbmsEngineTarget : std.extVar('rdbmsEngineTarget'),

	currentUser : {
		name : std.extVar('currentUserName'),
		id : std.extVar('currentUserId'),
		groupId : std.extVar('currentUserGroupId'),
		home : std.extVar('currentUserHome')
	},
}
