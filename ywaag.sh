#!/bin/bash
#
# "you were always a girl" (or "you were always a guy" if that applies)
#
# See README.md.
#
# SPDX-License-Identifier: Unlicense

set -e

function usage {
	echo "usage: $0 [-h] [-ong]"
	echo "   {-h --help}      show this usage"
	echo "   -o <oldname>   old name"
	echo "   -n <newname>   new name"
	echo "   -e <newemail>  new email"
	echo "   -g <repo>      git repo"
}

OLDNAME=""
NEWMAME=""
NEWEMAIL=""
REPO=""

while getopts ":ho:n:g:" arg; do
    case ${arg} in
        h)
            usage
            exit 0
            ;;
        o)
            OLDNAME="${OPTARG}"
            ;;
        n)
            NEWNAME="${OPTARG}"
            ;;
        e)
            NEWEMAIL="${OPTARG}"
            ;;
        g)
            REPO="${OPTARG}"
            ;;
    esac
done

if [ "${REPO}" = "" ]; then
    echo "error: repository unspecified" 1>&2
    exit 1
fi
if [ "${OLDNAME}" = "" ]; then
    echo "error: old name unspecified" 1>&2
    exit 1
fi
if [ "${NEWNAME}" = "" ]; then
    NEWNAME=$(git config --global user.name)
fi
if [ "${NEWEMAIL}" = "" ]; then
    NEWEMAIL=$(git config --global user.email)
fi


rm -rf repo.tmp
git clone -- "${REPO}" repo.tmp
pushd repo.tmp

git filter-branch -f \
    --env-filter "
        if [ \"\$GIT_COMMITTER_NAME\" = \"${OLDNAME}\" ];
        then
            GIT_COMMITTER_NAME=\"${NEWNAME}\";
            GIT_COMMITTER_EMAIL=\"${NEWEMAIL}\";
        fi

        if [ \"\$GIT_AUTHOR_NAME\" = \"${OLDNAME}\" ];
        then
            GIT_AUTHOR_NAME=\"${NEWNAME}\";
            GIT_AUTHOR_EMAIL=\"${NEWEMAIL}\";
        fi
    " \
    --msg-filter "
    	sed -e \"s/${OLDNAME} <\([^>]*\)>/${NEWNAME} <${NEWEMAIL}>/g; s/${OLDNAME}/${NEWNAME}/g;\"
    " \
    --tree-filter "
    	find . -type f -exec sed --in-place -e \"s/${OLDNAME} <\([^>]*\)>/${NEWNAME} <${NEWEMAIL}>/g; s/${OLDNAME}/${NEWNAME}/g;\" {} \;
    " \
    --tag-name-filter cat \
    -- --all

git push --force
git push -f --tags
