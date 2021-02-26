The ideas is to havea single code base that runs similar __for Caché and IRIS !__   

# Installation

- clone this repository to local disk
- start a vanilla __Caché for Windows (x86-64) 2018.1.4 (Build 505_1U) Thu May 28 2020 10:01:40 EDT__   
- or a vanilla  __IRIS for Windows (x86-64) 2020.1 (Build 215U) Mon Mar 30 2020 20:14:33 EDT__  
- from Terminal run this steps:

and __IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 2020.1 (Build 215U) Mon Mar 30 2020 20:27:11 EDT__  

~~~
USER>zn "%SYS"
~~~ 
%SYS>__do $system.OBJ.ImportDir("C:\GitHub\rcc\src\",,"ck",,1)__  
~~~
      Compilation finished successfully in 4.098s.
     Load finished successfully.
~~~
SYS>__do ##class(%ZPM.PackageManager).Init()__  
~~~
     Initialized local cache.
     Reindexing %ZPM.PackageManager.Server.Module... done.
     Reindexing %ZPM.PackageManager.Server.Application... done.
     Reindexing %ZPM.PackageManager.Client.Filesystem.Cache... done.
Do you want to configure general package manager settings? No => y
     UIFW Build Processes
     PythonPath: Path to python.exe; required for UIFW build processes.
Value:
     PortableGitPath: Root path to Portable Git; required for UIFW build processes.
Value:
Do you want to enable/update the 'ZPM' command? Yes => y
     Compiling routine : %ZLANGC00.mac
     Compiling routine : %ZLANGF00.mac
~~~
%SYS>__zpm__  
zpm: %SYS>__repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""__  
zpm: %SYS>__search -r__    
~~~
(Local Cache) Namespace-local module registry.:
 
registry https://pm.community.intersystems.com/:
analyzethis                           1.1.4
appmsw-telestat                       1.0.2 Repo: https://github.com/SergeyMi37/appmsw-telestat/
appmsw-util                           1.0.1 Repo: https://github.com/SergeyMi37/appmsw-util/
- - - -
~~~
