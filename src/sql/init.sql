create table if not exists Request (
    id              INTEGER              PRIMARY KEY              AUTOINCREMENT              NOT NULL,
    name            TEXT                 NOT NULL,
    method          INT,
    url             TEXT,
    last_sent       INT,
    collection_id   INT,
    FOREIGN KEY (collection_id) REFERENCES Collection(id) ON DELETE CASCADE
);

create table if not exists Collection (
    id		  INTEGER		PRIMARY KEY     AUTOINCREMENT NOT NULL,
    name	  TEXT				     	NOT NULL
);

create table if not exists CustomOrder (
    id		  INT,
    type      INT,
    position  INT
);

CREATE TRIGGER IF NOT EXISTS insert_custom_order_after_request_creation
    AFTER INSERT ON Request
BEGIN
    INSERT INTO CustomOrder (id, type, position) VALUES (NEW.id, 0, (SELECT COUNT(*) FROM CustomOrder));
END;

CREATE TRIGGER IF NOT EXISTS insert_custom_order_after_collection_creation
    AFTER INSERT ON Collection
BEGIN
    INSERT INTO CustomOrder (id, type, position) VALUES (NEW.id, 1, (SELECT COUNT(*) FROM CustomOrder));
END;

CREATE TRIGGER IF NOT EXISTS delete_custom_order_after_request_deletion
    AFTER DELETE ON Request
BEGIN
    UPDATE CustomOrder
    SET position = position - 1
    WHERE position > (SELECT position FROM CustomOrder WHERE id = OLD.id AND type = 0);
    DELETE FROM CustomOrder
    WHERE id = OLD.id AND type = 0;
END;

CREATE TRIGGER IF NOT EXISTS delete_custom_order_after_collection_deletion
    AFTER DELETE ON Collection
BEGIN
    UPDATE CustomOrder
    SET position = position - 1
    WHERE position > (SELECT position FROM CustomOrder WHERE id = OLD.id AND type = 1);
    DELETE FROM CustomOrder
    WHERE id = OLD.id AND type = 1;
    DELETE FROM Request
    WHERE collection_id = OLD.id;
END;

CREATE INDEX IF NOT EXISTS "Entry" ON "CustomOrder" (
	"id"	ASC,
	"type"	ASC
);

CREATE INDEX IF NOT EXISTS "RequestIdx" ON "Request" (
	"id"	ASC
);

CREATE INDEX IF NOT EXISTS "CollectionIdx" ON "Collection" (
	"id"	ASC
);
