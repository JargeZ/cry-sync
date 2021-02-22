#!/bin/bash
set -e
# Where located encrypted cryfs directory
CRYFS_BASE_DIR=/home/lev/cryfs_sync_config_folder

# Change it, if you want mount temp dir to another path
# Also it automatically created if does not exists
CRYFS_MOUNT_DIR="${HOME}/crypto_mount"

# Files/dir's relative from your $HOME path
FILELIST="
cry-sync.sh
.zshrc
.config/remmina
"


TMP_FILELIST=/tmp/filelist.txt
echo $FILELIST > $TMP_FILELIST

LOCAL=$HOME
REMOTE=$CRYFS_MOUNT_DIR

if [[ ! -d $REMOTE ]]; then
  echo "REMOTE dir $REMOTE does not exists"
  exit 1
fi
if [[ -z $LOCAL ]]; then
  echo "LOCAL path is empty, please edit script"
  exit 1
fi

for i in "$@"; do
case $i in
    --pull|--push)
    case $i in
      --pull ) FROM_TO="$REMOTE $LOCAL" ;;
      --push ) FROM_TO="$LOCAL $REMOTE" ;;
    esac
    shift # past argument with no value
    ;;
esac
done

if [[ -z "$FROM_TO" ]]; then
  echo "Please select --pull or --push"
  exit 1
fi


export CRYFS_FRONTEND=noninteractive
if [[ $(mountpoint -q ${CRYFS_MOUNT_DIR}) ]]; then
  echo "$CRYFS_MOUNT_DIR already mounted."
else
  CRYFS_PASSWORD=$(zenity --password --title="CryFS password" --timeout=120)
  echo "$CRYFS_PASSWORD" | cryfs --unmount-idle 2 "$CRYFS_BASE_DIR" "$CRYFS_MOUNT_DIR"
fi


rsync --archive --verbose --recursive --files-from=$TMP_FILELIST $FROM_TO

cryfs-unmount "$CRYFS_MOUNT_DIR"
rm $TMP_FILELIST

echo "Job done"
