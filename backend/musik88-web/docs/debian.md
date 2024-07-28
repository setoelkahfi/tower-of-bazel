# Homebrew

Homebrew is used to install ```pyenv```.

# Pyenv

~~Pyenv is used to manage ```python```.~~


# Server Storage

Hetzner gives a  40GB internal storage. When attaching another storage, always select manual attachment and then follow tutorial. This is an example of the tutorial:

```
Configure volume
To configure your volume, use the following commands on your server.
FORMAT VOLUME
 sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0HC_Volume_15126575
CREATE DIRECTORY
 mkdir /mnt/volume-hel1-1
MOUNT VOLUME
 mount -o discard,defaults /dev/disk/by-id/scsi-0HC_Volume_15126575 /mnt/volume-hel1-1
OPTIONAL: ADD VOLUME TO FSTAB
?
 echo "/dev/disk/by-id/scsi-0HC_Volume_15126575 /mnt/volume-hel1-1 ext4 discard,nofail,defaults 0 0" >> /etc/fstab
The volume is now accessible at /mnt/volume-hel1-1 for data storage. This data will persist if you detach the volume. It will be available for attachment to another server in the same location.
```

One will need to change the permission with: ```sudo chmod ugo+rwx /media/username/your_drive```.