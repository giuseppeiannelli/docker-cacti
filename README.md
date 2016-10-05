# Cacti docker image
[![](https://images.microbadger.com/badges/version/giuseppeiannelli/cacti.svg)](https://microbadger.com/images/giuseppeiannelli/cacti) [![](https://images.microbadger.com/badges/image/giuseppeiannelli/cacti.svg)](https://microbadger.com/images/giuseppeiannelli/cacti)
###  Docker container image with cacti 0.8.8h running on Alpine Linux(v3.4), Supervisord, Nginx(1.10.1) and PHP-fpm.

##### Included plugins
- cacti spine
- realtime
- monitor
- hmib
- thold (require start MySQL with --sql-mode=NO_ENGINE_SUBSTITUTION option)
- rrdclean
- aggregate


## Before run container

#### Create docker network
```
docker network create --driver bridge private
```
```
docker network create --driver bridge public
```

#### Setup MySql 
Use this image with external MySql DB. Download and import [cacti.sql](https://raw.githubusercontent.com/giuseppeiannelli/docker-cacti/master/cacti.sql) in your DB instance.

###### You can use [MySQL](https://hub.docker.com/_/mysql/) docker official image and mount cacti.sql in /docker-entrypoint-initdb.d when start container for the first time.

```
docker run -d --network private -v /download/folder/cacti.sql:/docker-entrypoint-initdb.d mysql
```

## Run container

```sh
docker run -d -p 161/udp:161/udp -p 80:80 --network public --network private --restart="always" -e DB_HOSTNAME=mysql -e DB_NAME=cacti -e DB_USERNAME=cactiuser -e DB_PASSWORD=cactiuser -e VIRTUAL_HOST=localhost giuseppeiannelli/cacti:0.8.8h
```
###### DEFAULT SET UP ENV

```
CACTI_VERSION=0.8.8h
SNMP_PORT=161
SNMP_PORT_PROTO=udp
DB_TYPE=mysql
DB_PORT=3306
```

#### docker-compose.yml
```sh
version: '2'
services:
  cacti:
    image: giuseppeiannelli/cacti:0.8.8h
    container_name: cacti
    depends_on:
      - mysql
    ports:
      - "161/udp:161/udp"  #BIND SMTP PORT TO HOST
      - "80:80"            #BIND HTTP PORT TO HOST
    networks:
      - database
      - nginx
    env_file: .env.cacti
    restart: always

  mysql:
    image: mysql:5.6
    container_name: mysql
    command: --sql-mode=NO_ENGINE_SUBSTITUTION
    volumes:
      - /mysql/storage/folder/:/var/lib/mysql  #STORE MYSQL DATA INTO HOST FOLDER
      - /mysql/dumps/folder/cacti.sql:/docker-entrypoint-initdb.d/cacti.sql #IMPORT CACTI EMPITY SQL IN MYSQL DB
    networks:
      - database
    env_file: .env.mysql
    restart: always

networks:
  database:
    external:
      name: private
  nginx:
    external:
      name: public
```

#### .env.cacti
```
DB_TYPE=mysql
DB_HOSTNAME=mysql
DB_PORT=3306
DB_SSL=false
DB_NAME=cacti
DB_USERNAME=cactiuser
DB_PASSWORD=cactiuser

VIRTUAL_HOST=localhost
```

#### .env.mysql
```
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=cacti
MYSQL_USER=cactiuser
MYSQL_PASSWORD=cactiuser
```

#### SSL
If you want a SSL, use [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/)

```
docker run -d -p 80:80 -p 443:443 --network public --network private -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

Remember to remove binding for port 80 on host

# Runtime

#### "Setup and Login" info
- ```Default Timezone``` UTC
- rrdtool version ```1.5.x``` 
- net-snmp ```5.x```
 
Log in to ```http://VIRTUAL_HOST/``` as admin/admin.
