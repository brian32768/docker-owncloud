DROP DATABASE owncloud;
-- CREATE DATABASE owncloud OWNER owncloud;
CREATE DATABASE owncloud TEMPLATE template0 ENCODING 'UNICODE';
ALTER DATABASE owncloud OWNER TO owncloud;
GRANT ALL PRIVILEGES ON DATABASE owncloud TO owncloud;
