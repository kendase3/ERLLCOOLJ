# <3 sid
from debian:sid

# copy some .rc files
add dotvimrc /etc/vim/vimrc.local
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
# hack from https://stackoverflow.com/questions/27079898/cant-compile-wine-on-64-bit-ubuntu
#run ln -s /usr/include/freetype2 /usr/include/freetype
#run apt-get install -y mlocate
#run updatedb
#run apt-get build-dep -y wine
run ./configure --enable-win64
run make -j4
run mkdir /home/kewluser/wineprefix
env DESTDIR="/home/kewluser/wineout"
run make install
