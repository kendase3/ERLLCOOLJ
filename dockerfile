# <3 sid
from debian:sid

workdir /app

# get whatever apt packages we need
run apt-get update && apt-get install -y aptitude && aptitude install -y \
  git \
  vim

run useradd -ms /bin/bash kewluser
user kewluser
workdir /home/kewluser
run git clone git://source.winehq.org/git/wine.git
workdir /home/kewluser/wine
run git checkout wine-4.3
