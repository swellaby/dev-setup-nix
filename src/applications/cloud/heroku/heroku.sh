# shellcheck shell=bash

function install_heroku() {
  local package_name="Heroku"
  install \
    --application-name "Heroku CLI" \
    --snap-name "heroku" \
    --snap-prefix "--classic" \
    --prefer-snap \
    --mac-package-name "heroku/brew/heroku"
}
