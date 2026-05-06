#!/usr/bin/env bash

set -e
set -o errexit
set -o errtrace

error_handler() {
    echo "Error occurred in script at line: ${BASH_LINENO[0]}, command: '${BASH_COMMAND}'"
}

trap 'error_handler' ERR

REPO_URL=$1
REPO_BRANCH=$2
BUILD_DIR=$3
COMMIT_HASH=$4

# Convert BUILD_DIR to absolute path
if [[ "$BUILD_DIR" != /* ]]; then
    BUILD_DIR="$(pwd)/$BUILD_DIR"
fi

FEEDS_CONF="feeds.conf.default"
GOLANG_REPO="https://github.com/sbwml/packages_lang_golang"
GOLANG_BRANCH="26.x"
THEME_SET="argon"
LAN_ADDR="192.168.1.1"

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
BASE_PATH=${BASE_PATH:-$SCRIPT_DIR}

source "$SCRIPT_DIR/modules/general.sh"
source "$SCRIPT_DIR/modules/feeds.sh"
source "$SCRIPT_DIR/modules/packages.sh"
source "$SCRIPT_DIR/modules/system.sh"
source "$SCRIPT_DIR/modules/cups.sh"
source "$SCRIPT_DIR/modules/docker.sh"


main() {
    # === 基础源码/编译环境 ===
    clone_repo
    clean_up
    reset_feeds_conf
    update_feeds
    remove_unwanted_packages
    remove_tweaked_packages

    # === 基础系统配置 ===
    fix_default_set
    fix_miniupnpd
    update_default_lan_addr
    remove_something_nss_kmod
    update_affinity_script
    change_cpuusage
    set_build_signature
    update_nss_diag
    fix_compile_coremark
    update_dnsmasq_conf
    add_backup_info_to_sysupgrade
    update_script_priority
    fix_kconfig_recursive_dependency
    install_feeds

    # === NSS 硬件相关 ===
    # update_ath11k_fw: 已禁用，qosmio/openwrt-ipq 源码已含标准 ath11k-firmware
    # update_ath11k_fw
    update_nss_pbuf_performance

    # === 基础工具/编译修复 ===
    change_dnsmasq2full
    fix_mk_def_depends
    update_golang
    check_default_settings
    install_opkg_distfeeds
    remove_attendedsysupgrade
    fix_rust_compile_error
    fix_openssl_ktls
    fix_opkg_check
    fix_cups_libcups_avahi_depends
    update_nginx_ubus_module
    update_uwsgi_limit_as
    update_menu_location
    fix_quectel_cm
    fix_pbr_ip_forward
}

main "$@"
