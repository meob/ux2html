# ux2html
Unix system statistics collector

ux2html collects Unix Operating System detailed configuration on standard output in HTML format.

ux2html contains Bourne Shell scripts to collect system configuration from all Unix boxes:  
+ Linux/GNU  (many distributions tested: RH, CentOS, OEL, Fedora, Ubuntu, Debian, Alpine, Photon OS, SUSE, ...)
+ SUN/Oracle SunOS/Solaris  
+ IBM AIX  
+ HP HP-UX, Tru64  
+ Apple Darwin/MAC OS X  
+ Microsoft MS-Windows (yes! Windows too... but using Cygwin/Win)  
+ and many other like: System V, NonStop-UX, OSF1, DYNIX, ...  
Most common versions are already managed and all Unix versions are supported: 
if You find a bug for a version specific version we will fix it!  
The architecture is easly extendible with plug-in and custom configuration.


## Installation
> mkdir /usr/local/amm  
> cd /usr/local/amm  
> wget --no-check-certificate https://meoshome.it.eu.org/pub/ux2html.zip      # Alternative to Github  
> unzip ux2html.zip

## Usage
> cd /usr/local/amm  
> sh ux2html.sh > `hostname`.htm 2> /dev/null

## Plug-ins
Plug-in directory contains several custom plug-ins.
To use a specific plug-in move it in /usr/local/amm
> cd /usr/local/amm  
> mv Plug-in/ux2p.020.Sap.sh ..

## Crontab configuration
ux2html statistics can be easly scheduled by crontab:  
50  23  *  *  1  cd /usr/local/amm ; sh ux2html.sh > &lsquo;hostname&lsquo;.&lsquo;date +\%Y\%m\%d&lsquo;.htm 2> /dev/null

## Security notes
ux2html is a System Administrator script. It requires root privileges to extract all system informations.
Source code has been thoroughly tested and can be easly inspected by administrators before using it.
For better security the installation directory (/usr/local/amm) must be writeable from root only.
Generated statistics contain sensitive information like user/group list, software versions, IP adresses, ...


# License
Copyright 1996-2024 mail@meo.bogliolo.name 

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
