#!/bin/bash

# Serval Project Linux.conf.au 2013 telephony server setup script
# Copyright 2013 Serval Project Inc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# This script will download, build, install and configure the default
# (development branch) Serval DNA and Asterisk 1.8 with the Serval app plug-in
# to make a functional Serval telephony server.
#
# @author Andrew Bettison <andrew@servalproject.com>
#
# Usage:
#     serval-setup-lca2013 <serval-keyring-file> [<install-prefix-dir>] [<servalinstance-dir>]

STEM="$0"
STEM="${STEM##*/}"
STEM="${STEM%.*}"
export STEM

export KEYRING="${1?missing <serval-keyring-file> argument}"
export TARGET="${2:-/opt/serval}"
export INSTANCE="${3:-$TARGET/var/serval-node}"

set -e -x

# Keyring file must exist and be readable.
case "$KEYRING" in
/*);;
*) KEYRING="$PWD/$KEYRING";;
esac
[ -f "$KEYRING" -a -s "$KEYRING" ]

# Target must be absolute.
[ -z "${TARGET%%/*}" ]

# Instance path must be absolute.
[ -z "${INSTANCE%%/*}" ]

# Must be run as super-user.
[ $UID -eq 0 ]

id serval || useradd -U -m -c 'Serval Project' serval

mkdir -p "$INSTANCE" || true
chown serval:serval "$INSTANCE"
chmod g+rwxs "$INSTANCE"

mkdir -p "$TARGET" || true
chown -R serval:serval "$TARGET"

export TMP="${TMPDIR:-/tmp}/$STEM"

sudo -E -u serval $SHELL - <<'EOF'

   set -e

   mkdir "$TMP" || true
   PROGRESS="$TMP"/progress
   mkdir -p "$PROGRESS" || true

   do_task() {
      set +x
      always=false
      if [ "$1" = '--always' ]; then
         always=true
         shift
      fi
      local task=$1
      if $always || [ ! -e "$PROGRESS/$task" ]; then
         echo "Doing: $task"
         set -e -x
         cd "$TMP"
         $task
         set +x
         >"$PROGRESS/$task"
         echo "Done: $task"
      else
         echo "Already done: $task -- skipping"
      fi
      set -x
   }

   make_target_dirs() {
      mkdir -p "$TARGET"/sbin
      mkdir -p "$TARGET"/etc/asterisk
      mkdir -p "$TARGET"/etc/default
      mkdir -p "$TARGET"/etc/init.d
   }

   download_asterisk() {
      mkdir download || true
      pushd download
      wget http://developer.servalproject.org/files/asterisk/asterisk-1.8-current.tar.gz
      popd
   }

   unpack_asterisk() {
      tar xzf download/asterisk-*.tar.gz
   }

   configure_asterisk() {
      pushd "$ASTERISK_SRC"
      ./configure --prefix=/opt/serval
      popd
   }

   build_asterisk() {
      pushd "$ASTERISK_SRC"
      make
      popd
   }

   install_asterisk() {
      pushd "$ASTERISK_SRC"
      make install
      make samples
      local etcfiles=$(echo "$TARGET"/etc/asterisk/*)
      [ -n "$etcfiles" -a "$etcfiles" != "$TARGET/etc/asterisk/*" ]
      make DESTDIR="$TARGET" config
      [ -x "$TARGET"/etc/init.d/asterisk ]
      [ -s "$TARGET"/etc/default/asterisk ]
      sed -i \
         -e 's/^AST_USER/#&/' \
         -e 's/^AST_GROUP/#&/' \
         "$TARGET"/etc/default/asterisk
      echo 'AST_USER=serval' >>"$TARGET"/etc/default/asterisk
      echo 'AST_GROUP=serval' >>"$TARGET"/etc/default/asterisk
      popd
   }

   clone_serval_dna() {
      rm -rf serval-dna
      git clone git://github.com/servalproject/serval-dna.git
   }

   update_serval_dna() {
      pushd serval-dna
      git pull
      popd
   }

   configure_serval_dna() {
      pushd serval-dna
      autoconf
      ./configure --prefix=/opt/serval
      popd
   }

   build_serval_dna() {
      pushd serval-dna
      make servald directory_service libmonitorclient.so libmonitorclient.a
      popd
   }

   install_serval_dna() {
      pushd serval-dna
      cp -a servald directory_service "$TARGET"/sbin
      cp -a Debian/etc/init.d/serval-dna "$TARGET"/etc/init.d
      cp -a Debian/etc/default/serval-dna "$TARGET"/etc/default
      sed -i \
         -e 's/^SERVALINSTANCE_PATH=/#&/' \
         -e 's/^USER=/#&/' \
         -e 's/^DAEMON=/#&/' \
         -e 's/^START_DAEMON=/#&/' \
         "$TARGET"/etc/default/serval-dna
      echo "START_DAEMON=yes" >>"$TARGET"/etc/default/serval-dna
      echo "USER=serval" >>"$TARGET"/etc/default/serval-dna
      echo "DAEMON=$TARGET/sbin/servald" >>"$TARGET"/etc/default/serval-dna
      echo "SERVALINSTANCE_PATH=$INSTANCE" >>"$TARGET"/etc/default/serval-dna
      cat >"$INSTANCE"/serval.conf <<FUBAR
dna.helper.executable=$TARGET/sbin/directory_service
interfaces.0.match=eth0
interfaces.0.mdp_tick_ms=0
interfaces.0.send_broadcasts=0
interfaces.0.default_route=1
log.file=serval.log
FUBAR
      cp "$KEYRING" "$INSTANCE"/serval.keyring
      > "$INSTANCE"/serval.log
      popd
   }

   clone_app_servaldna() {
      rm -rf app_servaldna
      git clone git://github.com/servalproject/app_servaldna.git
   }

   update_app_servaldna() {
      pushd app_servaldna
      git pull
      popd
   }

   build_app_servaldna() {
      pushd app_servaldna
      make AST_ROOT="$ASTERISK_SRC" SERVAL_ROOT="$TMP"/serval-dna
      popd
   }

   install_app_servaldna() {
      pushd app_servaldna
      cp -a app_servaldna.so "$TARGET"/lib/asterisk/modules
      cp -a servaldnaagi.py "$TARGET"/lib/asterisk
      cp -a conf/* "$TARGET"/etc/asterisk
      sed -i \
         -e "s|^SERVALD_AGI *=.*|SERVALD_AGI=$TARGET/lib/asterisk/servaldnaagi.py|" \
         -e "s|^SERVALD_BIN *=.*|SERVALD_BIN=$TARGET/sbin/servald|" \
         -e "s|^SERVALD_INSTANCE *=.*|SERVALD_INSTANCE=$INSTANCE|" \
         "$TARGET"/etc/asterisk/extensions.conf
      sed -i \
         -e "s|^instancepath *=.*|instancepath=$INSTANCE|" \
         "$TARGET"/etc/asterisk/servaldna.conf
      popd
   }

   set -x
   do_task --always make_target_dirs
   do_task clone_serval_dna
   [ -d "$TMP"/serval-dna ]
   do_task --always update_serval_dna
   do_task clone_app_servaldna
   [ -d "$TMP"/app_servaldna ]
   do_task --always update_app_servaldna
   do_task download_asterisk
   [ -r "$TMP"/download/asterisk*.tar.gz ]
   do_task unpack_asterisk
   ASTERISK_SRC=$(echo "$TMP"/asterisk*)
   [ -d "$ASTERISK_SRC" ]
   do_task configure_asterisk
   do_task build_asterisk
   do_task --always install_asterisk
   do_task configure_serval_dna
   do_task build_serval_dna
   do_task --always install_serval_dna
   do_task build_app_servaldna
   do_task --always install_app_servaldna

EOF

link_system() {
   # Make a symbolic link but don't clobber a real system file or directory.
   local src="$1"
   local dst="$2"
   if [ -L "$dst" -o ! -e "$dst" ]; then
      rm -f "$dst"
      ln -s "$src" "$dst"
   fi
}

# Link to reduce the chance of another (rogue) servald being started.
link_system "$TARGET"/var/serval-node /var/serval-node

# Links for convenience
link_system "$TARGET"/etc/asterisk /etc/asterisk
link_system "$TARGET"/var/log/asterisk /var/log/asterisk

# Links for auto-startup on boot and auto-shutdown.
link_system "$TARGET"/etc/init.d/serval-dna /etc/init.d/serval-dna
link_system "$TARGET"/etc/default/serval-dna /etc/default/serval-dna
link_system "$TARGET"/etc/init.d/asterisk /etc/init.d/asterisk
link_system "$TARGET"/etc/default/asterisk /etc/default/asterisk
update-rc.d -f serval-dna remove
update-rc.d -f asterisk remove
update-rc.d serval-dna defaults 81 18
update-rc.d asterisk defaults 82 17
