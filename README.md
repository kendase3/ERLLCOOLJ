# ERLLCOOLJ

## Purpose
A custom wine builder to play Mechwarrior Online

## Use
### Install Docker
On Debian/Ubuntu:
`sudo apt install docker.io`

On Fedora:
`sudo dnf install docker`

### Build Custom Wine:
`bash build`

### Extract Custom Wine to ./wineprefix
`bash copy`

### Play MWO via WINE with custom build:
`bash playmwo`

### Problems?
Feel free to open an issue on this github!  Thanks for trying it.

### Using Proton Flow
https://github.com/ValveSoftware/Proton
`git submodule update -init`
`cd wine && git apply mwo.patch` (from https://github.com/kendase3/ERLLCOOLJ/blob/master/mwo.patch )
`apt install virtualbox vagrant`
`make vagrant`
`make proton`
`make install`
then choose proton-localbuild in your steam dropdown for mwo :thumbsup:

what could be simpler
