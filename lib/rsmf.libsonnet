local DIALECT_DEFAULT = 'ansi';

{
	columnTypes : {
		identity(name = 'id') : { 
			name: name, 
			notNull: true, 
			sqlType(dialect = DIALECT_DEFAULT): "SERIAL",
			columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s INTEGER PRIMARY KEY AUTOINCREMENT" % { name : name },
		},
		text(name, size = 255, required = false) : { 
			name: name, 
			notNull: required, 
			size : size,
			columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s VARCHAR(%(size)d)%(required)s" % {name : name, size : size, required: if required then ' NOT NULL' else ''},
		},
		integer(name, required = false) : { 
			name: name, 
			notNull: required, 
			columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s INTEGER%(required)s" % {name : name, required: if required then ' NOT NULL' else ''},
		},
                datetime(name, required = false) : {
                        name: name,
                        notNull: required,
                        columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s DATETIME%(required)s" % {name : name, required: if required then ' NOT NULL' else ''},
                },
		enum(enumName, name = enumName + "_id", required = false) : {
			name : name,
			enumName : enumName,
			foreignKey: { parentTable: enumName, parentColumn: 'id' },
			columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s INTEGER%(required)s" % { name : name, required: if required then ' NOT NULL' else ''},			
			foreignKeySqlForCreateTable(dialect = DIALECT_DEFAULT): "FOREIGN KEY(%(name)s) REFERENCES %(parentTable)s(%(parentColumn)s)" % { name : name, parentTable: enumName, parentColumn: 'id' },
		},
		// TODO: create type that looks up the reference table in migration.tables and finds proper type, name, etc. and hooks up like Axiom used to
		// foreignKey(migration, refTableName, refColumnName, name = refColumnName, required = false) : {  
		// 	name : thisColumnName, 
		// 	columnSqlForCreateTable(dialect = DIALECT_DEFAULT): "%(name)s SQL for CREATE TABLE not implemented yet" % { name : std.asciiUpper(name) },
		// },
	},

	tableTypes : {
		typical(name, columns) : { 
			name: name, 
			columns: columns,
		},
		enum(name, data) : { 
			name: name, 
			columns: [
				$.columnTypes.identity(),
				$.columnTypes.text('code', required = true),
				$.columnTypes.text('value', required = true),
				$.columnTypes.text('abbrev'),
			], 
			data: data,
		},
	},

	createTablesSQL(migration, dialect = DIALECT_DEFAULT) : std.lines([
		"CREATE TABLE %(name)s (\n    %(columnsSQL)s\n);\n" % { 
			name : std.asciiUpper(table.name), 
			columnsSQL : std.join(", \n    ", 
				[c.columnSqlForCreateTable(dialect) for c in table.columns] +
				[c.foreignKeySqlForCreateTable(dialect) for c in $.tableForeignKeyColumns(table)]
			)
		} for table in migration.tables]
	),

	createSQLValue(value)::
		if std.isBoolean(value) then
			'' + value
		else if std.isNumber(value) then
			'' + value
		else 
			std.escapeStringJson(value),

	columnIsForeignKey(column)::
		if std.objectHas(column, 'foreignKey') then
			true
		else
			false,

	tableForeignKeyColumns(table)::
		local fkeyCols = std.filter($.columnIsForeignKey, table.columns);
		if std.length(fkeyCols) > 0 then
			fkeyCols
		else
			[],

	tableHasData(table)::
		if std.objectHas(table, 'data') then
			true
		else
			false,

	createTableRowInsertSQL(table, dataRows) : std.lines(["INSERT INTO %(tableName)s (%(columnNames)s) VALUES (%(columnValues)s);" % {
		tableName : std.asciiUpper(table),
		columnNames : std.join(", ", [std.asciiUpper(columnName) for columnName in std.objectFields(row)]),
		columnValues : std.join(", ", [$.createSQLValue(row[columnName]) for columnName in std.objectFields(row)]),
	} for row in dataRows]),

	createDataSQL(migration) : std.lines(std.flattenArrays([
		[$.createTableRowInsertSQL(table.name, table['data']) for table in std.filter($.tableHasData, migration.tables)],
		[$.createTableRowInsertSQL(tableName, migration.data[tableName]) for tableName in std.objectFields(migration.data)]
	])),

	osQueryConfigATC(migration, pathSpec) : std.manifestJsonEx({
		auto_table_construction : {
			[table.name] : {
				query : "select %(columns)s FROM %(tableName)s" % { tableName: table.name, columns: std.join(', ', [column.name for column in table.columns]) },
				path : pathSpec % migration,
				columns : [column.name for column in table.columns]
			} for table in migration.tables
		}
	}, "    ")
}
