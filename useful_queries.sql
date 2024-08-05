/* query for climbing locations within 1 km of
   0.1, 0.1 latitude longitude */
SELECT id, name,
       ST_Distance(
           geom,
           ST_SetSRID(ST_MakePoint(0.1, 0.1), 4326)
       ) AS distance
FROM climbing_location
WHERE ST_DWithin(
    geom,
    ST_SetSRID(ST_MakePoint(0.1, 0.1), 4326),
    1000
)
ORDER BY distance;


DO $$
DECLARE
    v_status VARCHAR(50);
    v_moderator_comments TEXT;
    v_phone_number VARCHAR(17) := '+14257706852';
BEGIN
    SELECT status, moderator_comments
    INTO v_status, v_moderator_comments
    FROM climb_user
    WHERE phone_number = v_phone_number
    LIMIT 1;

    UPDATE climb_user
    SET
        phone_number = '+14257706852',
        status = COALESCE(v_status, climb_user.status),
        moderator_comments = COALESCE(v_moderator_comments, climb_user.moderator_comments)
    WHERE climb_user.climb_user_id = 1;
END $$;
