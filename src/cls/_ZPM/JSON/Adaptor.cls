Include (%occInclude, %callout, %ZPM.cache)

IncludeGenerator %occInclude

Class %ZPM.JSON.Adaptor [ Abstract, PropertyClass = %ZPM.JSON.PropertyParameters, System = 3 ]
{

Parameter %JSONENABLED = 1;

Parameter %JSONIGNOREINVALIDFIELD As BOOLEAN = 0;

Parameter %JSONNULL As BOOLEAN = 0;

Parameter %JSONIGNORENULL As BOOLEAN = 0;

Parameter %JSONREFERENCE As STRING [ Constraint = "OBJECT,ID,OID,GUID", Flags = ENUM ] = "OBJECT";

Method %JSONImport(input, %mappingName As %String = "") As %Status [ ServerOnly = 1 ]
{
  Try {
    Set sc=$$$OK
    New %JSONObject
    If $isobject(input),input.%IsA("%Library.DynamicAbstractObject") {
      Set %JSONObject=input
    } Else {
      Set %JSONObject=##class(%Library.DynamicAbstractObject).%FromJSON(input)
    }
    Set sc=..%JSONImportInternal()
    
  } Catch ex {
    Set sc=ex.AsStatus()
  }
  Quit sc
}

ClassMethod %JSONNew(dynamicObject As %DynamicObject, containerOref As %RegisteredObject = "") As %RegisteredObject [ CodeMode = generator, GenerateAfter = %JSONGenerate, ServerOnly = 1 ]
{
  Quit ##class(%ZPM.JSON.Generator).JSONNew(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

Method %JSONExport(%mappingName As %String = "") As %Status
{
  Try {
      Set sc=$$$OK
      Set sc=..%JSONExportInternal()
  } Catch ex {
      If ex.%IsA("%Exception.SystemException") {
    Set zerror=ex.AsSystemError()
    If $piece(zerror,">",1)="<METHOD DOES NOT EXIST" {
        Return $$$ERROR($$$JSONRefNotEnabled,$piece(zerror,",",2))
    }
      }
      Set sc=ex.AsStatus()
  }
  Quit sc
}

Method %JSONExportToStream(ByRef export As %Stream.Object, %mappingName As %String = "") As %Status
{
  Set io=$io
  Try {
    If $get(export)="" {
      Set export=##class(%FileCharacterStream).%New()
      Set export.TranslateTable="UTF8"
      Set filestream=1
    } Else {
      Set filestream = ($zobjclass(export)="%Library.FileCharacterStream")
    }
    If filestream {
      Set stream=export
    } Else {
      Set stream=##class(%FileCharacterStream).%New()
      Set stream.TranslateTable="UTF8"
    }
    Set sc=stream.Write("")
    If $$$ISOK(sc) {
      Set file=stream.Filename 
      Use file:(/NOXY)
      Set sc=..%JSONExportInternal()
      Use io
    }
    If $$$ISOK(sc) Set stream.LineTerminator=$select($$$isUNIX:$char(10),1:$char(13,10))
    If 'filestream,$$$ISOK(sc) {  
      Set sc=export.CopyFrom(stream)
    }
  } Catch ex {
    Set sc=ex.AsStatus()
  }
  Quit sc
}

Method %JSONExportToString(ByRef %export As %String, %mappingName As %String = "") As %Status
{
  Try {
    Set sc=$$$OK
    Set %export=""
    Set sc=..%JSONExportToStringInternal()
  } Catch ex {
    If ex.Name="<MAXSTRING>" {
      Set sc=$$$ERROR($$$JSONMaxString,$$$mappingNameDisplay(%mappingName))
    } Else {
      Set sc=ex.AsStatus()
    }
  }
  Quit sc
}

Method %JSONX() [ Abstract, Internal, ServerOnly = 1 ]
{
  Quit
}

/*ClassMethod %JSONGenerate() [ CodeMode = generator, GenerateAfter = %JSONX, Internal, ServerOnly = 1 ]
{
  Quit ##class(%ZPM.JSON.Generator).%JSONGenerate(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

Method %JSONImportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(%ZPM.JSON.Generator).JSONImportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

Method %JSONExportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(%ZPM.JSON.Generator).JSONExportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

Method %JSONExportToStringInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(%ZPM.JSON.Generator).JSONExportToStringInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}
*/
/// %JSONGenerate is an internal method that controls the generation of the other methods in %ZPM.JSON.Adaptor.
/// If %JSONGenerate is overridden, then JSON meta data and the other generator methods
/// of %ZPM.JSON.Adaptor will not be created.<p>
ClassMethod %JSONGenerate() [ CodeMode = generator, GenerateAfter = %JSONX, Internal, ServerOnly = 1 ]
{
  Quit ##class(Generator).%JSONGenerate(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONImportInternal is internal method used by %JSONImport
Method %JSONImportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(Generator).JSONImportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONExportInternal is internal method used by %JSONExport
Method %JSONExportInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(Generator).JSONExportInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

/// %JSONExportToStringInternal is internal method used by %JSONExport
Method %JSONExportToStringInternal() As %Status [ CodeMode = generator, GenerateAfter = %JSONGenerate, Internal, ServerOnly = 1 ]
{
  Quit ##class(Generator).JSONExportToStringInternal(.%mode,.%class,.%property,.%method,.%parameter,.%codemode,.%code,.%classmodify,.%context)
}

}
