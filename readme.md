# WIP
An app for saving and viewing gps activities (cycling, running, hiking etc.).
Currently supports .fit[.gz] and .gpx[.gz] files.
Fit files must be fit activities (file ID == 6)

## run
```bash
docker build -t pursuit-server .
# STORAGE_DIRECTORY - the directory where sqlite db and uploaded files will be stored
docker run --rm -p 127.0.0.1:7070:7070 -v <STORAGE_DIRECTORY>:/appstorage pursuit-server
```

## dev
- Java: 24.0.1
- Zig: 0.15.0-dev.58+1f92b394e
- Node: v20.18.0
- Sqlite: 3.47.0

## todo
- Install/Setup
- Dashboard page
- Support other record fields: heart rate, temperature, candence, power etc.
- Support other fit file types
- Stats graphs: speed, elevation, hr etc.
- Route builder
