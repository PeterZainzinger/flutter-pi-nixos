set -e
OUTPUT=$(nixos-generate -f sd-aarch64-installer  --system aarch64-linux -c config.nix -I nixpkgs=$(pwd)/20.03 --cores 8 | tail -1)
WORK_DIR=$(dirname $OUTPUT)
FILENAME=$(basename $OUTPUT)

pushd ~/Desktop
rm -rf test
ln -s $WORK_DIR test
pushd ${WORK_DIR}/../
#sudo dd if=sd-image/$FILENAME of=/dev/mmcblk0 status=progress
