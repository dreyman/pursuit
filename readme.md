# WIP
An app for saving and viewing gps activities (cycling, running, hiking etc.).
Currently supports .fit[.gz] and .gpx[.gz] files.

Java: 24.0.1
Zig: 0.15.0-dev.58+1f92b394e
Node: v20.18.0
Sqlite: 3.47.0

## RUN
```bash
docker build -t pursuit-server .
# STORAGE_DIRECTORY - the directory where sqlite db and uploaded files are stored
docker run --rm -p 127.0.0.1:7070:7070 -v <STORAGE_DIRECTORY>:/appstorage pursuit-server
```

## TODO
- Install/Setup
