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

CREATE TRIGGER IF NOT EXISTS delete_variable_after_environment_deletion
    AFTER DELETE ON Environment
BEGIN
    DELETE FROM Variable WHERE environment_name = OLD.name;
END;

CREATE TRIGGER IF NOT EXISTS update_variable_after_environment_deletion
    AFTER UPDATE ON Environment
BEGIN
	UPDATE Variable
	SET environment_name=NEW.name
	WHERE Variable.environment_name=OLD.name;
END;