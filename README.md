# Docker images with systemd support

[![Build](https://github.com/msavdert/docker-linux-systemd/actions/workflows/build-and-push.yml/badge.svg?branch=main)](https://github.com/msavdert/docker-linux-systemd/actions/workflows/build-and-push.yml)
[![Release](https://github.com/msavdert/docker-linux-systemd/actions/workflows/release.yml/badge.svg)](https://github.com/msavdert/docker-linux-systemd/actions/workflows/release.yml)

Docker images for Ansible role, Molecule scenario, and systemd-enabled container testing.

Images are published to `melihsavdert/docker-systemd` with distro-version tags.

## Supported tags and platforms

- `oraclelinux-7` (`linux/amd64`, `linux/arm64`)
- `oraclelinux-8` (`linux/amd64`, `linux/arm64`)
- `oraclelinux-9` (`linux/amd64`, `linux/arm64`)
- `oraclelinux-10` (`linux/amd64`, `linux/arm64`)
- `rockylinux-8` (`linux/amd64`, `linux/arm64`)
- `rockylinux-9` (`linux/amd64`, `linux/arm64`)
- `rockylinux-10` (`linux/amd64`, `linux/arm64`)
- `ubuntu-20.04` (`linux/amd64`, `linux/arm64`)
- `ubuntu-22.04` (`linux/amd64`, `linux/arm64`)
- `ubuntu-24.04` (`linux/amd64`, `linux/arm64`)
- `ubuntu-26.04` (`linux/amd64`, `linux/arm64`)

`ubuntu-26.04` is included because the upstream base tag exists already. If Canonical changes the devel track before the final LTS cut, rebuild behavior may also change.

## Repository layout

Each distribution keeps flat, versioned Dockerfiles:

- `oraclelinux/7.Dockerfile`
- `oraclelinux/8.Dockerfile`
- `oraclelinux/9.Dockerfile`
- `oraclelinux/10.Dockerfile`
- `rockylinux/8.Dockerfile`
- `rockylinux/9.Dockerfile`
- `rockylinux/10.Dockerfile`
- `ubuntu/20.04.Dockerfile`
- `ubuntu/22.04.Dockerfile`
- `ubuntu/24.04.Dockerfile`
- `ubuntu/26.04.Dockerfile`

## Usage

### With Molecule

```yaml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: instance-ubuntu
    image: melihsavdert/docker-systemd:ubuntu-24.04
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
      - /var/lib/containerd
    cgroupns_mode: host
    privileged: true
    pre_build_image: true
    groups:
      - debian_family
  - name: instance-rocky
    image: melihsavdert/docker-systemd:rockylinux-10
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
      - /var/lib/containerd
    cgroupns_mode: host
    privileged: true
    pre_build_image: true
    groups:
      - rhel_family
provisioner:
  name: ansible
verifier:
  name: ansible
```

### Build and run

- Build an image.

```bash
export DISTR='ubuntu'
export VERSION='24.04'
docker build -t docker-systemd:${DISTR}-${VERSION} -f ${DISTR}/${VERSION}.Dockerfile .
```

- Run a container.

```bash
docker run -d --name systemd-${DISTR}-${VERSION} \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  docker-systemd:${DISTR}-${VERSION}
```

- Enter the container.

```bash
docker exec -it systemd-${DISTR}-${VERSION} /bin/bash
```

- Remove the container.

```bash
docker rm -f systemd-${DISTR}-${VERSION}
```

## Release workflow

Releases are generated with semantic-release. Conventional Commit messages drive:

- version bumping
- GitHub releases
- `CHANGELOG.md` updates

Useful commit types:

- `feat:` for new images or new supported versions
- `fix:` for image fixes
- `refactor:` for internal cleanup with user-visible effect
- `docs(README):` for documentation patches that should produce a patch release

## License

GNU General Public License. See [LICENSE](LICENSE).

## Author

Melih Savdert
