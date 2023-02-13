#!/bin/bash

# Sample script to configure the non-ovs portion of the networking
# recipe to cross-compile for the ES2K ACC platform.

if [ -z "${SDKTARGETSYSROOT}" ]; then
    echo ""
    echo "Error: SDKTARGETSYSROOT is not defined!"
    echo "Did you forget to source the environment variables?"
    echo ""
    exit 1
fi

_SYSROOT=${SDKTARGETSYSROOT}

# Default values
_BLD_DIR=build
_BLD_TYPE=RelWithDebInfo
_DEPS_DIR="${DEPEND_INSTALL:-//opt/deps}"
_DRY_RUN=false
_HOST_DIR="${HOST_INSTALL:-setup/host-deps}"
_OVS_DIR="${OVS_INSTALL:-//opt/ovs}"
_PREFIX=install
_SDE_DIR="${SDE_INSTALL:-//opt/p4sde}"
_TOOLFILE=${CMAKE_TOOLCHAIN_FILE}

# Displays help text
print_help() {
    echo ""
    echo "Configure recipe build"
    echo ""
    echo "Options:"
    echo "  --build=PATH     -B  Build directory path [${_BLD_DIR}]"
    echo "  --deps=PATH      -D  Target dependencies directory [${_DEPS_DIR}]"
    echo "  --dry-run        -n  Display cmake parameters and exit"
    echo "  --hostdeps=PATH  -H  Host dependencies directory [${_HOST_DIR}]"
    echo "  --ovs=PATH       -O  OVS install directory [${_OVS_DIR}]"
    echo "  --prefix=PATH    -P  Install directory prefix [${_PREFIX}]"
    echo "  --sde=PATH       -S  SDE install directory [${_SDE_DIR}]"
    echo ""
    echo "Environment variables:"
    echo "  DEPEND_INSTALL - Default target dependencies directory"
    echo "  HOST_INSTALL - Default host dependencies directory"
    echo "  OVS_INSTALL - Default OVS install directory"
    echo "  SDE_INSTALL - Default SDE install directory"
    echo ""
    echo "'//' at the beginning of a file path will be replaced with the"
    echo "sysroot directory path."
    echo ""
}

# Parse options
SHORTOPTS=B:D:H:O:P:S:T:hn
LONGOPTS=build:,deps:,dry-run,hostdeps:,help,ovs:,prefix:,sde:,toolchain:

eval set -- `getopt -o ${SHORTOPTS} --long ${LONGOPTS} -- "$@"`

while true ; do
    case "$1" in
    -B|--build)
        echo "Build directory: $2"
        _BLD_DIR=$2
        shift 2 ;;
    -D|--deps)
        _DEPS_DIR=$2
        shift 2 ;;
    -H|--hostdeps)
        _HOST_DIR=$2
        shift 2 ;;
    -h|--help)
        print_help
        exit 99 ;;
    -n|--dry-run)
        _DRY_RUN=true
        shift 1 ;;
    -O|--ovs)
        _OVS_DIR=$2
        shift 2 ;;
    -P|--prefix)
        echo "Install prefix: $2"
        _PREFIX=$2
        shift 2 ;;
    -S|--sde)
        _SDE_DIR=$2
        shift 2 ;;
    -T|--toolchain)
        _TOOLFILE=$2
        shift 2 ;;
    --)
        shift
        break ;;
    *)
        echo "Invalid parameter: $1"
        exit 1 ;;
    esac
done

# Substitute ${_SYSROOT}/ for // prefix
[ "${_DEPS_DIR:0:2}" = "//" ] && _DEPS_DIR=${_SYSROOT}/${_DEPS_DIR:2}
[ "${_HOST_DIR:0:2}" = "//" ] && _HOST_DIR=${_SYSROOT}/${_HOST_DIR:2}
[ "${_OVS_DIR:0:2}" = "//" ] && _OVS_DIR=${_SYSROOT}/${_OVS_DIR:2}
[ "${_SDE_DIR:0:2}" = "//" ] && _SDE_DIR=${_SYSROOT}/${_SDE_DIR:2}

if [ "${_DRY_RUN}" = "true" ]; then
    echo ""
    echo "CMAKE_BUILD_TYPE=${_BLD_TYPE}"
    echo "CMAKE_INSTALL_PREFIX=${_PREFIX}"
    echo "CMAKE_TOOLCHAIN_FILE=${_TOOLFILE}"
    echo "DEPEND_INSTALL_DIR=${_DEPS_DIR}"
    echo "HOST_DEPEND_DIR=${_HOST_DIR}"
    echo "OVS_INSTALL_DIR=${_OVS_DIR}"
    echo "SDE_INSTALL_DIR=${_SDE_DIR}"
    echo ""
    exit 0
fi

rm -fr ${_BLD_DIR} ${_PREFIX}

cmake -S . -B ${_BLD_DIR} \
    -DCMAKE_BUILD_TYPE=${_BLD_TYPE} \
    -DCMAKE_INSTALL_PREFIX=${_PREFIX} \
    -DCMAKE_TOOLCHAIN_FILE=${_TOOLFILE} \
    -DDEPEND_INSTALL_DIR=${_DEPS_DIR} \
    -DHOST_DEPEND_DIR=${_HOST_DIR} \
    -DOVS_INSTALL_DIR=${_OVS_DIR} \
    -DSDE_INSTALL_DIR=${_SDE_DIR} \
    -DSET_RPATH=TRUE \
    -DES2K_TARGET=ON

#cmake --build ${_BLD_DIR} -j8 --target install
