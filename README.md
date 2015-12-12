# docker-s3ql-volume

A small docker container to mount an s3 volume via s3ql so you can save your data in s3 from docker containers. The container handles uploading data to s3 and pulling it down for the first time when the container starts. It also will cleanly unmount the volume on shutdown.

## Usage

### Mount and run
docker run -d --name s3ql --env-file=path/to/environment gidjin/s3ql-volume mount.s3ql

### Fsck
docker run --rm -it --env-file=path/to/environment gidjin/s3ql-volume fsck.s3ql

### Environment Variables

These are the environment variables, the first three are required the others are optional

  * BACKEND_LOGIN is the s3 user
  * BACKEND_PASSWORD is the s3 pass for the bucket
  * STORAGE_URL is the bucket path

  * FS_PASSPHRASE is the passphrase for encryption, default is blank with no encryption
  * STORAGE_PATH is the path additional path below bucket root that is s3ql data location default is blank

## Notes

fsck and s3ql verify are run on start up and if they fail will bail out the container

should auto umount on shutdown, unless you run docker kill or something

Exposes a volume /mnt/s3ql which contains the config file, cache folder and data folder. To write to it when you start the container use the -v flag to mount a volume to the /volume directory, any writes there will be synced to the /mnt/s3ql/data folder which is the mount point. So read and write from the /volume dir

### Caveats

I'm currently only using this with DreamHosts Dream Objects so it may need some tweaking for use with Amazon's S3
