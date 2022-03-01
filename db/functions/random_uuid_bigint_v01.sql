CREATE OR REPLACE FUNCTION random_uuid_bigint()
   RETURNS BIGINT AS
$$
BEGIN
RETURN floor(random()* (9223372036854775800) + 1);
END;
$$ language 'plpgsql' STRICT;
