It is an interesting exercise.  
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

create archive: 
~~~
USER>zn "%SYS"
%SYS>
set sourcedir="C:\GitHub\ZPM-cache\src\"
set archfile="C:\GitHub\ZPM-cache\arch_zmp_cache.tgz"
set sc=##class(%ZPM.PackageManager.Developer.Archive).Create(sourcedir,archfile,.output)
%SYS>
~~~
make %ZPM.Installer
~~~
%SYS>
set arch=##class(%Stream.FileBinary).%New()
set sc=arch.LinkToFile(archfile)
set str=##class(%Stream.TmpCharacter).%New()
set mk=##class(%ZPM.Installer).Make(arch,.str) zw
set inst=##class(%Stream.FileCharacter).%New()
set sc=inst.FilenameSet("C:\GitHub\ZPM-cache\%Installer_cache.cls")   
set sc=inst.CopyFromAndSave(str) zw sc
~~~

on a vanilla __Caché for Windows (x86-64) 2018.1.4 (Build 505_1U) Thu May 28 2020 10:01:40 EDT__     
and on vanilla __IRIS for Windows (x86-64) 2020.1 (Build 215U) Mon Mar 30 2020 20:14:33 EDT__  
and __IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 2020.1 (Build 215U) Mon Mar 30 2020 20:27:11 EDT__  

Compile of %ZPM.Installer.cls fails due to mismatsh in TEMP directory after copy   
But the actual workaround is far simpler to understand 

See README.md
