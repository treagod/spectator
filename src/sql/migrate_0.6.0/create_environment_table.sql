CREATE TABLE if not exists Environment (
	name TEXT NOT NULL,
	created_at INTEGER NOT NULL,
	CONSTRAINT Environment_PK PRIMARY KEY (name)
);
