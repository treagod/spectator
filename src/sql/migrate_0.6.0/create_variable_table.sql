CREATE TABLE if not exists Variable (
	id TEXT(36) NOT NULL,
	"key" TEXT,
	value TEXT,
	created_at INTEGER,
	environment_name TEXT,
	CONSTRAINT Variable_PK PRIMARY KEY (id)
    FOREIGN KEY(environment_name) REFERENCES Environment(name)
	ON DELETE CASCADE
);