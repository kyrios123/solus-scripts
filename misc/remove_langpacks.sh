#!/bin/bash
#########################################################################
# Remove Firefox/Thunderbird language packs that don't match the locale
# to speeds up application opening/closing time
# Ideally the script should be executed after each update as the
# langpacks are re-installed
#
# NOTE: This hasn't been checked in a multi-user environment in which
#       different locales are used by user sessions
#########################################################################

FF_LANGPACK_DIR="/usr/lib64/firefox/browser/extensions"
TB_LANGPACK_DIR="/usr/lib64/thunderbird/extensions/"

C="\e[33m"
R="\033[m"

echo -e "Detedted locale: ${C}${LANG}${R}"
echo
echo "The following language packs will be kept"

if [[ -d "${FF_LANGPACK_DIR}" ]]; then
    echo -e "${C}Firefox${R}"
    find "${FF_LANGPACK_DIR}" -type f -name "langpack-${LANG%_*}*@firefox.mozilla.org.xpi" -print
fi

if [[ -d "${TB_LANGPACK_DIR}" ]]; then
    echo -e "${C}Thunderbird${R}"
    find "${TB_LANGPACK_DIR}" -type f -name "langpack-${LANG%_*}*@thunderbird.mozilla.org.xpi" -print
fi
echo

# Must be root to execute this part of the script
if [[ ${EUID} -ne 0 ]]; then
    echo -e "${C}This script must be run as root${R}" 1>&2
    exit 1
fi

if [[ -d "${FF_LANGPACK_DIR}" ]]; then
    echo -e "${C}Firefox${R}"
    find "${FF_LANGPACK_DIR}" -type f -name "langpack-*@firefox.mozilla.org.xpi" -not -name "langpack-${LANG%_*}*@firefox.mozilla.org.xpi" -delete 2>/dev/null
fi

if [[ -d "${TB_LANGPACK_DIR}" ]]; then
    echo -e "${C}Thunderbird${R}"
    find "${TB_LANGPACK_DIR}" -type f -name "langpack-*@thunderbird.mozilla.org.xpi" -and -not -name "langpack-${LANG%_*}*@thunderbird.mozilla.org.xpi" -delete 2>/dev/null
fi
echo "done."
