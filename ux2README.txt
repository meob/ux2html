UX2HTML Readme File

ux2html is an easy and flexible tool to collect Unix System Configuration
ux2html writes Unix OS and system documentation on std output in HTML format
ux2html can collect information from all Unix systems and uses specific configuration commands for:
 Linux/GNU, SunOS, AIX, HP-UX, Cygwin/Win, Darwin, Tru64, System V, NonStop-UX, OSF1, DYNIX, ..
The architecture is easly extendible with plug-in and custom configuration


Installation:
Create a local directory on the system (mkdir /usr/local/amm; cd /usr/local/amm)
Get the software from the WEB and put it on the local directory
  (eg. wget http://sourceforge.net/projects/ux2html/files/ux2html.zip/download)
Unzip/Untar the scripts (eg. unzip ux2html.zip)


Usage:
cd /usr/local/amm
sh ux2html.sh > `hostname`.htm 2> /dev/null


Advanced configuration:
Customize the script setting variables (vi ux2c-`hostname`.sh)
Enable/Disable and/or Add custom plugin (mv Plug-in/ux2p.020.Sap.sh .)

crontab usage: 
50  23  *  *  1  cd /usr/local/amm ; sh ux2html.sh > `hostname`.`date +\%Y\%m\%d`.htm 2> /dev/null


Notes:
  
Running the script requires root privileges

For security reasons the installation directory (eg. /usr/local/amm)
  should be writeable from root only.

Customization can be performed setting variables in (in order of precedence):
      ux2c-`hostname`.sh
      ux2c.sh
      ux2html.sh (not recommended)

System usage, activities and special configurations can be described in HTML in
 /etc/.sys_descr.htm /etc/.sys_log.htm /etc/.sys_disk.htm
They'll be reported on the final report

There are several available Plug-in:   
Oracle           MySQL      Timezone   OCFS2
OracleDetails    DB2        OAS        Asterisk
PostgreSQL       Sap        Connect    Symmetrix
InformixOnLine   Sendmail   HACMP      GFS2
Virtual          Asterisk   Custom     ...


New Plug-ins can be added creating a file named: ux2p-XXX-PlugInName.sh 
Plug-in are disabled moving them on file: ux2d-XXX-PlugInName.sh 



License:
Copyright 1996-2024 mail@meo.bogliolo.name 

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
