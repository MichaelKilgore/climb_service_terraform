CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS climb_route CASCADE;
DROP TABLE IF EXISTS phone_validation CASCADE;
DROP TABLE IF EXISTS climb_user CASCADE;
DROP TABLE IF EXISTS climb_location CASCADE;

CREATE TABLE climb_location (
  climb_location_id SERIAL PRIMARY KEY,
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

UPDATE climb_location
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

CREATE OR REPLACE FUNCTION update_geom()
RETURNS TRIGGER AS $$
BEGIN
    NEW.geom = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_climb_location_geom_trigger
BEFORE INSERT OR UPDATE ON climb_location
FOR EACH ROW
EXECUTE FUNCTION update_geom();


CREATE INDEX climb_location_geom_idx ON climb_location USING GIST (geom);


INSERT INTO climb_location (name, profile_pic_location, description, address, status, additional_info, moderator_comments, latitude, longitude)
VALUES ('Bull Creek District Park', '/images/bull-creek-park.jpg', '', '6701 Lakewood Dr, Austin, TX 78731', 'APPROVED', '', '', 0.0, 0.0);

CREATE TABLE climb_user (
  climb_user_id SERIAL PRIMARY KEY,
  user_name VARCHAR(200) UNIQUE,
  phone_number VARCHAR(15) CHECK(phone_number ~ '^[0-9]{0,15}$'),
  status VARCHAR(50) CHECK (status IN ('CONTRIBUTOR', 'COMMENTOR', 'VIEWER')),
  moderator_comments TEXT NOT NULL
);

INSERT INTO climb_user (user_name, status, moderator_comments)
VALUES ('michael', 'CONTRIBUTOR', '');

CREATE TABLE phone_validation (
  phone_number VARCHAR(15) UNIQUE CHECK(phone_number ~ '^[0-9]{0,15}$') PRIMARY KEY,
  creation_time TIMESTAMP NOT NULL,
  code VARCHAR(6) CHECK(code ~ '^[0-9]{0,6}$') NOT NULL
);

CREATE TABLE climb_route (
	climb_route_id SERIAL PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	grade VARCHAR(20) NOT NULL,
	climb_location_id INTEGER NOT NULL,
	FOREIGN KEY (climb_location_id) REFERENCES climb_location(climb_location_id), 
	latitude DOUBLE PRECISION NOT NULL,
	longitude DOUBLE PRECISION NOT NULL,
	geom GEOMETRY(Point, 4326),
	description TEXT NOT NULL, 
	video_link VARCHAR(300) NOT NULL,
	climb_user_id INTEGER NOT NULL,
	FOREIGN KEY (climb_user_id) REFERENCES climb_user(climb_user_id)
);

UPDATE climb_route
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

CREATE TRIGGER update_climb_route_geom_trigger
BEFORE INSERT OR UPDATE ON climb_route
FOR EACH ROW
EXECUTE FUNCTION update_geom();

INSERT INTO climb_route (name, grade, climb_location_id, latitude, longitude, description, video_link, climb_user_id)
VALUES ('route', '1', 1, 100, 100, 'desc', 'video', 1);

CREATE INDEX climb_route_geom_idx ON climb_route USING GIST (geom);
