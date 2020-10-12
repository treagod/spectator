UPDATE CustomOrder
SET position =
CASE
    WHEN (
        SELECT position
        FROM CustomOrder
        WHERE id = $MOVED_ID AND type = 0
        ) > (
        SELECT position
        FROM CustomOrder
        WHERE
            id = $TARGET_ID
            AND
            type = 0
        )
    THEN position + 1
    ELSE position - 1
END
WHERE
position
BETWEEN
CASE
    WHEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) > (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0)
    THEN (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0) + 1
    ELSE (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) + 1
END
AND
CASE
    WHEN (
        SELECT position
        FROM CustomOrder
        WHERE
            id = $MOVED_ID
            AND
            type = 0
        ) > (
        SELECT position
        FROM CustomOrder
        WHERE
            id = $TARGET_ID
            AND
            type = 0
        )
    THEN (SELECT position FROM CustomOrder WHERE id = $MOVED_ID AND type = 0) - 1
    ELSE (SELECT position FROM CustomOrder WHERE id = $TARGET_ID AND type = 0)
END;
