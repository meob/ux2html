UX2HTML Readme File

ux2html e' uno script semplice e flessibile per raccogliere la configurazione di sistemi Unix
ux2html restituisce in output la documentazione del sistema Unix in formato HTML
ux2html e' in grado di raccogliere i dati di configurazione da tutti gli Unix e varianti:
 Linux/GNU, SunOS, AIX, HP-UX, Cygwin/Win, Darwin, System V, ..
Lo script e' facilmente configurabile ed estendibile con Plug-in

Installazione:
# mkdir /usr/local/amm
# cd /usr/local/amm
# wget http://sourceforge.net/projects/ux2html/files/ux2html.zip/download
# unzip ux2html.zip

Utilizzo:
# cd /usr/local/amm
# sh ux2html.sh > MY_HOSTNAME.htm 2> /dev/null

Da crontab: 
50  23  *  *  1  cd /usr/local/amm ; sh ux2html.sh > `hostname`.`date +\%Y\%m\%d`.htm 2> /dev/null

Note:

L'esecuzione dello script richiede i privilegi di root

Alcuni Plug-in fanno esplicito riferimento alla directory /usr/local/amm
quindi e' consigliata la creazione di tale directory cosa effettuabile senza problemi su tutti gli Unix/Linux

Per ragioni di sicurezza e' importante che la directory di installazione (eg. /usr/local/amm)
sia scrivibile solo da root.

La personalizzazione dell'esecuzione dello script si effettua impostando le opportune variabili
in una serie di file (in ordine di precedenza)
      ux2c-`hostname`.sh
      ux2c.sh
      ux2html.sh (non raccomandato)

Vi sono una serie di Plug-in gia' disponibili:
      Oracle, MySQL, PostgreSQL, Informix, Sap, OAS, ...

Possono essere facilmente creati nuovi Plug-in creando un file dal nome: ux2p-XXX-PlugInName.sh 
I plug-in vengono disabilitati rinominandoli: ux2d-XXX-PlugInName.sh 


Installazione:
Creare una directory locale al sistema da analizzare (eg. mkdir /usr/local/amm)
Raccogliere il software da WEB e porlo nella directory appena creata

Eseguire lo script (sh ux2html.sh > hostname.htm)

Possono essere ora personalizzate le variabili di configurazione,
possono essere abilitati/disabilitati i plug-in ed inserito il
lancio periodico da crontab


Licenza:
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
