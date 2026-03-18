-- Create database and user for place-scraper
CREATE DATABASE places_scraper;
CREATE USER places_user WITH ENCRYPTED PASSWORD '8lRk1JBq7PmR';
GRANT ALL PRIVILEGES ON DATABASE places_scraper TO places_user;


