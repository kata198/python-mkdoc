#!/bin/bash

# Support calling like   ./install.sh DESTDIR="${pkgdir}"

for arg in "$@";
do
    if ( echo "${arg}" | grep -q '^PREFIX=' );
    then
        export "${arg}"
    elif ( echo "${arg}" | grep -q '^DESTDIR=' );
    then
        export "${arg}"
    fi
done

if [ -z "${PREFIX}" ];
then
    PREFIX="/usr"
else
    if [ "${PREFIX}" != "/" ];
    then
        PREFIX="$(echo "${PREFIX}" | sed 's|[/][/]*$||g')"
        PREFIX="$(echo "${PREFIX}" | sed 's|//|/|g')"
    fi
fi
if [ -z "${DESTDIR}" ];
then
    DESTDIR=""
else
    if [ "${DESTDIR}" != "/" ];
    then
        DESTDIR="$(echo "${DESTDIR}" | sed 's|[/][/]*$||g')"
        DESTDIR="$(echo "${DESTDIR}" | sed 's|//|/|g')"
    else
        DESTDIR=''
    fi
fi

BINDIR="${DESTDIR}${PREFIX}/bin"
# Remove any double-slashes
BINDIR="$(echo "${BINDIR}" | sed 's|//|/|g')"

mkdir -p "${BINDIR}"

install -v -m 755 mkpydoc.sh "${BINDIR}"
