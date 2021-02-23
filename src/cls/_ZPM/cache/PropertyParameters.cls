Class %ZPM.cache.PropertyParameters [ System = 2 ]
{

Parameter %JSONFIELDNAME As STRING;

Parameter %JSONINCLUDE As STRING [ Constraint = "INOUT,INPUTONLY,OUTPUTONLY,NONE", Flags = ENUM ];

Parameter %JSONNULL As BOOLEAN;

Parameter %JSONIGNORENULL As BOOLEAN;

Parameter %JSONREFERENCE As STRING [ Constraint = "OBJECT,ID,OID,GUID", Flags = ENUM ];

}
