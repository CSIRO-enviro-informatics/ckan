# Requirements

Requires Environment Variables
      
      CKAN_SITE_URL
      CKAN_PORT
      DATASTORE_READONLY_PASSWORD
      POSTGRES_PASSWORD
      CKAN_LDAP_PASSWORD

which can be set in an .env file 

file might look like:

CKAN_SITE_URL=http://localhost
CKAN_PORT=5000
DATASTORE_READONLY_PASSWORD=default_password
POSTGRES_PASSWORD=default_password
CKAN_LDAP_PASSWORD=[LDAP PASSWORD]

# Instructions

docker-compose up

