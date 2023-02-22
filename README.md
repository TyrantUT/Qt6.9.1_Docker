## Cross Compile QT 6.4.0 for Raspberry 4 using Docker

## Build Ubuntu Host
```
docker build -f Dockerfile.host -t host .
```

## Compile Qt 6.4.0 Host
```
docker run build
```

## Commit Host to a new image
```
docker ps -a #Find the ID of the build container
docker commit {ID} host
```

## Create build and built directories
### build contains the tar.gz of the cross compiled Qt 6.4.0
### built contains the compiled Qt binary for execution on the Raspberry Pi
```
mkdir build && mkdir built
```

## Build Qt 6.4.0 Raspberry Pi image
```
docker build -f Dockerfile.rpi -t rpi .
```

## Compile Qt 6.4.0 for Raspberry Pi
```
docker run \
	--mount src="$(pwd)/build",target=/build,type=bind \
	rpi
```