/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 *
 *  Reference:
 *  http://www.postgresql.org/docs/9.3/static/sql-syntax-lexical.html
 */
parser grammar PostgreSqlParser;

options {
	tokenVocab = PostgreSqlLexer;
}

//
// Compilation units
//

compilationUnit
	:	command* EOF
	;

notImplemented
	//:	. {throw new UnsupportedOperationException("Not yet implemented.");}
	:	~Semicolon+ {System.out.println("Not yet implemented.");}
	;

ellipsisNotImplemented
	:	. notImplemented
	;

//
// Expressions
//

arrayElement
	:	expression
	|	LeftBracket (arrayElement (Comma arrayElement)*)? RightBracket
	;

expression
	:	valueExpression
	;

valueExpression
	:	// a constant or literal value
		stringConstant
	|	numericConstant
	|	type stringConstant
	|	stringConstant Colon Colon type
	|	CAST LeftParen stringConstant AS type RightParen

	|	// a column reference
		(correlation Period)? columnName

	|	// a positional parameter reference, in the body of a function definition or prepared statement
		Dollar Integral

	|	// A subscripted expression
		valueExpression LeftBracket valueExpression (Colon valueExpression)? RightBracket

	|	// A field selection expression
		valueExpression Period fieldName
	|	// TODO?
		valueExpression Period Asterisk

	|	// An operator invocation
		valueExpression operator valueExpression?
	|	operator valueExpression

	|	// A function call
		functionName LeftParen (argument (Comma argument)*)? RightParen

	|	// An aggregate expression
		aggregateName
		LeftParen
		(	(ALL | DISTINCT)? expression (Comma expression)* orderByClause?
		|	Asterisk
		)
		RightParen

	|	// A window function call
		functionName
		(	LeftParen (expression (Comma expression)*)? RightParen
		|	LeftParen Asterisk RightParen
		)
		OVER
		(	windowName
		|	LeftParen windowDefinition RightParen
		)

	|	// A type cast
		CAST LeftParen expression AS type RightParen
	|	valueExpression Colon Colon type

	|	// A collation expression
		valueExpression COLLATE collation

	|	// A scalar subquery
		LeftParen selectStatement RightParen

	|	// An array constructor
		ARRAY LeftBracket (arrayElement (Comma arrayElement)*)? RightBracket
	|	ARRAY LeftParen selectStatement RightParen

	|	// A row constructor
		ROW LeftParen (expression (Comma expression)*)? RightParen
	|	LeftParen expression (Comma expression)+ RightParen

	|	// Another value expression in parentheses (used to group subexpressions and override precedence)
		LeftParen valueExpression RightParen

	|	// TODO: still need to figure out exactly where each of these goes...
		NULL
	|	booleanValue
	|	CURRENT_DATE
	|	CURRENT_USER
	|	CURRENT_TIME

	|	caseExpression

	|	// http://www.postgresql.org/docs/9.3/static/functions-string.html
		SUBSTRING LeftParen valueExpression FROM valueExpression RightParen
	|	TRIM LeftParen (LEADING | TRAILING | BOTH) StringConstant? FROM valueExpression RightParen

	|	// http://www.postgresql.org/docs/9.3/static/functions-subquery.html
		EXISTS LeftParen selectStatement RightParen
	;

// http://www.postgresql.org/docs/9.3/static/functions-conditional.html
caseExpression
	:	CASE expression?
		(	WHEN condition THEN expression
		)+
		(	ELSE expression
		)?
		END
	;

//
// Common
//

aggregateName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

aggregateType
	:	type
	;

alias
	:	identifier
	;

argname
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

argtype
	:	type
	;

argument
	:	VARIADIC? (argname NamedArgument)? expression
	;

booleanValue
	:	TRUE
	|	FALSE
	|	Integral
	|	// ON/OFF/YES/NO work for Boolean values in the in the SET command
		ON
	|	OFF
	|	YES
	|	NO
	;

channel
	:	identifier
	;

code
	:	notImplemented
	;

collation
	:	notImplemented
	;

columnAlias
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

columnDefinition
	:	notImplemented
	;

columnName
	:	(	identifier
		|	nonReservedKeywordNotFunctionOrType
		)
		(	// documentation for INSERT says column name can include a subscript
			LeftBracket valueExpression (Colon valueExpression)? RightBracket
		)*
		(	Period fieldName
		)*
	;

condition
	:	expression
	;

configurationParameter
	:	identifier (Period identifier)*
	;

configurationValue
	:	value (Comma value)*
	;

constraintName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

correlation
	:	tableName
	|	schemaName Period tableName
	;

count
	:	notImplemented
	;

cursorName
	:	notImplemented
	;

dataType
	:	notImplemented
	;

domainConstraint
	:	notImplemented
	;

event
	:	SELECT
	|	INSERT
	|	UPDATE
	|	DELETE
	;

existingWindowName
	:	notImplemented
	;

fieldName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

frameClause
	:	(RANGE | ROWS)? frameStart
	|	(RANGE | ROWS)? BETWEEN frameStart AND frameEnd
	;

frameEnd
	:	UNBOUNDED PRECEDING
	|	value PRECEDING
	|	CURRENT ROW
	|	value FOLLOWING
	|	UNBOUNDED FOLLOWING
	;

frameStart
	:	UNBOUNDED PRECEDING
	|	value PRECEDING
	|	CURRENT ROW
	|	value FOLLOWING
	|	UNBOUNDED FOLLOWING
	;

functionName
	:	identifier
	|	reservedKeywordFunctionOrType
	;

identifier
	:	Identifier
	|	QuotedIdentifier
	|	UnicodeQuotedIdentifier
	|	nonReservedKeyword
	;

indexMethod
	:	notImplemented
	;

indexName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

joinColumn
	:	columnName
	;

joinCondition
	:	condition
	;

label
	:	notImplemented
	;

langName
	:	notImplemented
	;

largeObjectOid
	:	notImplemented
	;

leftType
	:	notImplemented
	;

name
	:	notImplemented
	;

newConstraintName
	:	notImplemented
	;

newOwner
	:	notImplemented
	;

newName
	:	notImplemented
	;

newRole
	:	notImplemented
	;

newSchema
	:	notImplemented
	;

numericConstant
	:	Integral
	|	Numeric
	;

objectName
	:	notImplemented
	;

oldRole
	:	notImplemented
	;

operator
	:	operatorName
	|	AND
	|	OR
	|	NOT
	|	OPERATOR LeftParen schemaName Period operatorName RightParen
	|	IS NOT? DISTINCT FROM
	|	IS NOT? UNKNOWN
	;

operatorName
	:	Operator
	|	Asterisk
	|	Equal
	|	ISNULL
	|	NOTNULL
	|	IS
	|	IN
	|	BETWEEN
	|	OVERLAPS
	|	LIKE
	|	ILIKE
	|	SIMILAR
	|	ANY
	|	ALL
	|	SOME
	;

orderByClause
	:	notImplemented
	;

outputExpression
	:	notImplemented
	;

asOutputName
	:	AS? identifier
	|	AS? nonReservedKeywordNotFunctionOrType
	|	AS reservedKeywordFunctionOrType
	|	AS reservedKeyword
	;

parameter
	:	notImplemented
	;

payload
	:	notImplemented
	;

provider
	:	notImplemented
	;

rightType
	:	notImplemented
	;

roleName
	:	notImplemented
	;

ruleName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

savepointName
	:	notImplemented
	;

schemaName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

serverName
	:	notImplemented
	;

sessionId
	:	notImplemented
	;

snapshotId
	:	notImplemented
	;

sortExpression
	:	notImplemented
	;

sourceType
	:	type
	;

start
	:	notImplemented
	;

stringConstant
	:	StringConstant
	|	EscapeStringConstant
	|	BinaryStringConstant
	|	HexadecimalStringConstant
	|	UnicodeEscapeStringConstant
	|	BeginDollarStringConstant Text* EndDollarStringConstant
	;

tableName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	;

targetType
	:	type
	;

timezone
	:	notImplemented
	;

transactionId
	:	notImplemented
	;

userName
	:	identifier
	|	nonReservedKeywordNotFunctionOrType
	|	stringConstant
	;

usingList
	:	notImplemented
	;

value
	:	valueExpression
	;

windowDefinition
	:	existingWindowName?
		(	PARTITION BY expression (Comma expression)*
		)?
		(	ORDER BY expression (ASC | DESC | USING operator)? (NULLS (FIRST | LAST))? ellipsisNotImplemented
		)?
		frameClause?
	;

windowName
	:	identifier
	;

withQueryName
	:	identifier
	;

reservedKeyword
	:	ALL
	|	ANALYSE
	|	ANALYZE
	|	AND
	|	ANY
	|	ARRAY
	|	AS
	|	ASC
	|	ASYMMETRIC
	|	BOTH
	|	CASE
	|	CAST
	|	CHECK
	|	COLLATE
	|	COLUMN
	|	CONSTRAINT
	|	CREATE
	|	CURRENT_CATALOG
	|	CURRENT_DATE
	|	CURRENT_ROLE
	|	CURRENT_TIME
	|	CURRENT_TIMESTAMP
	|	CURRENT_USER
	|	DEFAULT
	|	DEFERRABLE
	|	DESC
	|	DISTINCT
	|	DO
	|	ELSE
	|	END
	|	EXCEPT
	|	FALSE
	|	FETCH
	|	FOR
	|	FOREIGN
	|	FROM
	|	GRANT
	|	GROUP
	|	HAVING
	|	IN
	|	INITIALLY
	|	INTERSECT
	|	INTO
	|	LATERAL
	|	LEADING
	|	LIMIT
	|	LOCALTIME
	|	LOCALTIMESTAMP
	|	NOT
	|	NULL
	|	OFFSET
	|	ON
	|	ONLY
	|	OR
	|	ORDER
	|	PLACING
	|	PRIMARY
	|	REFERENCES
	|	RETURNING
	|	SELECT
	|	SESSION_USER
	|	SOME
	|	SYMMETRIC
	|	TABLE
	|	THEN
	|	TO
	|	TRAILING
	|	TRUE
	|	UNION
	|	UNIQUE
	|	USER
	|	USING
	|	VARIADIC
	|	WHEN
	|	WHERE
	|	WINDOW
	|	WITH
	;

reservedKeywordFunctionOrType
	:	AUTHORIZATION
	|	BINARY
	|	COLLATION
	|	CONCURRENTLY
	|	CROSS
	|	CURRENT_SCHEMA
	|	FREEZE
	|	FULL
	|	ILIKE
	|	INNER
	|	IS
	|	ISNULL
	|	JOIN
	|	LEFT
	|	LIKE
	|	NATURAL
	|	NOTNULL
	|	OUTER
	|	OVER
	|	OVERLAPS
	|	RIGHT
	|	SIMILAR
	|	VERBOSE
	;

nonReservedKeyword
	:	ABORT
	|	ABSOLUTE
	|	ACCESS
	|	ACTION
	|	ADD
	|	ADMIN
	|	AFTER
	|	AGGREGATE
	|	ALSO
	|	ALTER
	|	ALWAYS
	|	ASSERTION
	|	ASSIGNMENT
	|	AT
	|	ATTRIBUTE
	|	BACKWARD
	|	BEFORE
	|	BEGIN
	|	BY
	|	CACHE
	|	CALLED
	|	CASCADE
	|	CASCADED
	|	CATALOG
	|	CHAIN
	|	CHARACTERISTICS
	|	CHECKPOINT
	|	CLASS
	|	CLOSE
	|	CLUSTER
	|	COMMENT
	|	COMMENTS
	|	COMMIT
	|	COMMITTED
	|	CONFIGURATION
	|	CONNECTION
	|	CONSTRAINTS
	|	CONTENT
	|	CONTINUE
	|	CONVERSION
	|	COPY
	|	COST
	|	CSV
	|	CURRENT
	|	CURSOR
	|	CYCLE
	|	DATA
	|	DATABASE
	|	DAY
	|	DEALLOCATE
	|	DECLARE
	|	DEFAULTS
	|	DEFERRED
	|	DEFINER
	|	DELETE
	|	DELIMITER
	|	DELIMITERS
	|	DICTIONARY
	|	DISABLE
	|	DISCARD
	|	DOCUMENT
	|	DOMAIN
	|	DOUBLE
	|	DROP
	|	EACH
	|	ENABLE
	|	ENCODING
	|	ENCRYPTED
	|	ENUM
	|	ESCAPE
	|	EVENT
	|	EXCLUDE
	|	EXCLUDING
	|	EXCLUSIVE
	|	EXECUTE
	|	EXPLAIN
	|	EXTENSION
	|	EXTERNAL
	|	FAMILY
	|	FIRST
	|	FOLLOWING
	|	FORCE
	|	FORWARD
	|	FUNCTION
	|	FUNCTIONS
	|	GLOBAL
	|	GRANTED
	|	HANDLER
	|	HEADER
	|	HOLD
	|	HOUR
	|	IDENTITY
	|	IF
	|	IMMEDIATE
	|	IMMUTABLE
	|	IMPLICIT
	|	INCLUDING
	|	INCREMENT
	|	INDEX
	|	INDEXES
	|	INHERIT
	|	INHERITS
	|	INLINE
	|	INPUT
	|	INSENSITIVE
	|	INSERT
	|	INSTEAD
	|	INVOKER
	|	ISOLATION
	|	KEY
	|	LABEL
	|	LANGUAGE
	|	LARGE
	|	LAST
	|	LC_COLLATE
	|	LC_CTYPE
	|	LEAKPROOF
	|	LEVEL
	|	LISTEN
	|	LOAD
	|	LOCAL
	|	LOCATION
	|	LOCK
	|	MAPPING
	|	MATCH
	|	MATERIALIZED
	|	MAXVALUE
	|	MINUTE
	|	MINVALUE
	|	MODE
	|	MONTH
	|	MOVE
	|	NAME
	|	NAMES
	|	NEXT
	|	NO
	|	NOTHING
	|	NOTIFY
	|	NOWAIT
	|	NULLS
	|	OBJECT
	|	OF
	|	OFF
	|	OIDS
	|	OPERATOR
	|	OPTION
	|	OPTIONS
	|	OWNED
	|	OWNER
	|	PARSER
	|	PARTIAL
	|	PARTITION
	|	PASSING
	|	PASSWORD
	|	PLANS
	|	PRECEDING
	|	PREPARE
	|	PREPARED
	|	PRESERVE
	|	PRIOR
	|	PRIVILEGES
	|	PROCEDURAL
	|	PROCEDURE
	|	PROGRAM
	|	QUOTE
	|	RANGE
	|	READ
	|	REASSIGN
	|	RECHECK
	|	RECURSIVE
	|	REF
	|	REFRESH
	|	REINDEX
	|	RELATIVE
	|	RELEASE
	|	RENAME
	|	REPEATABLE
	|	REPLACE
	|	REPLICA
	|	RESET
	|	RESTART
	|	RESTRICT
	|	RETURNS
	|	REVOKE
	|	ROLE
	|	ROLLBACK
	|	ROWS
	|	RULE
	|	SAVEPOINT
	|	SCHEMA
	|	SCROLL
	|	SEARCH
	|	SECOND
	|	SECURITY
	|	SEQUENCE
	|	SEQUENCES
	|	SERIALIZABLE
	|	SERVER
	|	SESSION
	|	SET
	|	SHARE
	|	SHOW
	|	SIMPLE
	|	SNAPSHOT
	|	STABLE
	|	STANDALONE
	|	START
	|	STATEMENT
	|	STATISTICS
	|	STDIN
	|	STDOUT
	|	STORAGE
	|	STRICT
	|	STRIP
	|	SYSID
	|	SYSTEM
	|	TABLES
	|	TABLESPACE
	|	TEMP
	|	TEMPLATE
	|	TEMPORARY
	|	TEXT
	|	TRANSACTION
	|	TRIGGER
	|	TRUNCATE
	|	TRUSTED
	|	TYPE
	|	TYPES
	|	UNBOUNDED
	|	UNCOMMITTED
	|	UNENCRYPTED
	|	UNKNOWN
	|	UNLISTEN
	|	UNLOGGED
	|	UNTIL
	|	UPDATE
	|	VACUUM
	|	VALID
	|	VALIDATE
	|	VALIDATOR
	|	VALUE
	|	VARYING
	|	VERSION
	|	VIEW
	|	VOLATILE
	|	WHITESPACE
	|	WITHOUT
	|	WORK
	|	WRAPPER
	|	WRITE
	|	XML
	|	YEAR
	|	YES
	|	ZONE

	// The following *act* as non-reserved keywords, but only exist in the lexer due
	// to their context-sensitive use in parser rules.
	|	BUFFERS
	|	COSTS
	|	FORMAT
	|	PUBLIC
	|	TIMING
	;

nonReservedKeywordNotFunctionOrType
	:	BETWEEN
	|	BIGINT
	|	BIT
	|	BOOLEAN
	|	CHAR
	|	CHARACTER
	|	COALESCE
	|	DEC
	|	DECIMAL
	|	EXISTS
	|	EXTRACT
	|	FLOAT
	|	GREATEST
	|	INOUT
	|	INT
	|	INTEGER
	|	INTERVAL
	|	LEAST
	|	NATIONAL
	|	NCHAR
	|	NONE
	|	NULLIF
	|	NUMERIC
	|	OUT
	|	OVERLAY
	|	POSITION
	|	PRECISION
	|	REAL
	|	ROW
	|	SETOF
	|	SMALLINT
	|	SUBSTRING
	|	TIME
	|	TIMESTAMP
	|	TREAT
	|	TRIM
	|	VALUES
	|	VARCHAR
	|	XMLATTRIBUTES
	|	XMLCONCAT
	|	XMLELEMENT
	|	XMLEXISTS
	|	XMLFOREST
	|	XMLPARSE
	|	XMLPI
	|	XMLROOT
	|	XMLSERIALIZE
	;

//
// Types
//


// http://www.postgresql.org/docs/9.3/static/datatype.html
type
	:	arrayType
	|	typeNotArrayType
	;

typeNotArrayType
	:	numericType
	//|	monetaryType
	|	characterType
	//|	binaryType
	|	datetimeType
	|	booleanType
	//|	enumeratedType
	//|	geometricType
	//|	networkAddressType
	|	bitStringType
	//|	textSearchType
	|	uuidType
	|	xmlType
	//|	jsonType
	//|	compositeType
	//|	rangeType
	//|	objectIdentifierType
	|	pseudoType
	|	identifier
	|	reservedKeywordFunctionOrType
	;

numericType
	:	SMALLINT
	|	INTEGER
	|	INT
	|	BIGINT
	|	DECIMAL
	|	DECIMAL LeftParen Integral RightParen
	|	DECIMAL LeftParen Integral Comma Integral RightParen
	|	NUMERIC
	|	NUMERIC LeftParen Integral RightParen
	|	NUMERIC LeftParen Integral Comma Integral RightParen
	|	REAL
	|	DOUBLE PRECISION
	//|	SMALLSERIAL
	//|	SERIAL
	//|	BIGSERIAL
	;

characterType
	:	CHARACTER VARYING
	|	CHARACTER VARYING LeftParen Integral RightParen
	|	VARCHAR
	|	VARCHAR LeftParen Integral RightParen
	|	CHARACTER
	|	CHARACTER LeftParen Integral RightParen
	|	CHAR
	|	CHAR LeftParen Integral RightParen
	|	TEXT
	;

datetimeType
	:	TIMESTAMP
		(	LeftParen Integral RightParen
		)?
		(	WITHOUT TIME ZONE
		|	WITH TIME ZONE
		)?
	|	DATE
	|	TIME
		(	LeftParen Integral RightParen
		)?
		(	WITHOUT TIME ZONE
		|	WITH TIME ZONE
		)?
	|	INTERVAL
		(	YEAR
		|	MONTH
		|	DAY
		|	HOUR
		|	MINUTE
		|	SECOND
		|	YEAR TO MONTH
		|	DAY TO HOUR
		|	DAY TO MINUTE
		|	DAY TO SECOND
		|	HOUR TO MINUTE
		|	HOUR TO SECOND
		|	MINUTE TO SECOND
		)?
		(	LeftParen Integral RightParen
		)?
	;

booleanType
	:	BOOLEAN
	;

bitStringType
	:	BIT VARYING? LeftParen Integral RightParen
	;

uuidType
	:	UUID
	;

xmlType
	:	XML
	;

arrayType
	:	typeNotArrayType arrayDimension+
	;

arrayDimension
	:	LeftBracket Integral? RightBracket
	;

pseudoType
	:	ANY
	|	TRIGGER
	;

//
// Commands
//

command
	:	statement Semicolon
	|	MetaCommand
	|	EndMetaCommand
	;

statement
	:	abortStatement
	|	alterAggregateStatement
	|	alterCollationStatement
	|	alterConversionStatement
	|	alterDatabaseStatement
	|	alterDefaultPrivilegesStatement
	|	alterDomainStatement
	|	alterEventTriggerStatement
	|	alterExtensionStatement
	|	alterForeignDataWrapperStatement
	|	alterForeignTableStatement
	|	alterFunctionStatement
	|	alterGroupStatement
	|	alterIndexStatement
	|	alterLanguageStatement
	|	alterLargeObjectStatement
	|	alterMaterializedViewStatement
	|	alterOperatorStatement
	|	alterOperatorClassStatement
	|	alterOperatorFamilyStatement
	|	alterRoleStatement
	|	alterRuleStatement
	|	alterSchemaStatement
	|	alterSequenceStatement
	|	alterServerStatement
	|	alterTableStatement
	|	alterTablespaceStatement
	|	alterTextSearchConfigurationStatement
	|	alterTextSearchDictionaryStatement
	|	alterTextSearchParserStatement
	|	alterTextSearchTemplateStatement
	|	alterTriggerStatement
	|	alterTypeStatement
	|	alterUserStatement
	|	alterUserMappingStatement
	|	alterViewStatement
	|	analyzeStatement
	|	beginStatement
	|	checkpointStatement
	|	closeStatement
	|	clusterStatement
	|	commentStatement
	|	commitStatement
	|	commitPreparedStatement
	|	copyStatement
	|	createAggregateStatement
	|	createCastStatement
	|	createCollationStatement
	|	createConversionStatement
	|	createDatabaseStatement
	|	createDomainStatement
	|	createEventTriggerStatement
	|	createExtensionStatement
	|	createForeignDataWrapperStatement
	|	createForeignTableStatement
	|	createFunctionStatement
	|	createGroupStatement
	|	createIndexStatement
	|	createLanguageStatement
	|	createMaterializedViewStatement
	|	createOperatorStatement
	|	createOperatorClassStatement
	|	createOperatorFamilyStatement
	|	createRoleStatement
	|	createRuleStatement
	|	createSchemaStatement
	|	createSequenceStatement
	|	createServerStatement
	|	createTableStatement
	|	createTableAsStatement
	|	createTablespaceStatement
	|	createTextSearchConfigurationStatement
	|	createTextSearchDictionaryStatement
	|	createTextSearchParserStatement
	|	createTextSearchTemplateStatement
	|	createTriggerStatement
	|	createTypeStatement
	|	createUserStatement
	|	createUserMappingStatement
	|	createViewStatement
	|	deallocateStatement
	|	declareStatement
	|	deleteStatement
	|	discardStatement
	|	doStatement
	|	dropAggregateStatement
	|	dropCastStatement
	|	dropCollationStatement
	|	dropConversionStatement
	|	dropDatabaseStatement
	|	dropDomainStatement
	|	dropEventTriggerStatement
	|	dropExtensionStatement
	|	dropForeignDataWrapperStatement
	|	dropForeignTableStatement
	|	dropFunctionStatement
	|	dropGroupStatement
	|	dropIndexStatement
	|	dropLanguageStatement
	|	dropMaterializedViewStatement
	|	dropOperatorStatement
	|	dropOperatorClassStatement
	|	dropOperatorFamilyStatement
	|	dropOwnedStatement
	|	dropRoleStatement
	|	dropRuleStatement
	|	dropSchemaStatement
	|	dropSequenceStatement
	|	dropServerStatement
	|	dropTableStatement
	|	dropTablespaceStatement
	|	dropTextSearchConfigurationStatement
	|	dropTextSearchDictionaryStatement
	|	dropTextSearchParserStatement
	|	dropTextSearchTemplateStatement
	|	dropTriggerStatement
	|	dropTypeStatement
	|	dropUserStatement
	|	dropUserMappingStatement
	|	dropViewStatement
	|	endStatement
	|	executeStatement
	|	explainStatement
	|	fetchStatement
	|	grantStatement
	|	insertStatement
	|	listenStatement
	|	loadStatement
	|	lockStatement
	|	moveStatement
	|	notifyStatement
	|	prepareStatement
	|	prepareTransactionStatement
	|	reassignOwnedStatement
	|	refreshMaterializedViewStatement
	|	reindexStatement
	|	releaseSavepointStatement
	|	resetStatement
	|	revokeStatement
	|	rollbackStatement
	|	rollbackPreparedStatement
	|	rollbackToSavepointStatement
	|	savepointStatement
	|	securityLabelStatement
	|	selectStatement
	//|	selectIntoStatement // combined with selectStatement
	|	setStatement
	|	setConstraintsStatement
	|	setRoleStatement
	|	setSessionAuthorizationStatement
	|	setTransactionStatement
	|	showStatement
	|	startTransactionStatement
	|	truncateStatement
	|	unlistenStatement
	|	updateStatement
	|	vacuumStatement
	|	valuesStatement
	;

// http://www.postgresql.org/docs/9.3/static/sql-abort.html
abortStatement
	:	ABORT (WORK | TRANSACTION)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-alteraggregate.html
alterAggregateStatement
	:	// ALTER AGGREGATE name ( argtype [ , ... ] ) RENAME TO new_name
		// ALTER AGGREGATE name ( argtype [ , ... ] ) OWNER TO new_owner
		// ALTER AGGREGATE name ( argtype [ , ... ] ) SET SCHEMA new_schema
		ALTER AGGREGATE aggregateName LeftParen argtype (Comma argtype)* RightParen
		(	RENAME TO newName
		|	OWNER TO newOwner
		|	SET SCHEMA newSchema
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-altercollation.html
alterCollationStatement
	:	ALTER COLLATION name
		(	RENAME TO newName
		|	OWNER TO newOwner
		|	SET SCHEMA newSchema
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterconversion.html
alterConversionStatement
	:	ALTER CONVERSION name
		(	RENAME TO newName
		|	OWNER TO newOwner
		|	SET SCHEMA newSchema
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterdatabase.html
alterDatabaseStatement
	:	ALTER DATABASE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterdefaultprivileges.html
alterDefaultPrivilegesStatement
	:	ALTER DEFAULT PRIVILEGES notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterdomain.html
alterDomainStatement
	:	ALTER DOMAIN name
		(	(SET DEFAULT expression | DROP DEFAULT)
		|	(SET | DROP) NOT NULL
		|	ADD domainConstraint (NOT VALID)?
		|	DROP CONSTRAINT (IF EXISTS)? constraintName (RESTRICT | CASCADE)?
		|	RENAME CONSTRAINT constraintName TO newConstraintName
		|	VALIDATE CONSTRAINT constraintName
		|	OWNER TO newOwner
		|	RENAME TO newName
		|	SET SCHEMA newSchema
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-altereventtrigger.html
alterEventTriggerStatement
	:	ALTER EVENT TRIGGER name
		(	DISABLE
		|	ENABLE (REPLICA | ALWAYS)?
		|	OWNER TO newOwner
		|	RENAME TO newName
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterextension.html
alterExtensionStatement
	:	ALTER EXTENSION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterforeigndatawrapper.html
alterForeignDataWrapperStatement
	:	ALTER FOREIGN DATA WRAPPER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterforeigntable.html
alterForeignTableStatement
	:	ALTER FOREIGN TABLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterfunction.html
alterFunctionStatement
	:	ALTER FUNCTION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altergroup.html
alterGroupStatement
	:	ALTER GROUP notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterindex.html
alterIndexStatement
	:	ALTER INDEX notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterlanguage.html
alterLanguageStatement
	:	ALTER LANGUAGE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterlargeobject.html
alterLargeObjectStatement
	:	ALTER LARGE OBJECT notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altermaterializedview.html
alterMaterializedViewStatement
	:	ALTER MATERIALIZED VIEW notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alteroperator.html
alterOperatorStatement
	:	ALTER OPERATOR notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alteroperatorclass.html
alterOperatorClassStatement
	:	ALTER OPERATOR CLASS notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alteroperatorfamily.html
alterOperatorFamilyStatement
	:	ALTER OPERATOR FAMILY notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterrole.html
alterRoleStatement
	:	ALTER ROLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterrule.html
alterRuleStatement
	:	ALTER RULE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterschema.html
alterSchemaStatement
	:	ALTER SCHEMA notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altersequence.html
alterSequenceStatement
	:	ALTER SEQUENCE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterserver.html
alterServerStatement
	:	ALTER SERVER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertable.html
alterTableStatement
	:	ALTER TABLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertablespace.html
alterTablespaceStatement
	:	ALTER TABLESPACE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertextsearchconfiguration.html
alterTextSearchConfigurationStatement
	:	ALTER TEXT SEARCH CONFIGURATION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertextsearchdictionary.html
alterTextSearchDictionaryStatement
	:	ALTER TEXT SEARCH DICTIONARY notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertextsearchparser.html
alterTextSearchParserStatement
	:	ALTER TEXT SEARCH PARSER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertextsearchtemplate.html
alterTextSearchTemplateStatement
	:	ALTER TEXT SEARCH TEMPLATE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertrigger.html
alterTriggerStatement
	:	ALTER TRIGGER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-altertype.html
alterTypeStatement
	:	ALTER TYPE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alteruser.html
alterUserStatement
	:	ALTER USER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterusermapping.html
alterUserMappingStatement
	:	ALTER USER MAPPING notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-alterview.html
alterViewStatement
	:	ALTER VIEW notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-analyze.html
analyzeStatement
	:	ANALYZE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-begin.html
beginStatement
	:	BEGIN (WORK | TRANSACTION)?
		(	transactionMode (Comma transactionMode)*
		)?
	;

transactionMode
	:	ISOLATION LEVEL
		(	SERIALIZABLE
		|	REPEATABLE READ
		|	READ COMMITTED
		|	READ UNCOMMITTED
		)
	|	READ (WRITE | ONLY)
	|	NOT? DEFERRABLE
	;

// http://www.postgresql.org/docs/9.3/static/sql-checkpoint.html
checkpointStatement
	:	CHECKPOINT
	;

// http://www.postgresql.org/docs/9.3/static/sql-close.html
closeStatement
	:	CLOSE (name | ALL)
	;

// http://www.postgresql.org/docs/9.3/static/sql-cluster.html
clusterStatement
	:	CLUSTER VERBOSE? tableName (USING indexName)?
	|	CLUSTER VERBOSE?
	|	// provided for backward compatibility only
		CLUSTER indexName ON tableName
	;

// http://www.postgresql.org/docs/9.3/static/sql-comment.html
commentStatement
	:	COMMENT notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-commit.html
commitStatement
	:	COMMIT (WORK | TRANSACTION)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-commitprepared.html
commitPreparedStatement
	:	COMMIT PREPARED transactionId
	;

// http://www.postgresql.org/docs/9.3/static/sql-copy.html
copyStatement
	:	COPY notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createaggregate.html
createAggregateStatement
	:	CREATE AGGREGATE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createcast.html
createCastStatement
	:	CREATE CAST notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createcollation.html
createCollationStatement
	:	CREATE COLLATION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createconversion.html
createConversionStatement
	:	CREATE DEFAULT? CONVERSION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createdatabase.html
createDatabaseStatement
	:	CREATE DATABASE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createdomain.html
createDomainStatement
	:	CREATE DOMAIN notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createeventtrigger.html
createEventTriggerStatement
	:	CREATE EVENT TRIGGER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createextension.html
createExtensionStatement
	:	CREATE EXTENSION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createforeigndatawrapper.html
createForeignDataWrapperStatement
	:	CREATE FOREIGN DATA WRAPPER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createforeigntable.html
createForeignTableStatement
	:	CREATE FOREIGN TABLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createfunction.html
createFunctionStatement
	:	CREATE (OR REPLACE)? FUNCTION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-creategroup.html
createGroupStatement
	:	CREATE GROUP notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createindex.html
createIndexStatement
	:	CREATE UNIQUE? INDEX notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createlanguage.html
createLanguageStatement
	:	CREATE (OR REPLACE)? TRUSTED? PROCEDURAL? LANGUAGE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-creatematerializedview.html
createMaterializedViewStatement
	:	CREATE MATERIALIZED VIEW notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createoperator.html
createOperatorStatement
	:	CREATE OPERATOR notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createopclass.html
createOperatorClassStatement
	:	CREATE OPERATOR CLASS notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createopfamily.html
createOperatorFamilyStatement
	:	CREATE OPERATOR FAMILY notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createrole.html
createRoleStatement
	:	CREATE ROLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createrule.html
createRuleStatement
	:	// CREATE [ OR REPLACE ] RULE name AS ON event
		//		TO table_name [ WHERE condition ]
		//		DO [ ALSO | INSTEAD ] { NOTHING | command | ( command ; command ... ) }
		CREATE (OR REPLACE)? RULE ruleName AS ON event
		TO tableName
		(	WHERE condition
		)?
		DO (ALSO | INSTEAD)?
		(	NOTHING
		|	statement
		|	LeftParen
			statement (Semicolon statement)* Semicolon?
			RightParen
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-createschema.html
createSchemaStatement
	:	CREATE SCHEMA notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createsequence.html
createSequenceStatement
	:	CREATE (TEMPORARY | TEMP)? SEQUENCE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createserver.html
createServerStatement
	:	CREATE SERVER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtable.html
createTableStatement
	:	CREATE
		(	(	GLOBAL
			|	LOCAL
			)?
			(	TEMPORARY
			|	TEMP
			)
		|	UNLOGGED
		)?
		TABLE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtableas.html
createTableAsStatement
	:	CREATE
		(	(	GLOBAL
			|	LOCAL
			)?
			(	TEMPORARY
			|	TEMP
			)
		|	UNLOGGED
		)?
		TABLE AS notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtablespace.html
createTablespaceStatement
	:	CREATE TABLESPACE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtsconfig.html
createTextSearchConfigurationStatement
	:	CREATE TEXT SEARCH CONFIGURATION notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtsdictionary.html
createTextSearchDictionaryStatement
	:	CREATE TEXT SEARCH DICTIONARY notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtsparser.html
createTextSearchParserStatement
	:	CREATE TEXT SEARCH PARSER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtstemplate.html
createTextSearchTemplateStatement
	:	CREATE TEXT SEARCH TEMPLATE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtrigger.html
createTriggerStatement
	:	CREATE CONSTRAINT? TRIGGER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createtype.html
createTypeStatement
	:	CREATE TYPE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createuser.html
createUserStatement
	:	CREATE USER notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createusermapping.html
createUserMappingStatement
	:	CREATE USER MAPPING FOR notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-createview.html
createViewStatement
	:	CREATE (OR REPLACE)? (TEMP | TEMPORARY)? RECURSIVE? VIEW notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-deallocate.html
deallocateStatement
	:	DEALLOCATE PREPARE? (name | ALL)
	;

// http://www.postgresql.org/docs/9.3/static/sql-declare.html
declareStatement
	:	DECLARE name (BINARY | INSENSITIVE | NO? SCROLL)*
		CURSOR ((WITH | WITHOUT) HOLD)? FOR (selectStatement | valuesStatement)
	;

// http://www.postgresql.org/docs/9.3/static/sql-delete.html
deleteStatement
	:	(WITH RECURSIVE? withQuery (Comma withQuery)*)?
		DELETE FROM ONLY? tableName Asterisk? (AS? alias)?
		(	USING usingList
		)?
		(	WHERE condition
		|	WHERE CURRENT OF cursorName
		)?
		(	RETURNING Asterisk
		|	RETURNING outputExpression asOutputName? ellipsisNotImplemented
		)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-discard.html
discardStatement
	:	DISCARD
		(	ALL
		|	PLANS
		|	TEMPORARY
		|	TEMP
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-do.html
doStatement
	:	DO (LANGUAGE langName)? code
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropaggregate.html
dropAggregateStatement
	:	// DROP AGGREGATE [ IF EXISTS ] name ( argtype [ , ... ] ) [ CASCADE | RESTRICT ]
		DROP AGGREGATE (IF EXISTS)? aggregateName LeftParen
		(	argtype (Comma argtype)*
		|	// special case for a zero-argument aggregate function
			Asterisk
		)
		RightParen (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropcast.html
dropCastStatement
	:	DROP CAST (IF EXISTS)? LeftParen sourceType AS targetType RightParen (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropcollation.html
dropCollationStatement
	:	DROP COLLATION (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropconversion.html
dropConversionStatement
	:	DROP CONVERSION (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropdatabase.html
dropDatabaseStatement
	:	DROP DATABASE (IF EXISTS)? name
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropdomain.html
dropDomainStatement
	:	DROP DOMAIN (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropeventtrigger.html
dropEventTriggerStatement
	:	DROP EVENT TRIGGER (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropextension.html
dropExtensionStatement
	:	DROP EXTENSION (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropforeigndatawrapper.html
dropForeignDataWrapperStatement
	:	DROP FOREIGN DATA WRAPPER (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropforeigntable.html
dropForeignTableStatement
	:	DROP FOREIGN TABLE (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropfunction.html
dropFunctionStatement
	:	// DROP FUNCTION [ IF EXISTS ] name ( [ [ argmode ] [ argname ] argtype [, ...] ] )
		//		[ CASCADE | RESTRICT ]
		DROP FUNCTION (IF EXISTS)? functionName
		LeftParen
		(	(argmode? argname? | argname argmode) argtype
			(Comma (argmode? argname? | argname argmode) argtype)*
		)?
		RightParen
		(CASCADE | RESTRICT)?
	;

argmode
	:	IN
	|	OUT
	|	INOUT
	|	VARIADIC
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropgroup.html
dropGroupStatement
	:	DROP GROUP (IF EXISTS)? name (Comma name)*
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropindex.html
dropIndexStatement
	:	DROP INDEX CONCURRENTLY? (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droplanguage.html
dropLanguageStatement
	:	DROP PROCEDURAL? LANGUAGE (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropmaterializedview.html
dropMaterializedViewStatement
	:	DROP MATERIALIZED VIEW (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropoperator.html
dropOperatorStatement
	:	DROP OPERATOR (IF EXISTS)? name LeftParen (leftType | NONE) Comma (rightType | NONE) RightParen (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropoperatorclass.html
dropOperatorClassStatement
	:	DROP OPERATOR CLASS (IF EXISTS)? name USING indexMethod (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropoperatorfamily.html
dropOperatorFamilyStatement
	:	DROP OPERATOR FAMILY (IF EXISTS)? name USING indexMethod (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropowned.html
dropOwnedStatement
	:	DROP OWNED BY name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droprole.html
dropRoleStatement
	:	DROP ROLE (IF EXISTS)? name (Comma name)*
	;

// http://www.postgresql.org/docs/9.3/static/sql-droprule.html
dropRuleStatement
	:	DROP RULE (IF EXISTS)? name ON tableName (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropschema.html
dropSchemaStatement
	:	DROP SCHEMA (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropsequence.html
dropSequenceStatement
	:	DROP SEQUENCE (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropserver.html
dropServerStatement
	:	DROP SERVER (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptable.html
dropTableStatement
	:	DROP TABLE (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptablespace.html
dropTablespaceStatement
	:	DROP TABLESPACE (IF EXISTS)? name
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptextsearchconfiguration.html
dropTextSearchConfigurationStatement
	:	DROP TEXT SEARCH CONFIGURATION (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptextsearchdictionary.html
dropTextSearchDictionaryStatement
	:	DROP TEXT SEARCH DICTIONARY (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptextsearchparser.html
dropTextSearchParserStatement
	:	DROP TEXT SEARCH PARSER (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptextsearchtemplate.html
dropTextSearchTemplateStatement
	:	DROP TEXT SEARCH TEMPLATE (IF EXISTS)? name (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptrigger.html
dropTriggerStatement
	:	DROP TRIGGER (IF EXISTS)? name ON tableName (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-droptype.html
dropTypeStatement
	:	DROP TYPE (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropuser.html
dropUserStatement
	:	DROP USER (IF EXISTS)? name (Comma name)*
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropusermapping.html
dropUserMappingStatement
	:	DROP USER MAPPING (IF EXISTS)? FOR
		(	userName
		|	USER
		|	CURRENT_USER
		|	PUBLIC
		)
		SERVER serverName
	;

// http://www.postgresql.org/docs/9.3/static/sql-dropview.html
dropViewStatement
	:	DROP VIEW (IF EXISTS)? name (Comma name)* (CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-end.html
endStatement
	:	END (WORK | TRANSACTION)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-execute.html
executeStatement
	:	EXECUTE name (LeftParen parameter (Comma parameter)* RightParen)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-explain.html
explainStatement
	:	EXPLAIN (LeftParen option (Comma option)* RightParen)? statement
	|	EXPLAIN ANALYZE? VERBOSE? statement
	;

option
	:	ANALYZE booleanValue?
	|	VERBOSE booleanValue?
	|	COSTS booleanValue?
	|	BUFFERS booleanValue?
	|	TIMING booleanValue?
	|	FORMAT (TEXT | XML | JSON | YAML)
	;

// http://www.postgresql.org/docs/9.3/static/sql-fetch.html
fetchStatement
	:	FETCH (direction (FROM | IN)?)? cursorName
	;

// http://www.postgresql.org/docs/9.3/static/sql-grant.html
grantStatement
	:	GRANT notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-insert.html
insertStatement
	:	(WITH RECURSIVE? withQuery (Comma withQuery)*)?
		INSERT INTO (schemaName Period)? tableName (LeftParen columnName (Comma columnName)* RightParen)?
		// { DEFAULT VALUES | VALUES ( { expression | DEFAULT } [, ...] ) [, ...] | query }
		(	DEFAULT VALUES
		|	VALUES LeftParen (expression | DEFAULT) (Comma (expression | DEFAULT))* RightParen (Comma LeftParen (expression | DEFAULT) (Comma (expression | DEFAULT))* RightParen)*
		|	selectStatement
		)
		// [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]
		(	RETURNING Asterisk
		|	RETURNING outputExpression asOutputName? (Comma outputExpression asOutputName?)*
		)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-listen.html
listenStatement
	:	LISTEN channel
	;

// http://www.postgresql.org/docs/9.3/static/sql-load.html
loadStatement
	:	LOAD stringConstant
	;

// http://www.postgresql.org/docs/9.3/static/sql-lock.html
lockStatement
	:	LOCK TABLE? ONLY? name Asterisk? (Comma name Asterisk?)* (IN lockmode MODE)? NOWAIT?
	;

lockmode
	:	ACCESS SHARE
	|	ROW SHARE
	|	ROW EXCLUSIVE
	|	SHARE UPDATE EXCLUSIVE
	|	SHARE
	|	SHARE ROW EXCLUSIVE
	|	EXCLUSIVE
	|	ACCESS EXCLUSIVE
	;

// http://www.postgresql.org/docs/9.3/static/sql-move.html
moveStatement
	:	MOVE (direction (FROM | IN)?)? cursorName
	;

// differs from the spec: empty is not allowed
direction
	:	NEXT
	|	PRIOR
	|	FIRST
	|	LAST
	|	ABSOLUTE count
	|	RELATIVE count
	|	count
	|	ALL
	|	FORWARD
	|	FORWARD count
	|	FORWARD ALL
	|	BACKWARD
	|	BACKWARD count
	|	BACKWARD ALL
	;

// http://www.postgresql.org/docs/9.3/static/sql-notify.html
notifyStatement
	:	NOTIFY channel (Comma payload)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-prepare.html
prepareStatement
	:	PREPARE name (LeftParen dataType (Comma dataType)* RightParen)? AS
		(	selectStatement
		|	insertStatement
		|	updateStatement
		|	deleteStatement
		|	valuesStatement
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-preparetransaction.html
prepareTransactionStatement
	:	PREPARE TRANSACTION transactionId
	;

// http://www.postgresql.org/docs/9.3/static/sql-reassignowned.html
reassignOwnedStatement
	:	REASSIGN OWNED BY oldRole (Comma oldRole)* TO newRole
	;

// http://www.postgresql.org/docs/9.3/static/sql-refreshmaterializedview.html
refreshMaterializedViewStatement
	:	REFRESH MATERIALIZED VIEW name (WITH NO? DATA)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-reindex.html
reindexStatement
	:	REINDEX (INDEX | TABLE | DATABASE | SYSTEM) name FORCE?
	;

// http://www.postgresql.org/docs/9.3/static/sql-releasesavepoint.html
releaseSavepointStatement
	:	RELEASE SAVEPOINT? savepointName
	;

// http://www.postgresql.org/docs/9.3/static/sql-reset.html
resetStatement
	:	RESET configurationParameter
	|	RESET TIME ZONE
	|	RESET ALL
	;

// http://www.postgresql.org/docs/9.3/static/sql-revoke.html
revokeStatement
	:	REVOKE (GRANT OPTION FOR)?
		(	(SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER) (Comma (SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER))*
		|	ALL PRIVILEGES?
		)
		ON
		(	TABLE? tableName ellipsisNotImplemented
		|	ALL TABLES IN SCHEMA schemaName ellipsisNotImplemented
		)
		FROM
		(	GROUP? roleName
		|	PUBLIC
		)
		ellipsisNotImplemented
		(CASCADE | RESTRICT)?
	|	REVOKE notImplemented // many more options
	;

// http://www.postgresql.org/docs/9.3/static/sql-rollback.html
rollbackStatement
	:	ROLLBACK (WORK | TRANSACTION)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-rollbackprepared.html
rollbackPreparedStatement
	:	ROLLBACK PREPARED transactionId
	;

// http://www.postgresql.org/docs/9.3/static/sql-rollbacktosavepoint.html
rollbackToSavepointStatement
	:	ROLLBACK (WORK | TRANSACTION)? TO SAVEPOINT? savepointName
	;

// http://www.postgresql.org/docs/9.3/static/sql-savepoint.html
savepointStatement
	:	SAVEPOINT savepointName
	;

// http://www.postgresql.org/docs/9.3/static/sql-securitylabel.html
securityLabelStatement
	:	SECURITY LABEL (FOR provider)? ON
		(	TABLE objectName
		|	COLUMN tableName Period columnName
		|	AGGREGATE aggregateName LeftParen aggregateType (Comma aggregateType)* RightParen
		|	DATABASE objectName
		|	DOMAIN objectName
		|	EVENT TRIGGER objectName
		|	FOREIGN TABLE objectName
		|	FUNCTION functionName LeftParen (argmode? argname? argtype (Comma argmode? argname? argtype)*)? RightParen
		|	LARGE OBJECT largeObjectOid
		|	MATERIALIZED VIEW objectName
		|	PROCEDURAL? LANGUAGE objectName
		|	ROLE objectName
		|	SCHEMA objectName
		|	SEQUENCE objectName
		|	TABLESPACE objectName
		|	TYPE objectName
		|	VIEW objectName
		)
		IS label
	;

// http://www.postgresql.org/docs/9.3/static/sql-select.html
// http://www.postgresql.org/docs/9.3/static/sql-selectinto.html
selectStatement
	:	(	// [ WITH [ RECURSIVE ] with_query [, ...] ]
			WITH RECURSIVE? withQuery (Comma withQuery)*
		)?
		SELECT
		(	// [ ALL | DISTINCT [ ON ( expression [, ...] ) ] ]
			(	ALL
			|	DISTINCT
				(	ON LeftParen expression (Comma expression)* RightParen
				)?
			)
		)?
		(	// * | expression [ [ AS ] output_name ] [, ...]
			(	Asterisk
			|	tableName Period Asterisk
			|	expression asOutputName?
			)
			(	Comma
				(	Asterisk
				|	tableName Period Asterisk
				|	expression asOutputName?
				)
			)*
		)
		(	// This is the distinguishing feature of a SELECT INTO statement
			INTO (TEMPORARY | TEMP | UNLOGGED)? TABLE? (schemaName Period)? tableName
		)?
		(	// [ FROM from_item [, ...] ]
			FROM fromItem (Comma fromItem)*
		)?
		(	// [ WHERE condition ]
			WHERE condition
		)?
		(	// [ GROUP BY expression [, ...] ]
			GROUP BY expression (Comma expression)*
		)?
		(	// [ HAVING condition [, ...] ]
			HAVING condition (Comma condition)*
		)?
		(	// [ WINDOW window_name AS ( window_definition ) [, ...] ]
			WINDOW windowName AS LeftParen windowDefinition RightParen
			(	Comma windowName AS LeftParen windowDefinition RightParen
			)*
		)?
		(	// [ { UNION | INTERSECT | EXCEPT } [ ALL | DISTINCT ] select ]
			(UNION | INTERSECT | EXCEPT)
			(ALL | DISTINCT)?
			selectStatement
		)?
		(	// [ ORDER BY expression [ ASC | DESC | USING operator ] [ NULLS { FIRST | LAST } ] [, ...] ]
			ORDER BY
			expression
			(	ASC
			|	DESC
			|	USING operator
			)?
			(	NULLS (FIRST | LAST)
			)?
			(	Comma
				expression
				(	ASC
				|	DESC
				|	USING operator
				)?
				(	NULLS (FIRST | LAST)
				)?
			)*
		)?
		(	// [ LIMIT { count | ALL } ]
			LIMIT (count | ALL)
		)?
		(	// [ OFFSET start [ ROW | ROWS ] ]
			OFFSET start (ROW | ROWS)?
		)?
		(	// [ FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } ONLY ]
			FETCH (FIRST | NEXT) count? (ROW | ROWS) ONLY
		)?
		(	// [ FOR { UPDATE | NO KEY UPDATE | SHARE | KEY SHARE } [ OF table_name [, ...] ] [ NOWAIT ] [...] ]
			FOR
			(	UPDATE
			|	NO KEY UPDATE
			|	SHARE
			|	KEY SHARE
			)
			(	OF tableName (Comma tableName)*
			)?
			NOWAIT?
			(	Comma
				(	UPDATE
				|	NO KEY UPDATE
				|	SHARE
				|	KEY SHARE
				)
				(	OF tableName (Comma tableName)*
				)?
				NOWAIT?
			)*
		)?
	;

fromItem
	:	// [ ONLY ] table_name [ * ] [ [ AS ] alias [ ( column_alias [, ...] ) ] ]
		ONLY? (schemaName Period)? tableName Asterisk?
		(	AS? alias
			(	LeftParen columnAlias (Comma columnAlias)* RightParen
			)?
		)?
	|	// [ LATERAL ] ( select ) [ AS ] alias [ ( column_alias [, ...] ) ]
		LATERAL? LeftParen (selectStatement | valuesStatement) RightParen AS? alias 
		(	LeftParen columnAlias (Comma columnAlias)* RightParen
		)?
	|	// with_query_name [ [ AS ] alias [ ( column_alias [, ...] ) ] ]
		withQueryName
		(	AS? alias
			(	LeftParen columnAlias (Comma columnAlias)* RightParen
			)?
		)?
	|	// [ LATERAL ] function_name ( [ argument [, ...] ] ) [ AS ] alias [ ( column_alias [, ...] | column_definition [, ...] ) ]
		LATERAL? functionName LeftParen (argument (Comma argument)*)? RightParen AS? alias
		(	LeftParen columnAlias (Comma columnAlias)* | columnDefinition (Comma columnDefinition)* RightParen // TODO: WTF order of operations?
		)?
	|	// [ LATERAL ] function_name ( [ argument [, ...] ] ) AS ( column_definition [, ...] )
		LATERAL? functionName LeftParen (argument (Comma argument)*)? RightParen AS LeftParen columnDefinition ellipsisNotImplemented RightParen
	|	// from_item [ NATURAL ] join_type from_item [ ON join_condition | USING ( join_column [, ...] ) ]
		fromItem NATURAL? joinType fromItem
		(	ON joinCondition
		|	USING LeftParen joinColumn (Comma joinColumn)* RightParen
		)?
	|	// This form is suggested by the descriptive text
		LATERAL? functionName LeftParen (argument (Comma argument)*)? RightParen
	|	// TODO: This form is suggested by actual input samples
		LeftParen fromItem RightParen
	;

withQuery
	:	// with_query_name [ ( column_name [, ...] ) ] AS ( select | values | insert | update | delete )
		withQueryName (LeftParen columnName (Comma columnName)* RightParen)?
		AS LeftParen (selectStatement | valuesStatement | insertStatement | updateStatement | deleteStatement) RightParen
	;

joinType
	:	INNER? JOIN
	|	LEFT OUTER? JOIN
	|	RIGHT OUTER? JOIN
	|	FULL OUTER? JOIN
	|	CROSS JOIN
	;

// http://www.postgresql.org/docs/9.3/static/sql-selectinto.html
//selectIntoStatement
//	:	(WITH RECURSIVE? withQuery (Comma withQuery)*)?
//		SELECT ~Semicolon* INTO notImplemented
//	;

// http://www.postgresql.org/docs/9.3/static/sql-set.html
setStatement
	:	SET (SESSION | LOCAL)? configurationParameter (TO | Equal) (configurationValue | stringConstant | DEFAULT)
	|	SET (SESSION | LOCAL)? TIME ZONE (timezone | LOCAL | DEFAULT)
	;

// http://www.postgresql.org/docs/9.3/static/sql-setconstraints.html
setConstraintsStatement
	:	SET CONSTRAINTS
		(	ALL
		|	name (Comma name)*
		)
		(	DEFERRED
		|	IMMEDIATE
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-setrole.html
setRoleStatement
	:	SET (SESSION | LOCAL)? ROLE (roleName | NONE)
	|	RESET ROLE
	;

// http://www.postgresql.org/docs/9.3/static/sql-set-session-authorization.html
setSessionAuthorizationStatement
	:	SET (SESSION | LOCAL)? SESSION AUTHORIZATION (userName | DEFAULT)
	|	RESET SESSION AUTHORIZATION
	;

// http://www.postgresql.org/docs/9.3/static/sql-settransaction.html
setTransactionStatement
	:	SET TRANSACTION transactionMode (Comma transactionMode)*
	|	SET TRANSACTION SNAPSHOT snapshotId
	|	SET SESSION CHARACTERISTICS AS TRANSACTION transactionMode (Comma transactionMode)*
	;

// http://www.postgresql.org/docs/9.3/static/sql-show.html
showStatement
	:	SHOW name
	|	SHOW ALL
	;

// http://www.postgresql.org/docs/9.3/static/sql-starttransaction.html
startTransactionStatement
	:	START TRANSACTION
		(	transactionMode (Comma transactionMode)*
		)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-truncate.html
truncateStatement
	:	TRUNCATE TABLE? ONLY? name Asterisk? (Comma name Asterisk?)*
		(	RESTART IDENTITY
		|	CONTINUE IDENTITY
		)?
		(CASCADE | RESTRICT)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-unlisten.html
unlistenStatement
	:	UNLISTEN
		(	channel
		|	Asterisk
		)
	;

// http://www.postgresql.org/docs/9.3/static/sql-update.html
updateStatement
	:	UPDATE notImplemented
	;

// http://www.postgresql.org/docs/9.3/static/sql-vacuum.html
vacuumStatement
	:	// VACUUM [ ( { FULL | FREEZE | VERBOSE | ANALYZE } [, ...] ) ] [ table_name [ (column_name [, ...] ) ] ]
		VACUUM (LeftParen (FULL | FREEZE | VERBOSE | ANALYZE) (Comma (FULL | FREEZE | VERBOSE | ANALYZE))* RightParen)? (tableName (LeftParen columnName (Comma columnName)* RightParen)?)?
	|	// VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] [ table_name ]
		VACUUM FULL? FREEZE? VERBOSE? tableName?
	|	// VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] ANALYZE [ table_name [ (column_name [, ...] ) ] ]
		VACUUM FULL? FREEZE? VERBOSE? ANALYZE (tableName (LeftParen columnName (Comma columnName)* RightParen)?)?
	;

// http://www.postgresql.org/docs/9.3/static/sql-values.html
valuesStatement
	:	VALUES LeftParen expression (Comma expression)* RightParen (Comma LeftParen expression (Comma expression)* RightParen)*
		(	// [ ORDER BY sort_expression [ ASC | DESC | USING operator ] [, ...] ]
			ORDER BY sortExpression (ASC | DESC | USING operator) ellipsisNotImplemented
		)?
		(	// [ LIMIT { count | ALL } ]
			LIMIT (count | ALL)
		)?
		(	// [ OFFSET start [ ROW | ROWS ] ]
			OFFSET start (ROW | ROWS)?
		)?
		(	// [ FETCH { FIRST | NEXT } [ count ] { ROW | ROWS } ONLY ]
			FETCH (FIRST | NEXT) count? (ROW | ROWS) ONLY
		)?
	;
