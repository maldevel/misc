## change-root-password.sh


### Requirements
* Tested on Debian 8.x


### Supported services
* System
* GLPI
* Owncloud
* Gitlab
* Wordpress
* MySQL
* PostgreSQL


### Usage
```bash
usage: change-root-password [-h] -s service [-u username] [-d database] [-b username] [--occ filepath]

arguments:
-h, --help                          show this help message and exit
-s service, --service service
                                    select a service to change root/admin password (mysql, system, postgresql, gitlab, glpi, owncloud, wordpress)
-u username, --username username    service administrator's username.
-d database, --database database    database name to make sql queries.
-b username, --dbuser username      database user to make sql queries.
--occ filepath                      location of occ tool
```


### Usage Examples

#### change-root-password.sh

##### System
```bash
./change-root-password.sh -s system
```
* **-s <service>**  service.

```bash
./change-root-password.sh -s system -u myroot
```
* **-s <service>**  service.
* **-u <username>**  system 'root' username, in case the default(root) has been changed.

##### MySQL
```bash
./change-root-password.sh -s mysql 
```
* **-s <service>**  service.

```bash
./change-root-password.sh -s mysql -u myroot
```
* **-s <service>**  service.
* **-u <username>** mysql 'root' username, in case the default(root) has been changed.

##### PostgreSQL
```bash
./change-root-password.sh -s postgresql
```
* **-s <service>**  service.

```bash
./change-root-password.sh -s postgresql -u myadmin -d mypostgres
```
* **-s <service>**  service.
* **-u <username>** postgresql 'root' username, in case the default(postgres) has been changed.
* **-d <database>** postgresql 'root' database, in case the default(postgres) has been changed.

##### Gitlab
```bash
./change-root-password.sh -s gitlab
```
* **-s <service>**  service.

##### GLPI
```bash
./change-root-password.sh -s glpi -d assetsdb
```
* **-s <service>**  service.
* **-d <database>** glpi database.

```bash
./change-root-password.sh -s glpi -u myroot -d assetsdb
```
* **-s <service>**  service.
* **-u <username>** glpi 'root' username, in case the default(glpi) has been changed.
* **-d <database>** glpi database.

```bash
./change-root-password.sh -s glpi -u myroot -d assetdb -b myroot
```
* **-s <service>**    service.
* **-u <username>**   glpi 'root' username, in case the default(glpi) has been changed.
* **-d <database>**   glpi database.
* **-b <mysqluser>**  mysql user, default root.

##### Owncloud
```bash
./change-root-password.sh -s owncloud -u myadmin --occ /var/www/owncloud/occ
```
* **-s <service>** 		service.
* **-u <username>**		owncloud 'root' username.
* **--occ <filepath>**	owncloud's occ tool filepath(default: /var/www/html/owncloud/occ).

##### Wordpress
```bash
./change-root-password.sh -s wordpress -d mywordpress
```
* **-s <service>**  service.
* **-d <database>** wordpress database.

```bash
./change-root-password.sh -s wordpress -d mywordpress -b myroot
```
* **-s <service>**    service.
* **-d <database>**   wordpress database.
* **-b <mysqluser>**  mysql user, default root.

