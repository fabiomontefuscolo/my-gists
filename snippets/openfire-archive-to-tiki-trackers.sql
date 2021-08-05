BEGIN
    DECLARE tr_ID     INT DEFAULT  2;
    DECLARE tf_ROOMID INT DEFAULT  7;
    DECLARE tf_ROOM   INT DEFAULT  8;
    DECLARE tf_SENDER INT DEFAULT  9;
    DECLARE tf_DATE   INT DEFAULT 10;
    DECLARE tf_BODY   INT DEFAULT 12;

    DECLARE _lastInsertId INT DEFAULT 0;
    DECLARE _lastItemId   INT DEFAULT 0;
    DECLARE _lastSync     INT DEFAULT 0;

    DECLARE ofRoomID  BIGINT;
    DECLARE ofName    VARCHAR(50);
    DECLARE ofSender  TEXT;
    DECLARE ofLogTime CHAR(15);
    DECLARE ofBody    TEXT;

    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor1 CURSOR FOR 
        SELECT
            mc.roomID,
            mr.name,
            mc.sender,
            mc.logTime,
            mc.body
        FROM xmpp_montefuscolo_com_br.ofMucConversationLog mc
        INNER JOIN xmpp_montefuscolo_com_br.ofMucRoom mr
            ON mc.roomID=mr.roomID
        WHERE
            CAST(mc.logTime AS UNSIGNED) > (_lastSync * 1000)
            AND mr.publicRoom = 1
            AND (
                mc.body != NULL
                OR
                mc.body != ""
            )
        ORDER BY mc.logTime ASC;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- get last item
    SELECT MAX(itemId)
        INTO _lastItemId
        FROM tiki_tracker_items
        WHERE trackerId = tr_ID;

    -- get last imported message date
    IF _lastItemID != NULL THEN
        SELECT value
            INTO _lastSync
            FROM tiki_tracker_item_fields
            WHERE itemId = _lastItemId
                AND fieldId = tf_DATE;
    END IF;

    OPEN cursor1;
    read_loop: LOOP
        FETCH cursor1 INTO ofRoomID, ofName, ofSender, ofLogTime, ofBody;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO tiki_tracker_items (trackerId, created, createdBy, status, lastModif, lastModifBy)
            VALUES(
                tr_ID,
                UNIX_TIMESTAMP(),
                "mysql:stored-procedure:ImportOFArchiveToTrackers",
                "o",
                UNIX_TIMESTAMP(),
                "mysql:stored-procedure:ImportOFArchiveToTrackers"
            );
        SET _lastInsertId = LAST_INSERT_ID();

        IF _lastInsertId > 0 THEN
            INSERT INTO tiki_tracker_item_fields (itemID, fieldID, value) VALUES (_lastInsertId, tf_ROOMID, ofRoomID);
            INSERT INTO tiki_tracker_item_fields (itemID, fieldID, value) VALUES (_lastInsertId, tf_ROOM,   ofName);
            INSERT INTO tiki_tracker_item_fields (itemID, fieldID, value) VALUES (_lastInsertId, tf_SENDER, ofSender);
            INSERT INTO tiki_tracker_item_fields (itemID, fieldID, value) VALUES (_lastInsertId, tf_DATE,   ROUND(ofLogTime / 1000));
            INSERT INTO tiki_tracker_item_fields (itemID, fieldID, value) VALUES (_lastInsertId, tf_BODY,   ofBody);
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END LOOP;
    CLOSE cursor1;
END
