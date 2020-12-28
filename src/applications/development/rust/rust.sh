# shellcheck shell=bash

local_dir_name=$(dirname "${BASH_SOURCE[0]}")
source "${local_dir_name}/../../misc/curl/curl.sh"

function install_rust() {
  tool_installed "curl"
  if [ $? -ne 0 ]; then
    install_curl
  fi

  local components=""

  for arg in "$@"; do
    case "${arg}" in
      -r | --install-rustfmt)
        components="${components} rustfmt"
        ;;
      -c | --install-clippy)
        components="${components} clippy"
        ;;
      *)
        error "Invalid 'install_rust' arg: '${arg}'. This is a bug!"
        exit 1
        ;;
    esac
  done

  if [ -n "${components}" ]; then
    components="-c${components}"
  fi

  curl \
    --proto '=https' \
    --tlsv1.2 \
    -sSf https://sh.rustup.rs |
    sh -s -- -y ${components}

  source $HOME/.cargo/env
}
