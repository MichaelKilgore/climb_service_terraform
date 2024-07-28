CREATE EXTENSION postgis;

CREATE TABLE climbing_location (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  profile_pic_location VARCHAR(300) NOT NULL,
  description TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  geom GEOMETRY(Point, 4326),
  status VARCHAR(50) CHECK (status IN ('APPROVED', 'IN REVIEW', 'REJECTED WITH COMMENTS', 'REJECTED')),
  additional_info TEXT NOT NULL,
  moderator_comments TEXT NOT NULL
);

UPDATE climbing_location
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

CREATE OR REPLACE FUNCTION update_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_geom_trigger
BEFORE INSERT OR UPDATE ON climbing_location
FOR EACH ROW
EXECUTE FUNCTION update_geom();


CREATE INDEX climbing_location_geom_idx ON climbing_location USING GIST (geom);


INSERT INTO climbing_location (name, profile_pic_location, description, address, status, additional_info, moderator_comments, latitude, longitude)
VALUES ('Bull Creek District Park', '/images/bull-creek-park.jpg', '', '6701 Lakewood Dr, Austin, TX 78731', 'APPROVED', '', '', 0.0, 0.0);

CREATE TABLE climb_user (
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(200) UNIQUE,
  phone_number VARCHAR(15) UNIQUE CHECK(phone_number ~ '^[0-9]{0,15}$'),
  status VARCHAR(50) CHECK (status IN ('CONTRIBUTOR', 'COMMENTOR', 'VIEWER')),
  moderator_comments TEXT NOT NULL,
);

INSERT INTO climb_user (user_name, status, moderator_comments)
VALUES ('michael', 'CONTRIBUTOR', '');

CREATE TABLE phone_validation (
  phone_number VARCHAR(15) UNIQUE CHECK(phone_number ~ '^[0-9]{0,15}$') PRIMARY KEY,
  creation_time TIMESTAMP NOT NULL,
  code VARCHAR(6) CHECK(code ~ '^[0-9]{0,6}$') NOT NULL
)

