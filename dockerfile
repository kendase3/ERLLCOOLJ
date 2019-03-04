# Feel free to switch to testing if sid proves unstable; no other changes
# should be necessary.
from debian:stretch

# mainly copy the .vimrc for the mouse setting to easily cut/paste into docker
add dotvimrc /etc/vim/vimrc.local
# the stock sources only have main instead of contrib and non-free.
# we'll need those repos to get the build dependencies for wine.
#add sources.list /etc/apt/sources.list

# get x86 packages if needed
run dpkg --add-architecture i386

# get whatever apt packages we need
run apt-get update && apt-get install -y aptitude && aptitude install -y \
  git \
  gcc-mingw-w64 \
  g++-mingw-w64 \
  mingw-w64-x86-64-dev \
  vim

run apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

#add winehq repo
run curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
run echo 'deb http://dl.winehq.org/wine-builds/debian stretch main' > /etc/apt/sources.list.d/winehq.list
#add docker repo
run curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
run add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
#add backports
run echo 'deb http://ftp.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list
run echo 'deb-src http://ftp.us.debian.org/debian/ stretch main contrib non-free' > /etc/apt/sources.list.d/wine-apt-get-src.list
#install host build-time dependencies
run apt-get update
# NOTE(ken): changed multilib from 6 to 7 on sid
run apt-get install -y gpgv2 gnupg2 g++ g++-multilib mingw-w64 git docker-ce fontforge-nox python-debian
run apt-get -y -t stretch-backports install meson
#winehq-devel is installed to pull in dependencies to run Wine
run apt-get install -y --install-recommends winehq-devel
#remove system Wine installation to ensure no accidental leakage
run apt-get remove -y winehq-devel
#configure posix mingw-w64 alternative for DXVK
run update-alternatives --set x86_64-w64-mingw32-gcc `which x86_64-w64-mingw32-gcc-posix`
run update-alternatives --set x86_64-w64-mingw32-g++ `which x86_64-w64-mingw32-g++-posix`
run update-alternatives --set i686-w64-mingw32-gcc `which i686-w64-mingw32-gcc-posix`
run update-alternatives --set i686-w64-mingw32-g++ `which i686-w64-mingw32-g++-posix`

run apt-get install -y libsdl2-dev
run apt-get install -y libsdl2-dev:i386

run apt-get install -y libfreetype6-dev:i386
run apt-get install -y libfontconfig1-dev

run apt-get install -y wget
run ln -s /usr/lib/x86_64-linux-gnu/libSDL2-2.0.so.0 /usr/lib/x86_64-linux-gnu/libSDL2.so
run apt install libudev-dev
run apt-get install mlocate


run apt-get build-dep -y wine
#run apt-get build-dep -y dxvk

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
run git clone https://github.com/ValveSoftware/dxvk
env WINEPREFIX="/home/kewluser/wineout2"
# FIXME: this command should generate a wine prefix, no?  maybe it is doing it right in my home folder is the problem.
run /home/kewluser/wineout/usr/local/bin/winecfg
workdir /home/kewluser/dxvk
#run bash setup_dxvk.sh install
#run git checkout proton_3.16 
run git checkout master
# FIXME: move up or remove
run apt-get install -y xvfb
#run Xvfb :99 &
#env DISPLAY=:99
run git clone https://github.com/KhronosGroup/glslang
run apt-get install -y cmake
run mkdir glslang/mwobuild
workdir /home/kewluser/dxvk/glslang/mwobuild
env DESTDIR=""
run cmake -DCMAKE_BUILD_TYPE=Release ..
run make -j4 install

workdir /home/kewluser/dxvk
run bash package-release.sh master ./out --no-package 
env PATH="$PATH:/home/kewluser/wineout/usr/local/bin"
workdir /home/kewluser/dxvk/out/dxvk-master/x64
# FIXME: this actually makes a bum link (based on docker contents)
# we will do it manually
#run bash setup_dxvk.sh -y
run cp ./*.dll /home/kewluser/wineout2/drive_c/windows/system32
