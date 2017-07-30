#!/bin/bash
# vim: set ts=4 sw=4 st=4 expandtab

#  mkpydoc.sh - 
#    Copyright (c) 2015, 2016, 2017 Timothy Savannah, All Rights Reserved
#
#   Licensed under the terms of the GNU General Purpose License (GPL) Version 3.0
#
#    If you did not recieve a copy of the license as LICENSE with this distribution,
#      it can be found at: https://github.com/kata198/python-mkdoc/blob/master/LICENSE
#
#  You MAY redistribute this script and modify the "DEFAULT_PROJECT_NAME" line to match your project,
#    without open-sourcing your entire project. That single line is considered "public domain" for this reason.

# mkpydoc.sh - Generate pydoc for an arbitrary project (via argument), or
#              if DEFAULT_PROJECT_NAME is set within this file then
#               this script can be copied into your project's root directory
#               and executed without argment to generate using thatname.


_PYTHON_MKDOC_VERSION="0.1.0"

# DEFAULT_PROJECT_NAME - Set to the name of the folder containing your package
#    (i.e. the folder containing the highest-level __init__.py)
#
#    This will be used in lieu of an argument (so just running ./mkpydoc.sh vs ./mkpydoc.sh "myFolderName")
#
#  The single line below (DEFAULT_PROJECT_NAME=...) is considered public domain and may be modified and redistributed
#    without the restrictions of the GPL. All other lines are GPLv3
DEFAULT_PROJECT_NAME="YOUR_PROJECT_DIR_HERE"

if [ -z "$1" ];
then
    if [ "${DEFAULT_PROJECT_NAME}" = "YOUR_PROJECT_DIR_HERE" ];
    then
        printf "Error: Missing argument of root package folder, and DEFAULT_PROJECT_NAME within the script was not set.\n\n" >&2
        exit 1;
    fi
    PROJECT_NAME="${DEFAULT_PROJECT_NAME}"
else
    PROJECT_NAME="${1}"
fi

if [ ! -d "${PROJECT_NAME}" ];
then
    printf "Error: No such directory \"%s\"\n\n" "${PROJECT_NAME}" >&2
    exit 2;
fi

if [ ! -e "${PROJECT_NAME}/__init__.py" ];
then
    printf "Error: Directory \"%s\" does not contain __init__.py, and thus cannot be imported as a module. Check path?\n\n" "${PROJECT_NAME}" >&2
    exit 2;
fi


if [ "$(basename "${PROJECT_NAME}")" != "${PROJECT_NAME}" ] || [ ! -d "./${PROJECT_NAME}" ];
then
    printf "Error: Directory \"%s\" must be present in the current directory.\n  Navigate to the project root directory and try again.\n\n" "${PROJECT_NAME}" >&2
    exit 2;
fi


# note_action - Print an "action" (what the script is doing), in a noticable format different from output.
#
#   Args are same as printf (use "%s" and extra args for variables, etc.)
#
note_action() {
    
    FORMAT_STR="${1}"
    shift

    echo -en "\e[34m"

    printf "==> ${FORMAT_STR}" "$@"

    echo -en "\e[39m"

}

# note_failure - Note a failure to stderr, in a noticable format different from output.
#
#   Args are same as printf (use "%s" and extra args for variables, etc.)
#
note_failure() {
    FORMAT_STR="${1}"
    shift

    echo -en "\e[31m" >&2

    printf "==X ${FORMAT_STR}" "$@" >&2

    echo -en "\e[39m" >&2

}



note_action "Scanning for .py files within \"%s\"\n" "${PROJECT_NAME}"

shopt -s globstar
shopt -s nullglob

ALL_FILES="$(echo ${PROJECT_NAME}/**.py ${PROJECT_NAME}/**/*.py)"

if [ -z "${ALL_FILES}" ];
then
    printf "Error: No .py files found in \"%s\"\n\n" "${PROJECT_NAME}" >&2
    exit 2;
fi

ALL_FILES="$(echo "${ALL_FILES}" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"

ALL_MODS="$(echo "${ALL_FILES}" | tr ' ' '\n' | sed -e 's|/|.|g' -e 's|.py$||g' -e 's|.__init__$||g' | tr '\n' ' ')"

printf "Found the following modules: %s\n\n" "$(echo "${ALL_MODS}" | tr '\n' ' ')"


note_action "Generating pydocs...\n"
pydoc -w ${ALL_MODS}

note_action "Preparing 'doc' dir\n"
mkdir -p doc

python -c "import AdvancedHTMLParser"
HAS_ADVANCED_HTML_PARSER_MOD=$?

if [ ${HAS_ADVANCED_HTML_PARSER_MOD} -ne 0 ];
then
    note_failure "Python module AdvancedHTMLParser is not found!\n"
    note_failure "  Cannot convert local paths to relative web-safe paths or other cleanup tasks.\n\n"
else
    note_action "Converting absolute local paths to relative web-safe paths...\n"
fi

# TASK: Iterate through each generated file, clean up (assuming AdvancedHTMLParser is present),
#         and move into "doc" directory.

for fnamePy in ${ALL_FILES};
do
    fname="$(echo "${fnamePy}" | sed 's/.py$/.html/g' | tr '/' '.' | sed 's/\.__init__//g' )"

    if [ "${HAS_ADVANCED_HTML_PARSER_MOD}" -eq 0 ];
    then
        python <<EOT

import AdvancedHTMLParser
import sys

if __name__ == '__main__':

    filename = "${fname}"

    parser = AdvancedHTMLParser.AdvancedHTMLParser()
    parser.parseFile(filename)

    em = parser.filter(tagName='a', href='.')

    if len(em) == 0:
        sys.exit(0)

    em = em[0]

    em.href = '${PROJECT_NAME}.html'

    parentNode = em.parentNode

    emIndex = parentNode.children.index(em)

    i = len(parentNode.children) - 1
    
    while i > emIndex:
        parentNode.removeChild( parentNode.children[i] )
        i -= 1


    with open(filename, 'wt') as f:
        f.write(parser.getHTML())

EOT
        RET=$?

        if [ "${RET}" -ne 0 ];
        then
            note_failure "Failed to clean up \"%s\" (from \"%s\"). Exit code: %d\n" "${fname}" "${fnamePy}" "${RET}"
        fi
    fi

    mv "${fname}" 'doc/'
    if [ $? -ne 0 ];
    then
        note_failure "Failed to move \"%s\" into \"doc\" directory.\n" "${fname}"
    fi

done

#  TASK: prepare to be ready to zip up for upload by symlinking index.html to main module pydoc

pushd "doc" >/dev/null 2>&1

rm -f index.html
if [ $? -ne 0 ];
then
    note_failure "Failed to remove doc/index.html in order to re-link\n"
else
    ln -s ${PROJECT_NAME}.html index.html
fi


popd >/dev/null 2>&1
