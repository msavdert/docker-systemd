# Docker images with systemd support

[![Build](https://github.com/msavdert/docker-systemd/actions/workflows/build-and-push.yml/badge.svg?branch=main)](https://github.com/msavdert/docker-systemd/actions/workflows/build-and-push.yml)
[![Release](https://github.com/msavdert/docker-systemd/actions/workflows/release.yml/badge.svg)](https://github.com/msavdert/docker-systemd/actions/workflows/release.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/melihsavdert/docker-systemd)](https://hub.docker.com/r/melihsavdert/docker-systemd)

Reusable multi-distribution Docker images with working systemd support for Ansible role testing, Molecule scenarios, CI jobs, and other cases where a minimal base image is not enough.

Source repository: https://github.com/msavdert/docker-systemd

Images are published to both registries:

```text
melihsavdert/docker-systemd:<tag>
ghcr.io/msavdert/docker-systemd:<tag>
```

Examples:

- `melihsavdert/docker-systemd:ubuntu-24.04`
- `melihsavdert/docker-systemd:amazonlinux-2`
- `melihsavdert/docker-systemd:oraclelinux-9`

No `latest` tag is published by design. Use an explicit distro-version tag to keep tests deterministic.

## Quick start

```bash
docker run -d --name systemd-ubuntu-24.04 \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  ghcr.io/msavdert/docker-systemd:ubuntu-24.04
```

## Why this repository exists

Most upstream container images are intentionally minimal. That is usually the right default, but it is not ideal when you need a realistic systemd-based environment for infrastructure testing.

These images are built for cases where you need:

- `systemctl` to work
- distro-native package managers and filesystem layout
- predictable service behavior during Molecule or CI runs
- a consistent tagging model across multiple Linux families

## Supported tags

The tag name is always the full distro identifier, not just the version number. For example, use `amazonlinux-2`, not only `2`.

| Family | Published tags | Platforms |
| --- | --- | --- |
| AlmaLinux | `almalinux-8`, `almalinux-9`, `almalinux-10` | `linux/amd64`, `linux/arm64` |
| Amazon Linux | `amazonlinux-2`, `amazonlinux-2023` | `amazonlinux-2`: `linux/amd64`<br>`amazonlinux-2023`: `linux/amd64`, `linux/arm64` |
| CentOS | `centos-7` | `linux/amd64` |
| Debian | `debian-10`, `debian-11`, `debian-12`, `debian-13` | `linux/amd64`, `linux/arm64` |
| Fedora | `fedora-39`, `fedora-40`, `fedora-41`, `fedora-42`, `fedora-43` | `linux/amd64`, `linux/arm64` |
| openSUSE | `opensuse-15.6`, `opensuse-16.0`, `opensuse-tumbleweed` | `linux/amd64`, `linux/arm64` |
| Oracle Linux | `oraclelinux-7`, `oraclelinux-8`, `oraclelinux-9`, `oraclelinux-10` | `linux/amd64`, `linux/arm64` |
| Rocky Linux | `rockylinux-8`, `rockylinux-9`, `rockylinux-10` | `linux/amd64`, `linux/arm64` |
| Ubuntu | `ubuntu-20.04`, `ubuntu-22.04`, `ubuntu-24.04`, `ubuntu-26.04` | `linux/amd64`, `linux/arm64` |

`ubuntu-26.04` is included because the upstream base tag already exists. If Canonical changes the development track before final release, rebuild behavior may also change.

## Usage

### Pull an image

```bash
docker pull melihsavdert/docker-systemd:amazonlinux-2
```

```bash
docker pull ghcr.io/msavdert/docker-systemd:amazonlinux-2
```

### Run a container

```bash
docker run -d --name systemd-rocky-10 \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  melihsavdert/docker-systemd:rockylinux-10
```

### Use with Molecule

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

## Build locally

```bash
export DISTR='ubuntu'
export VERSION='24.04'

docker build \
  -t docker-systemd:${DISTR}-${VERSION} \
  -f ${DISTR}/${VERSION}.Dockerfile \
  .
```

```bash
docker run -d --name systemd-${DISTR}-${VERSION} \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  docker-systemd:${DISTR}-${VERSION}
```

```bash
docker exec -it systemd-${DISTR}-${VERSION} /bin/bash
```

## Image rules

Each image follows the same baseline approach:

- install only what is needed for a usable systemd-based test environment
- prune unnecessary unit wants to reduce noise and boot overhead
- keep distro-specific handling isolated to the places where it is required
- use native systemd startup instead of shell wrapper entrypoints

## Automation

The repository is maintained with four focused workflows:

- `validate.yml` lints Dockerfiles and test-builds images on pull requests
- `build-and-push.yml` publishes images to Docker Hub and GHCR on `main` and on a weekly schedule
- `release.yml` manages GitHub releases and updates `CHANGELOG.md` with semantic-release
- `dockerhub-description.yml` syncs `README.md` to Docker Hub

## Release notes

Releases are generated with semantic-release and conventional commits.

- `feat:` for new images or supported versions
- `fix:` for image fixes
- `refactor:` for internal cleanup with user-visible effect
- `docs(README):` for README changes that should produce a patch release

## Maintenance notes

- Dependabot is configured only for GitHub Actions updates.
- GHCR packages are published from GitHub Actions with `GITHUB_TOKEN` and linked back to this repository through OCI source metadata.
- If Docker Hub description sync reports `Not Found`, confirm that the target Docker Hub repository exists and that the configured credentials can update its metadata.

## License

GNU General Public License. See [LICENSE](LICENSE).

## Author

Melih Savdert
