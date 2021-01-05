# shellcheck shell=bash

function install_heroku() {
  install \
    --application-name "Heroku CLI" \
    --snap-name "heroku" \
    --snap-prefix "--classic" \
    --prefer-snap \
    --mac-package-name "heroku/brew/heroku"
}
