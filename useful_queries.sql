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
