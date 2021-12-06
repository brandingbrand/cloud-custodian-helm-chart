#!/usr/bin/env bash


# optional shellcheck options
# shellcheck enable=add-default-case
# shellcheck enable=avoid-nullary-conditions
# shellcheck enable=check-unassigned-uppercase
# shellcheck enable=deprecate-which
# shellcheck enable=quote-safe-variables
# shellcheck enable=require-variable-braces


# IMPORT ENV VARS HERE ##


# ENV SETTINGS ##########
set -e                      # exit all shells if script fails
set -u                      # exit script if uninitialized variable is used
set -o pipefail             # exit script if anything fails in pipe
shopt -s failglob           # fail on regex expansion fail
shopt -s nullglob           # enables recursive globbing
IFS=$'\n\t'



# GLOBALS ###############
declare -ra ARGS=("${@}")
# "${1}" = cloud_custodian_chart_dirpath
# "${2}" = chart_museum_username
# "${3}" = chart_museum_password
# "${4}" = chart_museum_url


#########################
# UTILITY FUNCTIONS  ####
#########################
function get_script_filename(){
  basename "${0}"
}


function get_calling_dirpath(){
  pwd
}


function get_script_dirpath(){
  cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
}


function get_script_filepath(){
  echo "$(get_script_dirpath)/$(get_script_filename)"
}


function verify_dependency(){ 
  hash "${@}" || exit 127; 
}


# <shellcheck> directive applies to this entire function and this function only
# shellcheck disable=SC2016,SC1003
function usage(){
  echo; echo;
  echo '==== PRINTING USAGE BY DEFAULT ============================================================='
  get_script_filename
  get_script_filepath
  echo
  echo '<< ARGUMENT ORDER >>'
  echo '# "${1}" = cloud_custodian_chart_dirpath'
  echo '# "${2}" = chart_museum_username'
  echo '# "${3}" = chart_museum_password'
  echo '# "${4}" = chart_museum_url | DEFAULT: "https://charts.in.bbhosted.com"'
  echo
  echo "<< EXAMPLE >>"
  echo "$ ./$(get_script_filename) \ "
  echo '     "${HOME}/<path_to_helm_chart>/cloud-custodian-helm-chart/cloud-custodian-cron" \'
  echo '     "${HELM_REPO_USERNAME}" \'
  echo '     "${HELM_REPO_PASSWORD}"'
  echo '     "https://charts.in.bbhosted.com"'
  echo '==== PRINTING USAGE BY DEFAULT ============================================================='
  echo; echo;
}


function set_functions_readonly(){
  local -r all_functions="$( declare -F | sed 's/declare -f //g' )"
  for function in ${all_functions}; do
    readonly -f "${function}"
  done
}


function verify_dependencies(){
  local -ra dependencies=(
    # list all binary dependencies here
    'helm'
  )
  # shellcheck disable=SC2068
  for dependency in ${dependencies[@]}; do
    verify_dependency "${dependency}"
  done
}


function initialize(){
  set_functions_readonly
  verify_dependencies
}


function force_push_chart(){
  local -r cloud_custodian_chart_dirpath="${1}"
  local -r chart_museum_username="${2}"
  local -r chart_museum_password="${3}"
  local -r chart_museum_url="${4}"
  helm cm-push \
      --force \
      "${cloud_custodian_chart_dirpath}" \
      "${chart_museum_url}"  \
      --username="${chart_museum_username}" \
      --password="${chart_museum_password}"
}


# MAIN ##################
function main(){

  local -r _default_chart_museum_url='https://charts.in.bbhosted.com'
  local -r cloud_custodian_chart_dirpath="${1}"
  local -r chart_museum_username="${2}"
  local -r chart_museum_password="${3}"
  local -r chart_museum_url="${4:-"${_default_chart_museum_url}"}"

  usage 
  initialize
  force_push_chart "${cloud_custodian_chart_dirpath}" "${chart_museum_username}" "${chart_museum_password}" "${chart_museum_url}"
  
  exit 0
}
main "${ARGS[@]}"
# "${1}" = cloud_custodian_chart_dirpath
# "${2}" = chart_museum_username
# "${3}" = chart_museum_password
# "${4}" = chart_museum_url
