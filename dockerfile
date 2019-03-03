# Feel free to switch to testing if sid proves unstable; no other changes
# should be necessary.
from debian:sid

# mainly copy the .vimrc for the mouse setting to easily cut/paste into docker
add dotvimrc /etc/vim/vimrc.local
# the stock sources only have main instead of contrib and non-free.
# we'll need those repos to get the build dependencies for wine.
add sources.list /etc/apt/sources.list

# get x86 packages if needed
run dpkg --add-architecture i386

# get whatever apt packages we need
run apt-get update && apt-get install -y aptitude && aptitude install -y \
  git \
  vim

run apt-get build-dep -y wine

# could be anywhere, but work in /home/someuser for similarity to normal system
workdir /home/kewluser
run git clone git://source.winehq.org/git/wine.git
workdir /home/kewluser/wine
# apply mwo wine changes
add mwo.patch .
run git checkout wine-4.3
run git apply mwo.patch
run ./configure --enable-win64
run make -j4
run mkdir /home/kewluser/wineprefix
env DESTDIR="/home/kewluser/wineout"
run make install

# dxvk
workdir /home/kewluser
run git clone https://github.com/doitsujin/dxvk
env WINEPREFIX="$DESTDIR"
run /home/kewluser/wineout/usr/local/bin/winecfg
workdir /home/kewluser/dxvk
#run bash setup_dxvk.sh install
run apt-get build-dep -y dxvk
run apt-get install -y gcc-mingw-w64
run apt-get install -y g++-mingw-w64
run apt-get install -y mingw-w64-x86-64-dev
run git checkout v1.0
run bash package-release.sh master ./out --no-package 
