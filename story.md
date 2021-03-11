It is an interesting exercise.  
and it runs similar __for Caché and IRIS !__   

Steps taken so far:  
- added .inc to make $$$FileTempDir available 
- edit all storage definitions %library.... instead of %Storage...
    
- to make ZPM command available run: %SYS>do ##class(%ZPM.PackageManager).Init()  
- to init repository run: zpm: USER>repo -r -n registry -url https://pm.community.intersystems.com/ -user "" -pass ""   
- next, search install, ... as well known. No errors   
- Adjust module.xml for new parts.  
   
__generating %ZPM.Installer__    

create archive: 
~~~
USER>zn "%SYS"
%SYS>
set sourcedir="C:\GitHub\ZPM-cache\zpm"
set archfile="C:\GitHub\ZPM-cache\arch_zmp_cache.tgz"
set sc=##class(%ZPM.PackageManager.Developer.Archive).Create(sourcedir,archfile,.output) zw sc
%SYS>
~~~
make Installer_Cache
~~~
%SYS>
set arch=##class(%Stream.FileBinary).%New()
set sc=arch.LinkToFile(archfile)
set str=##class(%Stream.TmpCharacter).%New()
set mk=##class(%ZPM.Installer).Make(arch,.str) zw mk,sc

set inst=##class(%Stream.FileCharacter).%New()
set sc=inst.FilenameSet("C:\GitHub\ZPM-cache\cacheInstaller.xml")   
set sc=inst.CopyFromAndSave(str) zw sc
~~~



