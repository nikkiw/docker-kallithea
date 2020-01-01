# Kallithea Docker Image

[This](https://hub.docker.com/r/toras9000/kallithea) is a docker image of the source code management system [kallithea](https://kallithea-scm.org/).  
It is affected by the specifications of [atnurgaliev/kallithea](https://hub.docker.com/r/atnurgaliev/kallithea)'s image and is compatible with version 0.4 and lator.  

## Tags

- latest ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/master/build/Dockerfile))
- 0.5.0 ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/tag_0.5.0/build/Dockerfile))
- 0.4.1 ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/tag_0.4.1/build/Dockerfile))

Execute by a non-root user.

- gu ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/tag_gu/build/Dockerfile))
- gu-0.5.0 ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/tag_gu-0.5.0/build/Dockerfile))
- gu-0.4.1 ([Dockerfile](https://github.com/toras9000/docker-kallithea/blob/tag_gu-0.4.1/build/Dockerfile))

## Usage

If you run for trial.  
The container provides services on port 80.  

```bash
$ docker run -d -p 8000:80 toras9000/kallithea
```

## Data location

The storage location of data in the container.  
When changing the version, pay attention to the handling of persistent data.  
See [Upgrading Kallithea](https://kallithea.readthedocs.io/en/latest/upgrade.html) for the steps required to change the version.  

- `/kallithea/config`  
contains configuration file (`kallithea.ini`).  

- `/kallithea/repos`  
contains repositories.  

- `/kallithea/logs`  
contains log files.  

## Enviroment variables

If kallithea.ini does not exist in the container, it is considered the first time and the initialization process is executed.  
The following are variables used at initialization.  

- `KALLITHEA_ADMIN_USER`  
Administrator account username (default: `admin`)  

- `KALLITHEA_ADMIN_PASS`  
Administrator account password (default: `admin`)  

- `KALLITHEA_ADMIN_MAIL`  
Administrator account e-mail (default: `admin@example.com`)  

- `KALLITHEA_LANG`  
Specifies the default language for when the display language cannot be determined automatically.  
It is determined by browser settings if possible. See [i18n support](https://kallithea.readthedocs.io/en/latest/setup.html#internationalization-i18n-support).  
(empty by default, meaning english. can be one of `be bg cs da de el es fr hu ja nb_NO nl_BE pl pt_BR ru sk tr uk zh_CN zh_TW`)  

The following are the variables that are used every time it starts.  

- `KALLITHEA_EXTERNAL_DB`  
SQLAlchemy connection string when using an external database.See [SQLAlchemy documentation](https://docs.sqlalchemy.org/en/12/core/engines.html#database-urls) for examples)  
This image supports PostgreSQL (by psycopg2) and MySQL (by mysqlclient).  
(empty by default, SQLite is used.)  

- `KALLITHEA_LOCALE`  
Specify the locale in the container.  ("en_US.UTF-8" by default)  

- `KALLITHEA_REPOSORT_IDX`  
Default sort column number for repository list.  
A rough patch to the display template. (empty by default, no patch.)  

- `KALLITHEA_REPOSORT_ORDER`  
Sort direction when default sort column is specified.  
A rough patch to the display template. ("asc" by default)  

- `KALLITHEA_FIX_PERMISSION`  
If set to TRUE, will overwrite the file permissions of the repository and configuration files
. (TRUE by default)  


When executing with persistence, the following two steps are assumed as an example.  
First, run with database initialization.  

```bash
$ docker run -d -p 8000:80 \
             -e KALLITHEA_ADMIN_USER=admin \
             -e KALLITHEA_ADMIN_PASS=secret \
             -v /opt/kallithea/config:/kallithea/config \
             -v /opt/kallithea/repos:/kallithea/repos \
             -v /opt/kallithea/logs:/kallithea/logs \
             toras9000/kallithea
```

After the initialization is completed, omit unnecessary specifications for the second time and later.  

```bash
$ docker run -d -p 8000:80 \
             -v /opt/kallithea/config:/kallithea/config \
             -v /opt/kallithea/repos:/kallithea/repos \
             -v /opt/kallithea/logs:/kallithea/logs \
             toras9000/kallithea
```
