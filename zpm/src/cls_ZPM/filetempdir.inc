ROUTINE %ZPM.filetempdir [Type=INC]
#;  %ZPM.filetempdir.inc   ; by rcc for Caché
#define FileTempDir ##class(%SYS.System).TempDirectory()_"/"_##class(%PopulateUtils).StringMin(8,8)
