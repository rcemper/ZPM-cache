The idea is to have a single code base that runs similar __for Caché and IRIS !__     
# Installation 
- clone this repository to local disk
# Docker
- from cloned project directory run __docker-compose up -d --build__  
you get __IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 20201 (Build 215U) Mon Mar 30 2020 20:27:11 EDT__  
- enter session __docker-compose exec iris iris session iris__
# Windows
- start a vanilla __Caché for Windows (x86-64) 2018.1.4 (Build 505_1U) Thu May 28 2020 10:01:40 EDT__   
- or a vanilla  __IRIS for Windows (x86-64) 2020.1 (Build 215U) Mon Mar 30 2020 20:14:33 EDT__  

There is a fast and a detailed variant:    
  
__Fast install:__     
- load and compile Installer.xml from cloned repositora and your done    
    
__Detailed install:__
- from Terminal run this steps:
~~~
USER>zn "%SYS"   

%SYS>set dir="C:\GitHub\ZPM-cache\zpm\" ; your downloaded project directory   

%SYS>do $system.OBJ.ImportDir(dir,,"ck",,1)  ; load & compile ZPM
     Load of directory started on 02/26/2021 19:08:44
     - - -
     Compilation finished successfully in 3.759s.   
     Load finished successfully.  
%SYS>do ##class(%ZPM.PackageManager).Init()  
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
%SYS>
%SYS>zpm  
zpm: %SYS>repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""   
zpm: %SYS>search -r
    (Local Cache) Namespace-local module registry.:
     registry https://pm.community.intersystems.com/:
     analyzethis                           1.1.4
     appmsw-telestat                       1.0.2 Repo: https://github.com/SergeyMi37/appmsw-telestat/
     appmsw-util                           1.0.1 Repo: https://github.com/SergeyMi37/appmsw-util/
- - - -
zpm: %SYS>quit
~~~
