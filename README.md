It is work in progress  
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


