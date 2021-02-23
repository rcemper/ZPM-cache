It is an intersting exercise.  
and it runs similar __for Caché and IRIS !__   

Steps taken so far:  
- added .inc to make $$$FileTempDir available 
- edit all storage defnitions instead of %Storage...
- patched %ZPM.Installer to use it  
- load & compile %ZPM.Installer > creates a bunch of missing modules  
- load & compile adjusted classes > compiles with no errors   
    
- to make ZPM command available run: %SYS>do ##class(%ZPM.PackageManager).Init()  
- to init repository run: zpm: USER>repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""   
- next, search install, ... as well known. No errors  

generating an install kit is not so obvious from code.  ???   

create archive: s sc=##class(%ZPM.PackageManager.Developer.Archive).Create("C:\InterSystems\Cache184\mgr\rcc\src\","arch_cache.txt",.output)  
output=0   sc=1

make %ZPM.Installer
~~~
%SYS>s arch=##class(%Stream.FileBinary).%New()
%SYS>Set sc=arch.LinkToFile("C:\InterSystems\Cache184\mgr\zpm_cache_arch.tgz")
%SYS>zw
arch=<OBJECT REFERENCE>[525@%Stream.FileBinary]
sc=1
%SYS>s str=##class(%Stream.TmpCharacter).%New()
%SYS>s mk=##class(%ZPM.Installer).Make(arch,.str)
Exporting to XML started on 02/23/2021 12:55:48
Exporting class: %ZPM.Installer
Export finished successfully.
 
%SYS>zw
arch=<OBJECT REFERENCE>[525@%Stream.FileBinary]
mk=1
sc=1
str=<OBJECT REFERENCE>[523@%Stream.TmpCharacter]
%SYS>s inst=##class(%Stream.FileCharacter).%New()
%SYS>s sc=inst.FilenameSet("C:\GitHub\rcc\%Installer_cache.cls") zw sc
sc=1
%SYS>s sc=inst.CopyFromAndSave(str) zw
arch=<OBJECT REFERENCE>[525@%Stream.FileBinary]
inst=<OBJECT REFERENCE>[24@%Stream.FileCharacter]
mk=1
sc=1
str=<OBJECT REFERENCE>[523@%Stream.TmpCharacter]
%SYS>
~~~

on a vanilla __Caché for Windows (x86-64) 2018.1.4 (Build 505_1U) Thu May 28 2020 10:01:40 EDT__     
and on vanilla __IRIS for Windows (x86-64) 2020.1 (Build 215U) Mon Mar 30 2020 20:14:33 EDT__  

There is a mismatch between Installer.cls and Module.xls   
So it fails at import of .INC files actual workaround is simple   
~~~
USER>zn "%SYS"
 
%SYS>do $system.OBJ.ImportDir("C:\GitHub\rcc\src\",,"ck",,1)
    Compilation finished successfully in 4.098s.
     Load finished successfully.
 SYS>do ##class(%ZPM.PackageManager).Init()
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
%SYS>zpm
zpm: %SYS>repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""
zpm: %SYS>search -r
(Local Cache) Namespace-local module registry.:
 
registry https://pm.community.intersystems.com/:
analyzethis                           1.1.4
appmsw-telestat                       1.0.2 Repo: https://github.com/SergeyMi37/appmsw-telestat/
appmsw-util                           1.0.1 Repo: https://github.com/SergeyMi37/appmsw-util/
- - - -
~~~
