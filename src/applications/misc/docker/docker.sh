# shellcheck shell=bash

local_dir_name=$(dirname "${BASH_SOURCE[0]}")
source "${local_dir_name}/../curl/curl.sh"

function cleanup_docker_packages() {
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    return
  fi

  local -ar DOCKER_CLEANUP_PACKAGES_COMMON_FEDORA_BASED=(
    "docker"
    "docker-client"
    "docker-client-latest"
    "docker-common"
    "docker-latest"
    "docker-latest-logrotate"
    "docker-logrotate"
    "docker-engine"
  )

  local -ar DOCKER_CLEANUP_PACKAGES_EXTRA_SE_LINUX=(
    "docker-selinux"
    "docker-engine-selinux"
  )

  local -ar DOCKER_CLEANUP_PACKAGES_COMMON_DEBIAN_BASED=(
    "docker"
    "docker-engine"
    "docker.io"
    "containerd"
    "runc"
  )

  function remove_packages() {
    local -a package_list=("$@")
    for package in "${package_list[@]}"; do
      remove_package -n "${package}"
    done
  }

  case "${LINUX_DISTRO}" in
    "${DEBIAN_DISTRO}" | "${UBUNTU_DISTRO}")
      remove_packages "${DOCKER_CLEANUP_PACKAGES_COMMON_DEBIAN_BASED[@]}"
      ;;
    "${FEDORA_DISTRO}")
      remove_packages "${DOCKER_CLEANUP_PACKAGES_COMMON_FEDORA_BASED[@]}"
      remove_packages "${DOCKER_CLEANUP_PACKAGES_EXTRA_SE_LINUX[@]}"
      ;;
    "${RHEL_DISTRO}" | "${CENTOS_DISTRO}")
      remove_packages "${DOCKER_CLEANUP_PACKAGES_COMMON_FEDORA_BASED[@]}"
      ;;
    *)
      error "Unsupported distro for docker installation: '${LINUX_DISTRO}'"
      return 1
      ;;
  esac
}

function install_docker_dependencies() {
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ] || [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
    return
  fi

  if [ "${LINUX_DISTRO_FAMILY}" != "${DEBIAN_DISTRO_FAMILY}" ]; then
    error "Unsupported distro for docker installation: '${LINUX_DISTRO}'"
    return 1
  fi

  local -ar debian_based_dependencies=(
    "apt-transport-https"
    "ca-certificates"
    "gnupg-agent"
    "software-properties-common"
  )

  install_curl

  for package in "${debian_based_dependencies[@]}"; do
    install_package -n "${package}"
  done
}

function add_docker_repository() {
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    return
  fi

  if [ "${LINUX_DISTRO_FAMILY}" == "${FEDORA_DISTRO_FAMILY}" ]; then
    install_package -n "dnf-plugins-core"
    add_package_repository -r "https://download.docker.com/linux/${LINUX_DISTRO}/docker-ce.repo"
  elif [ "${LINUX_DISTRO_FAMILY}" == "${DEBIAN_DISTRO_FAMILY}" ]; then
    # Since we know that we're on a Debian-based system, we can go ahead
    # and use dpkg to normalize the architectures instead of using the more
    # generalized `uname -m` or `arch` and then having to map them ourselves.
    local arch
    arch=$(dpkg --print-architecture)
    case "${arch}" in
      "amd64" | "arm64" | "armhf") ;;

      *)
        error "Unsupported processor architecture: '${arch}'. Unable to install Docker"
        return 1
        ;;
    esac
    local repo_url="https://download.docker.com/linux/${LINUX_DISTRO}"
    local codename
    codename="$(lsb_release -cs)"
    local repo="deb [arch=${arch}] ${repo_url} ${codename} stable"
    add_package_repository -r "${repo}"
  else
    error "Unsupported distro for docker installation: '${LINUX_DISTRO}'"
    return 1
  fi
}

function install_docker() {
  if [ "${OPERATING_SYSTEM}" == "${MAC_OS}" ]; then
    install \
      --application-name "Docker" \
      --mac-package-name "docker"
    return $?
  fi

  cleanup_docker_packages
  update_package_lists
  install_docker_dependencies
  add_remote_signing_key --key-url "https://download.docker.com/linux/${LINUX_DISTTRO}/gpg"
  add_docker_repository
  update_package_lists

  local -ar docker_packages=(
    "docker-ce"
    "docker-ce-cli"
    "containerd.io"
  )

  for package in "${docker_packages[@]}"; do
    install_package -n "${package}"
  done
}
