#!/usr/bin/env bash
# Usage: publish-box.sh VERSION [EXTRA_PACKAGES...]
set -euo pipefail

VERSION="${1:?usage: publish-box.sh VERSION [extra apt packages]}"
shift
EXTRA="${*:-}"
LAB="$HOME/vagrant-lab"
BOXDIR="$LAB/boxes"
IMAGE="devops-lab/vagrant-ubuntu:${VERSION}"
BUILD="$BOXDIR/build-${VERSION}"
BOXFILE="$BOXDIR/devops-ubuntu2404-docker-${VERSION}.box"

echo ">> Building image ${IMAGE} (extra packages: ${EXTRA:-none})"
docker build -q -t "$IMAGE" \
  --build-arg BOX_VERSION="$VERSION" \
  --build-arg EXTRA_PACKAGES="$EXTRA" \
  "$LAB/image"

echo ">> Assembling box contents in ${BUILD}"
rm -rf "$BUILD"
mkdir -p "$BUILD"
cp "$LAB/image/vagrant_lab_key" "$BUILD/vagrant_private_key"
chmod 600 "$BUILD/vagrant_private_key"

echo '{"provider": "docker"}' > "$BUILD/metadata.json"

cat > "$BUILD/Vagrantfile" <<RUBY
Vagrant.configure("2") do |config|
  config.ssh.private_key_path = File.expand_path("../vagrant_private_key", __FILE__)
  config.ssh.insert_key       = false
  config.vm.provider "docker" do |d|
    d.image   = "${IMAGE}"
    d.has_ssh = true
  end
end
RUBY

tar -C "$BUILD" -czf "$BOXFILE" metadata.json Vagrantfile vagrant_private_key
echo ">> Box written: ${BOXFILE}"

echo ">> Regenerating catalog.json"
python3 - "$BOXDIR" <<'PY'
import hashlib, json, pathlib, re, sys
boxdir = pathlib.Path(sys.argv[1])
versions = []
for box in boxdir.glob("devops-ubuntu2404-docker-*.box"):
    ver = re.search(r"docker-(.+)\.box$", box.name).group(1)
    sha = hashlib.sha256(box.read_bytes()).hexdigest()
    versions.append({
        "version": ver,
        "providers": [{
            "name": "docker",
            "url": box.resolve().as_uri(),
            "checksum_type": "sha256",
            "checksum": sha,
            "architecture": "amd64",
            "default_architecture": True,
        }],
    })
versions.sort(key=lambda v: [int(x) for x in v["version"].split(".")])
catalog = {
    "name": "devops/ubuntu2404",
    "description": "Internal Ubuntu 24.04 base box (docker provider)",
    "versions": versions,
}
(boxdir / "catalog.json").write_text(json.dumps(catalog, indent=2) + "\n")
print("catalog.json lists versions:", ", ".join(v["version"] for v in versions))
PY
