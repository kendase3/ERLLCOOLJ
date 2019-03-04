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
'bash playmwo'

### Problems?
Feel free to open an issue on this github!  Thanks for trying it.

### Temporary extra work
Right now one must open winecfg (with `bash configmwo`) and go to the libraries page and change 'd3d11' and 'dxgi' to native.
