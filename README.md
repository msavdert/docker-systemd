# Docker images with systemd support

[![Build](https://github.com/msavdert/docker-systemd/actions/workflows/build-and-push.yml/badge.svg?branch=main)](https://github.com/msavdert/docker-systemd/actions/workflows/build-and-push.yml)
[![Release](https://github.com/msavdert/docker-systemd/actions/workflows/release.yml/badge.svg)](https://github.com/msavdert/docker-systemd/actions/workflows/release.yml)

Curated multi-distribution Docker images with working systemd support for Ansible role testing, Molecule scenarios, and CI environments that need a realistic init system.

Images are published to `melihsavdert/docker-systemd` with distro-version tags.

## Why this repository exists

Most base images are intentionally minimal and do not behave like a real VM or host booted with systemd. That is a problem for infrastructure testing, especially when roles or playbooks expect:

- `systemctl` to work
- service units to exist
- cgroup mounting behavior compatible with systemd
- a predictable distro-specific package manager and filesystem layout

This repository keeps those images in one place with a consistent tagging model and repeatable build automation.

## Supported tags and platforms

- `almalinux-8` (`linux/amd64`, `linux/arm64`)
- `almalinux-9` (`linux/amd64`, `linux/arm64`)
- `almalinux-10` (`linux/amd64`, `linux/arm64`)
- `amazonlinux-2` (`linux/amd64`)
- `amazonlinux-2023` (`linux/amd64`, `linux/arm64`)
- `centos-7` (`linux/amd64`)
- `debian-10` (`linux/amd64`, `linux/arm64`)
- `debian-11` (`linux/amd64`, `linux/arm64`)
- `debian-12` (`linux/amd64`, `linux/arm64`)
- `debian-13` (`linux/amd64`, `linux/arm64`)
- `fedora-39` (`linux/amd64`, `linux/arm64`)
- `fedora-40` (`linux/amd64`, `linux/arm64`)
- `fedora-41` (`linux/amd64`, `linux/arm64`)
- `fedora-42` (`linux/amd64`, `linux/arm64`)
- `fedora-43` (`linux/amd64`, `linux/arm64`)
- `opensuse-15.6` (`linux/amd64`, `linux/arm64`)
- `opensuse-16.0` (`linux/amd64`, `linux/arm64`)
- `opensuse-tumbleweed` (`linux/amd64`, `linux/arm64`)
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

No `latest` tag is published by design. Consumers should choose an explicit distro-version tag so tests remain deterministic.

## Repository layout

Each distribution keeps flat, versioned Dockerfiles:

- `almalinux/8.Dockerfile`
- `almalinux/9.Dockerfile`
- `almalinux/10.Dockerfile`
- `amazonlinux/2.Dockerfile`
- `amazonlinux/2023.Dockerfile`
- `centos/7.Dockerfile`
- `debian/10.Dockerfile`
- `debian/11.Dockerfile`
- `debian/12.Dockerfile`
- `debian/13.Dockerfile`
- `fedora/39.Dockerfile`
- `fedora/40.Dockerfile`
- `fedora/41.Dockerfile`
- `fedora/42.Dockerfile`
- `fedora/43.Dockerfile`
- `opensuse/15.6.Dockerfile`
- `opensuse/16.0.Dockerfile`
- `opensuse/tumbleweed.Dockerfile`
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

## Image design rules

All images in this repository follow the same baseline rules:

- install only the packages needed to make systemd usable in CI
- prune non-essential unit wants to reduce boot noise and side effects
- expose `/sys/fs/cgroup`
- start with a systemd entrypoint instead of a shell wrapper
- keep distro-specific behavior only where the base image requires it

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

### Direct container usage

```bash
docker run -d --name systemd-ubuntu-24.04 \
  --privileged \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  melihsavdert/docker-systemd:ubuntu-24.04
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

## Automation

The repository ships with four distinct automation layers:

- `validate.yml` builds and lints images on pull requests
- `build-and-push.yml` publishes multi-arch images on `main` and on a weekly schedule
- `release.yml` creates GitHub releases and updates `CHANGELOG.md` using semantic-release
- `dockerhub-description.yml` syncs `README.md` to Docker Hub repository metadata

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

## Maintenance notes

- Dependabot is configured only for GitHub Actions updates. That keeps workflow actions current without creating noisy dependency churn in the images themselves.
- If Docker Hub description sync reports `Not Found`, verify that the Docker Hub repository exists and optionally set a repository variable named `DOCKERHUB_REPOSITORY` if the target repository name differs from `melihsavdert/docker-systemd`.

## License

GNU General Public License. See [LICENSE](LICENSE).

## Author

Melih Savdert
