#!/usr/bin/env bash
#
# Bootstrap a pkgsrc prefix.
#

set -eux

#
# First calculate our checkout directory and workspace, which will be one
# directory above.  We do this rather than using GITHUB_* variables to ensure
# they are consistent (i.e. Cygwin vs native Windows), and "pwd -P" ensures
# the path is canonical to avoid buildlink issues.
#
CI_WORKSPACE="$(cd ..; pwd -P)"
CI_SRCDIR="$(pwd -P)"

#
# Set up some default variables.  These can be set by the action, but are also
# specified here even if empty so that we can use 'set -eu' above.
#
: "${CI_BOOTSTRAP_ARGS:=}"
: "${CI_BOOTSTRAP_TAR:=bootstrap.tar}"
: "${CI_MAKE_JOBS:=4}"
: "${CI_PREFIX:=/usr/pkg}"
: "${CI_SYSTEM_PATH:=/sbin:/bin:/usr/sbin:/usr/bin}"
: "${CI_TMPDIR==${CI_WORKSPACE}/tmp}"
: "${CI_WRKDIR:=${CI_SRCDIR}/wrkdir}"
: "${CI_UNPRIVILEGED:=true}"

#
# In many places we only run this script if we already detected that we need
# to generate a bootstrap kit, but adding an early bailout helps other places
# where it is simpler to just run the script and let it figure out what to do.
#
if [ -f "${CI_BOOTSTRAP_TAR}" ]; then
	echo "Bootstrap kit ${CI_BOOTSTRAP_TAR} already exists."
	exit 0
fi

PATH="${CI_SYSTEM_PATH}"

#
# Set up unprivileged support or sudo.
#
if ${CI_UNPRIVILEGED}; then
	CI_BOOTSTRAP_ARGS="${CI_BOOTSTRAP_ARGS} --unprivileged"
	CI_SUDO=
else
	CI_SUDO=sudo
fi

#
# Ensure we start with clean work areas.  CI_PREFIX and CI_WRKDIR must not
# exist, bootstrap will create them.  Some packages can leave directories with
# insufficient permissions so we need to ensure they are fixed-up first.
#
${CI_SUDO} chmod -R u+w ${CI_PREFIX} ${CI_TMPDIR} ${CI_WRKDIR} 2>/dev/null || true
${CI_SUDO} rm -rf ${CI_PREFIX} ${CI_TMPDIR} ${CI_WRKDIR}
${CI_SUDO} mkdir -p ${CI_TMPDIR}

cat >${CI_TMPDIR}/bootstrap-include.mk <<EOF
ALLOW_VULNERABLE_PACKAGES=	yes
FAILOVER_FETCH=			yes
MAKE_JOBS=			${CI_MAKE_JOBS}
NO_PKGTOOLS_REQD_CHECK=		yes
PKG_DEVELOPER=			yes
SKIP_LICENSE_CHECK=		yes
USE_INDIRECT_DEPENDS=		yes
X11_TYPE=			modular
EOF

mkdir -p $(dirname ${CI_BOOTSTRAP_TAR})
cd ${CI_SRCDIR}/bootstrap
${CI_SUDO} ./bootstrap \
	--binary-kit=${CI_BOOTSTRAP_TAR} \
	--make-jobs=${CI_MAKE_JOBS} \
	--mk-fragment=${CI_TMPDIR}/bootstrap-include.mk \
	--prefix=${CI_PREFIX} \
	--workdir=${CI_WRKDIR} \
	${CI_BOOTSTRAP_ARGS}
