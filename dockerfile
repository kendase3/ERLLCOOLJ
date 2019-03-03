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
  flex \
  vim

# could be anywhere, but work in /home/someuser for similarity to normal system
workdir /home/kewluser
run git clone https://github.com/ValveSoftware/Proton
#run git checkout 72499898a7da4b3d17c748e308b50d9347f4b370 # ~3.16.7
# maybe this will resolve my FAudio/SDL issues
workdir /home/kewluser/Proton
run git checkout proton-3.16-6
run git submodule update --init
workdir /home/kewluser/Proton/wine
add mwo.patch .
run git apply mwo.patch
workdir /home/kewluser/Proton

# now we 'just' have to do a proton build.  the problem is, proton was made
# to be built with vagrant, which is a bit much to do inside of a docker container and does not seem very easily shareable with a pre-built patch like this.
# thankfully their instructions say it should be easy to dink with in this
# form.

# this section adapted from Proton/Vagrantfile

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

# start the build
run mkdir mwobuild
workdir /home/kewluser/Proton/mwobuild
# note what version of proton we built with
# technically we took an additional commit from the 3.16 branch
run bash ../configure.sh --no-steam-runtime --build-name ERLLCOOLJ3.16.7
#run make obj-wine64/Makefile obj-wine32/Makefile
run apt-get install mlocate
run updatedb
run apt-get install -y bison
run apt-get build-dep -y wine
run apt-get install -y libfreetype6-dev
run make obj-wine64/Makefile
# run apt-get build-dep -y -a i386 wine
run apt-get install -y libfreetype6-dev:i386
run apt-get install -y libfontconfig1-dev
# there is an issue linking in the 32-bit freetype for some reason
run ln -s /usr/lib/i386-linux-gnu/libfreetype.so.6 /usr/lib/i386-linux-gnu/libfreetype.so
#run apt-get install -y libxml2-dev:i386
#run apt-get install -y libxslt-dev:i386
#run apt-get install -y libgnutls-dev:i386
#run apt-get install -y libjpeg-dev:i386
#run make obj-wine32/Makefile
run apt-get install -y wget
run make dist 
