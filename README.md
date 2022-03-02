# ChangeInGIT
Hack a GIT change observer in Swift.

## Motivation
I need a small CI system on raspberry implemented in principles of 
* KISS (keep it stuped simple), 
* MinD (minimize dependency) and 
* Microservice (never ever software maintenance but new programming)

## Using

_first run_

* build or take the ``git-ci`` executable
* On Windows create a executable file called ``CIdoIt.exe``.
* On Linux start ``git-ci`` executable to let create the ``CIdoIt.exe`` and modified ``CIdoIt.exe`` with ``vi`` or other editor. 

_default run_

* start ``git-ci`` in background

_default stop_

* create a file ``CIstop`` w/o extension in running directory of ``git-ci``

## How does it work?
CIHack.exe check every 60 seconds the hash of repository and at first time or hash is changed the CIdoIt.exe program is called. If a file CIstop are existing in running directory this CI is stopping and delete as last the CIstop file

## Notes:
The extension .exe is important with system who must not be named. In result of that it calls an executable ``CIdoIt.exe``. ``CIdoIt.exe`` can be under systems with executable file attribute a script file. On THE other system who must not be named you need to create a binary executable file.


###### EOF
