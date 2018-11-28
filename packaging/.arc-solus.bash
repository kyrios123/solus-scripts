#!/bin/bash
#
# To use this file, add the following to your ~/.bashrc
#
#   if [ -f ~/.arc-solus.bash ] ; then
#       . ~/.arc-solus.bash
#   fi
#
# You must add your Phabricator token in the "PhabTOKEN" variable.
# It can be found by going into your Phabricator -> User -> Settings -> Conduct API Tokens
#
# Note: "jq" must be installed ( sudo eopkg it jq )
#

PhabTOKEN="PUT-YOUR-TOKEN-HERE"
PhabURL="https://dev.getsol.us"


# input: repo name
# output: local & remote release numbers
# return: 0 if release has correctly been bumped
_check_rel_num() {
    local fn="package.yml"
    local pattern="^release"

    if [[ -f pspec.xml ]]; then
        fn="pspec.xml"
        pattern="<Update release="
    fi

    local remNum=$(curl --silent \
        ${PhabURL}/api/diffusion.searchquery \
        -d api.token=${PhabTOKEN} \
        -d path=./${fn} \
        -d grep=${pattern} \
        -d repository=$1 \
        -d branch=master | jq -r '.result[]' | grep "release" | sed 's/[^0-9]*//g')

    local locNum=$(grep -m 1 "${pattern}" ${fn} | sed 's/[^0-9]*//g')

    rc=$((locNum - remNum -1))

    if [[ $rc -ne 0 ]]; then
        echo "Invalid release number: $locNum (local) vs $remNum (remote)"
    fi

    return $rc
}

# input: repo name
# output: repositoryPHID
_get_repositoryPHID() {
    local rphid=$(curl --silent \
        ${PhabURL}/api/diffusion.repository.search \
        -d api.token=${PhabTOKEN} \
        -d queryKey=active \
        -d limit=1 \
        -d constraints[shortNames][0]=$1 | jq -r '.result.data[0].phid')
    echo $rphid
}

# input: repo name
# output: active diff(s)
# return: 0 no diff, 1 active diff(s)
_get_active_diff() {
    local rphid=$(_get_repositoryPHID $1)
    local rc=0

    curl --silent \
        ${PhabURL}/api/differential.revision.search \
        -d api.token=${PhabTOKEN} \
        -d order=newest \
        -d queryKey=active \
        -d constraints[repositoryPHIDs][0]=${rphid} | jq -e -r '.result.data[] | ("Active diff D" + (.id|tostring) + ": " + .fields.title)'

    if [[ $? -eq 0 ]]; then
        rc=1
    fi

    return $rc
}

arc() {
    local repo=${PWD##*/}
    local rc=0

    if [[ $1 == diff ]]; then
        _get_active_diff "${repo}"
        [[ $? -ne 0 ]] && rc=1
        _check_rel_num "${repo}"
        [[ $? -ne 0 ]] && rc=1
    fi

    if [[ $rc -ne 0 ]]; then
        read -r -n 1 -p "Do you want to continue? [y/N] "
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi

    command arc $@
}
