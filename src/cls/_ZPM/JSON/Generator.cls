Include (%occInclude, %ZPM.cache)

IncludeGenerator (%occInclude, %ZPM.cache)

Class %ZPM.JSON.Generator [ Abstract, System = 2 ]
{

ClassMethod GenerateMapping(class As %String, Output mapping) As %Status [ Internal ]
{
  Kill mapping
  Do ..LeftSequenceClass(class,.classSeq)
  Set jsonignoreinvalidfield=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONIGNOREINVALIDFIELD",$$$cPARAMdefault)
  Set jsondefaultmapping=$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONMAPPING",$$$cPARAMdefault)
  Set jsondefaultnull=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONNULL",$$$cPARAMdefault)
  Set jsondefaultignorenull=''$$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONIGNORENULL",$$$cPARAMdefault)
  Set jsondefaultreference=$zcvt($$$comMemberKeyGet(class,$$$cCLASSparameter,"%JSONREFERENCE",$$$cPARAMdefault),"U")
  If jsondefaultreference="" Set jsondefaultreference="OBJECT"
  If $case(jsondefaultreference,"OBJECT":0,"ID":0,"OID":0,"GUID":0,:1) {
    Quit $$$ERROR($$$JSONInvalidDefaultParameter,"parameter %JSONREFERENCE","class base")
  }
  Set sc=$$$OK
  Set property=""
  For {
    Set property=$$$comMemberNext(class,$$$cCLASSproperty,property)
    If property="" Quit
    Set jsoninclude=$zcvt($$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONINCLUDE"),"L")
    Set includeProperty=$case(jsoninclude,"":"","inout":1,"inputonly":1,"outputonly":1,"none":1,:-1)
    If includeProperty=-1 {
      Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"parameter %JSONINCLUDE",property,"class base")
      Quit
    }
    Do ..GetMemberInfo(class,property,.includeProperty,.type,.membercat)
    If includeProperty {
      If jsoninclude="" Set jsoninclude="inout"
      If membercat["STREAM",membercat["Array" {
        Set sc=$$$ERROR($$$JSONNoStreamArray,property,"class base")
        Quit
      }
      Set literaltype=""
      If membercat["CSTREAM" {
        Set literaltype="string"
      } ElseIf membercat["BSTREAM" {
        Set encoding=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"ENCODING")
        Set literaltype=$case($zcvt(encoding,"L"),"":"base64","base64":"base64","hex":"hex",:"")
        If literaltype="" {
          Set sc=$$$ERROR($$$XMLInvalidEncoding,encoding,property)
          Quit
        }
      } ElseIf membercat["LITERAL" {
        Set literaltype=$$$comMemberKeyGet(type,$$$cCLASSparameter,"JSONTYPE",$$$cPARAMdefault)
        If literaltype="" Set literaltype="string"
        If literaltype="string",$$$comMemberKeyGet(type,$$$cCLASSparameter,"XSDTYPE",$$$cPARAMdefault)'="string" {
          Set literaltype="string/json"
        }      }
      Set defClass=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPorigin)
      Set required=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPrequired)
      Set jsonfieldname=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONFIELDNAME")
      If jsonfieldname="" Set jsonfieldname=property
      Set jsonnull=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONNULL")
      Set jsonnull=$select(jsonnull="":jsondefaultnull,1:''jsonnull)
      If literaltype="string" {
        Set jsonignorenull=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONIGNORENULL")
        Set jsonignorenull=$select(jsonignorenull="":jsondefaultignorenull,1:''jsonignorenull)
      } Else {
        Set jsonignorenull=0      }
      If membercat["OBJ" {
        Set jsonreference=$zcvt($$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONREFERENCE"),"U")
        If jsonreference="" Set jsonreference=jsondefaultreference
        Set jsonreference=$case(jsonreference,
                    "OBJECT":$$$jsonrefobject,
                    "ID":$$$jsonrefid,
                    "OID":$$$jsonrefoid,
                    "GUID":$$$jsonrefguid,
                    :"")
        If jsonreference="" {
          Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"parameter %JSONREFERENCE",property,"class base")
          Quit        }
        Set jsonmapping=$$$comMemberArrayGet(class,$$$cCLASSproperty,property,$$$cPROPparameter,"%JSONMAPPING")
        If jsonmapping="" Set jsonmapping=jsondefaultmapping
      } Else {
        Set jsonreference=""      }
      Set node=$lb(property,$$$QN(property),jsoninclude,jsonfieldname,jsonnull,jsonignorenull,jsonreference,required,literaltype,membercat,type,jsonmapping)
      Set item=$increment(tempmap)
      Set tempmap(
          +classSeq-classSeq(defClass)+1,
          +$$$defMemberKeyGet(defClass,$$$cCLASSproperty,property,$$$cPROPsequencenumber),
          item)=node
    }  }
  If $$$ISOK(sc) {
    Set mapping($c(1),0)=$lb(class,jsonignoreinvalidfield)
    Set mapping($c(1))=0
    Set cls=""
    For {
      Set cls=$order(tempmap(cls))
      If cls="" Quit
      Set prop=""
      For {
        Set prop=$order(tempmap(cls,prop))
        If prop="" Quit
        Set num=""
        For {
          Set num=$order(tempmap(cls,prop,num))
          If num="" Quit
          Set item=mapping($c(1))+1
          Set mapping($c(1))=item
          Set mapping($c(1),item)=tempmap(cls,prop,num)
        }   }    }   }
  Quit sc
}

ClassMethod GetMemberInfo(class As %String, property As %String, ByRef includeProperty As %Boolean, Output type As %String, Output membercat As %String) [ Internal ]
{
  Set collection=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPcollection)
  Set relationship=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPrelationship)
  Set cardinality=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPcardinality)
  If includeProperty = "" {
    If $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPmultidimensional) {
      Set includeProperty = 0
    } ElseIf $$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPprivate)||(property="%Concurrency") {
      Set includeProperty = 0
    } ElseIf relationship,cardinality'="children",cardinality'="many" {
      Set includeProperty = 0
    } Else {
      Set includeProperty = 1
    }  }
  If includeProperty {
    Set type=$$$comMemberKeyGet(class,$$$cCLASSproperty,property,$$$cPROPtype)
    If type="" Set type="%Library.String"
    Set typecat=$$$getClassType(type)
    Set membercat=##class(%Compiler.XML.Generator.Adaptor).TypeToMembercat(type,typecat,.mixed)
    If membercat="" Set includeProperty=0
  }
  If includeProperty {
    If relationship {
      If (cardinality = "many") || (cardinality = "children") {
        Set membercat = "ListCollection"_membercat
      }
    } Else {
      If collection="" {
        If (membercat'="LITERAL") {
          Kill typeSeq
          Do ##class(%Compiler.XML.Generator.Adaptor).SequenceClass(type,.typeSeq)
          If $data(typeSeq("%Library.ArrayOfDataTypes")) {
            Set membercat = "ArrayCollection"
          } ElseIf $data(typeSeq("%Library.ArrayOfObjects")) {
            Set membercat = "ArrayCollection"
          } ElseIf $data(typeSeq("%Library.ListOfDataTypes")) {
            Set membercat = "ListCollection"
          } ElseIf $data(typeSeq("%Library.ListOfObjects")) {
            Set membercat = "ListCollection"
          }
          If membercat["Collection" {
            Set type=$$$comMemberKeyGet(type,$$$cCLASSparameter,"ELEMENTTYPE",$$$cPARAMdefault)
            If membercat'["OBJ",type="" Set type="%Library.String"
            If type="" {
              Set sc=$$$ERROR($$$XMLNeedElementType,property)
              Quit
            }
            Set type=$$$NormalizeClassname(type)
            Set typecat=$$$getClassType(type)
            Set membercat=membercat_##class(%Compiler.XML.Generator.Adaptor).TypeToMembercat(type,typecat,.mixed)
          }
        }
      } Else {
        if collection = $$$cPROPCOLLECTIONLIST {
          Set membercat="ListCollection"_membercat
        } ElseIf collection = $$$cPROPCOLLECTIONARRAY {
          Set membercat="ArrayCollection"_membercat
        } } } }
}

ClassMethod LeftSequenceClass(class As %String, ByRef seqArray)
{
  If '$data(seqArray(class)) Set seqArray(class)=$increment(seqArray)
  Set superList=$$$comClassKeyGet(class,$$$cCLASSsuper)
  Set len=$length(superList,",")
  For i=len:-1:1 {
    Set super=$piece(superList,",",i)
    If super'="" {
      Do ..LeftSequenceClass(super,.seqArray)
    }  }
  Quit
}

ClassMethod GenerateMappingFromXdata(class As %String, ByRef mapping) As %Status [ Internal ]
{
  Set compiledclass=##class(%Dictionary.CompiledClass).%OpenId(class,,.sc)
  If $$$ISERR(sc) Quit sc
  Set count=compiledclass.XDatas.Count()
  For i=1:1:count {
    Set xdata=compiledclass.XDatas.GetAt(i)
    Set configName=xdata.Name
    If configName="" Continue
 #dim reader As %XML.Reader=##class(%XML.Reader).%New()
    Set reader.KeepWhitespace=0
    Set sc=reader.OpenStream(xdata.Data)
    If $$$ISERR(sc) Quit
 #dim document As %XML.Document=reader.Document
 #dim node As %XML.Node=document.GetDocumentElement()
    If node="" Continue
    If node.LocalName'="Mapping" Continue
    If node.Namespace'="http://www.intersystems.com/jsonmapping" {
      Set sc=$$$ERROR($$$JSONUnexpectedNamespace,node.QName,$$$mappingNameDisplay(configName))
      Quit   }
    Do reader.CorrelateRoot("%ZPM.JSON.Mapping")
    If 'reader.Next(.obj,.sc) Quit
    If reader.Next(.dummy) {
      Set sc=$$$ERROR($$$JSONExtraMapping,$$$mappingNameDisplay(configName))
      Quit    }
    Set sc=..GenerateMappingFromClass(class,configName,obj,.mapping)
    If $$$ISERR(sc) Quit  }
  Quit sc
}

ClassMethod GenerateMappingFromClass(class As %String, name As %String, obj As %ZPM.JSON.Mapping, ByRef mapping) As %Status [ Internal ]
{
  kill mapping(name)
  Set jsonignoreinvalidfield=obj.IgnoreInvalidField
  Set jsondefaultmapping=obj.Mapping
  Set jsondefaultnull=''obj.Null
  Set jsondefaultignorenull=''obj.IgnoreNull
  Set jsondefaultreference=$zcvt(obj.Reference,"U")
  If jsondefaultreference="" Set jsondefaultreference="OBJECT"
  If $case(jsondefaultreference,"OBJECT":0,"ID":0,"OID":0,"GUID":0,:1) {
    Quit $$$ERROR($$$JSONInvalidDefaultParameter,"attribute reference",$$$mappingNameDisplay(name))
  }
  Set mapping(name,0)=$lb(class,jsonignoreinvalidfield)
#dim property As %ZPM.JSON.MappingProperty
  Set sc=$$$OK
  For i=1:1:obj.propertyList.Count() {
    Set property=obj.propertyList.GetAt(i)
    If property="" {
      Set sc=$$$ERROR($$$JSONNoPropertyName,$$$mappingNameDisplay(name))
      Quit    }
   Set propertyName=property.Name
    If '$$$comMemberDefined(class,$$$cCLASSproperty,propertyName) {
      Set sc=$$$ERROR($$$JSONUnexpectedPropertyName,propertyName,$$$mappingNameDisplay(name))
      Quit }
    Set jsoninclude=$zcvt(property.Include,"L")
    Set includeProperty=$case(jsoninclude,"":"","inout":1,"inputonly":1,"outputonly":1,"none":1,:-1)
    If includeProperty=-1 {
      Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"attribute Include",property,$$$mappingNameDisplay(name))
      Quit    }
    Do ..GetMemberInfo(class,propertyName,.includeProperty,.type,.membercat)
    If includeProperty {
      If jsoninclude="" Set jsoninclude="inout"
      If membercat["STREAM",membercat["Array" {
        Set sc=$$$ERROR($$$JSONNoStreamArray,property,$$$mappingNameDisplay(name))
        Quit      }
      Set literaltype=""
      If membercat["CSTREAM" {
        Set literaltype="string"
      } ElseIf membercat["BSTREAM" {
        Set encoding=$$$comMemberArrayGet(class,$$$cCLASSproperty,propertyName,$$$cPROPparameter,"ENCODING")
        Set literaltype=$case($zcvt(encoding,"L"),"":"base64","base64":"base64","hex":"hex",:"")
        If literaltype="" {
          Set sc=$$$ERROR($$$XMLInvalidEncoding,encoding,property)
          Quit        }
      } ElseIf membercat["LITERAL" {
        Set literaltype=$$$comMemberKeyGet(type,$$$cCLASSparameter,"JSONTYPE",$$$cPARAMdefault)
        If literaltype="" Set literaltype="string"
        If literaltype="string",$$$comMemberKeyGet(type,$$$cCLASSparameter,"XSDTYPE",$$$cPARAMdefault)'="string" {
          Set literaltype="string/json"
        }
      }
      Set required=$$$comMemberKeyGet(class,$$$cCLASSproperty,propertyName,$$$cPROPrequired)
      Set jsonfieldname=property.FieldName
      If jsonfieldname="" Set jsonfieldname=propertyName
      Set jsonnull=property.Null
      Set jsonnull=$select(jsonnull="":jsondefaultnull,1:''jsonnull)
      If literaltype="string" {
        Set jsonignorenull=property.IgnoreNull
        Set jsonignorenull=$select(jsonignorenull="":jsondefaultignorenull,1:''jsonignorenull)
      } Else {
        Set jsonignorenull=0      }
      If membercat["OBJ" {
        Set jsonreference=$zcvt(property.Reference,"U")
        If jsonreference="" Set jsonreference=jsondefaultreference
        Set jsonreference=$case(jsonreference,
                    "OBJECT":$$$jsonrefobject,
                    "ID":$$$jsonrefid,
                    "OID":$$$jsonrefoid,
                    "GUID":$$$jsonrefguid,
                    :"")
        If jsonreference="" {
          Set sc=$$$ERROR($$$JSONInvalidPropertyParameter,"attribute Reference",property)
          Quit        }
        Set jsonmapping=property.Mapping
        If jsonmapping="" Set jsonmapping=jsondefaultmapping
      } Else {
        Set jsonreference=""      }
      Set mapping(name,$increment(mapping(name)))=
         $lb(propertyName,$$$QN(propertyName),jsoninclude,jsonfieldname,jsonnull,jsonignorenull,jsonreference,required,literaltype,membercat,type,jsonmapping)
    }
  }
  Quit sc
}

ClassMethod %JSONGenerate(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
  Set %code=0
  If '$$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) Quit $$$OK
  Set abstract=$$$comClassKeyGet(%class,$$$cCLASSabstract)
  Set sc=$$$OK
  Set sc=..GenerateMapping(%class,.mapping)
  If $$$ISERR(sc) Quit sc
  Set sc=..GenerateMappingFromXdata(%class,.mapping)
  If $$$ISERR(sc) Quit sc
  If 'abstract {
    If $$$ISOK(sc) {
      Set sc=..GenerateAllImportInternal(%class,.mapping)
    }
    If $$$ISOK(sc) {
      Set sc=..GenerateAllExportInternal(%class,.mapping,1)
    }
    If $$$ISOK(sc) {
      Set sc=..GenerateAllExportInternal(%class,.mapping,0)
    }  }
  Quit sc
}

ClassMethod JSONImportInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
  Set %code=0
  If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
    Merge %code=$$$tEXTcode("%JSONImportInternal")
  }
  Quit $$$OK
}

ClassMethod JSONExportInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
  Set %code=0
  If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
    Merge %code=$$$tEXTcode("%JSONExportInternal")
  }
  Quit $$$OK
}

ClassMethod JSONExportToStringInternal(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status [ Internal ]
{
  Set %code=0
  If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
    Merge %code=$$$tEXTcode("%JSONExportToStringInternal")
  }
  Quit $$$OK
}

ClassMethod JSONNew(%mode, %class, %property, %method, %parameter, %codemode, %code, %classmodify, %context) As %Status
{
  Set %code=0
  If $$$comMemberKeyGet(%class,$$$cCLASSparameter,"%JSONENABLED",$$$cPARAMdefault) {
    $$$GENERATE("  Quit ##class("_%class_").%New()")
  }
  Quit $$$OK
}

ClassMethod GenerateAllImportInternal(class As %String, ByRef mapping As %String) As %Status [ Internal ]
{
  New %code
  Set %code=0
  Set sc=$$$OK
  
  Try {
    $$$GENERATE("  Set sc=$$$OK")
    Set needTestInvalidField=0
    Set needRequired=0
    Set indent=""
    Set mappingName=$c(1)
    Set count=0
    For {
      Set mappingName=$order(mapping(mappingName))
      If mappingName="" Quit
      $$$GENERATE("  "_$select(count=0:"If",1:"} ElseIf")_" %mappingName="""_mappingName_""" {")
      Set count=count+1
      Set indent="  "
      Set sc=..GenerateImportInternal(class,indent,mappingName,.mapping,.needRequired,.needTestInvalidField)
      If $$$ISERR(sc) Quit
    }
    If $$$ISERR(sc) Quit
    If count>0 $$$GENERATE("  } Else {")
    Set sc=..GenerateImportInternal(class,indent,$c(1),.mapping,.needRequired,.needTestInvalidField)
    If $$$ISERR(sc) Quit
    If count>0 $$$GENERATE("  }")
    If needTestInvalidField {
      $$$GENERATE("  If $get(testInvalidField) {")
      $$$GENERATE("    Set invalid=0,iterator=%JSONObject.%GetIterator()")
      $$$GENERATE("    While iterator.%GetNext(.key,.value) { If $data(proplist(key))=0 Set invalid=1 Quit  }")
      $$$GENERATE("    If invalid Quit $$$ERROR($$$JSONImportBadField,key,$$$mappingNameDisplay(%mappingName))")
      $$$GENERATE("  }")
    }
    $$$GENERATE("%JSONImportExit Quit sc")
    $$$GENERATE("%JSONImportError Quit $$$ERROR($$$JSONImportError,field,$$$mappingNameDisplay(%mappingName))")
    If needRequired $$$GENERATE("%JSONImportRequired Quit $$$ERROR($$$JSONImportRequired,field,$$$mappingNameDisplay(%mappingName))")
    Merge $$$tEXTcode("%JSONImportInternal")=%code
  } Catch ex {
    Set sc=ex.AsStatus()
  }
  Quit sc
}

ClassMethod GenerateImportInternal(class As %String, indent As %String, mappingName As %String, ByRef mapping As %String, ByRef needRequired As %Boolean, ByRef needTestInvalidField As %Boolean) As %Status [ Internal ]
{
  Set sc=$$$OK
  Set ignoreInvalidField=$$$jsonignoreinvalidfield(mapping,mappingName)
  If 'ignoreInvalidField {
    Set needTestInvalidField=1
    $$$GENERATE(indent_"  Set testInvalidField=1")
  }
  For index=1:1:$$$jsonpropertycount(mapping,mappingName) {
    Set propertyMap=$$$jsongetprop(mapping,mappingName,index)
    Set fieldname=$replace($$$jsonfieldname(propertyMap),"""","""""")
    If 'ignoreInvalidField {
      $$$GENERATE(indent_"  Set proplist("""_fieldname_""")=""""")
    }
    If $$$jsoninclude(propertyMap)'["in" Continue
    $$$GENERATE(indent_"  Set field="""_fieldname_""" Set jsontype=$$$JSONGetTypeOf(%JSONObject,field)")
    $$$GENERATE(indent_"  If jsontype'=""unassigned"" {")
    $$$GENERATE(indent_"    If jsontype=""null"" {")
    If $$$jsonrequired(propertyMap) {
      $$$GENERATE(indent_"      Goto %JSONImportRequired")
    } Else {
      $$$GENERATE(indent_"      Set .."_$$$jsonpropertyQN(propertyMap)_"=""""")
    }
    $$$GENERATE(indent_"    } Else {")
    Set membercat=$$$jsonmembercat(propertyMap)
    If membercat["Collection" {
      // Generate code to import collections
      If membercat["List" {
        // Generate code to import lists
        Do ..GenImportList(class,propertyMap,indent_"    ")
      } Else {
        // Generate code to import arrays
        Do ..GenImportArray(class,propertyMap,indent_"    ")
      }
    } Else {
      // Generate code to import this non-collection field
      Do ..GenImportField(class,propertyMap,indent_"    ",0)
    }
    If $$$jsonrequired(propertyMap) {
      $$$GENERATE(indent_"  } Else { Goto %JSONImportRequired }")
      Set needRequired=1
    } Else {
      $$$GENERATE(indent_"  }")
    }
  }
  Quit sc
}

ClassMethod GenImportList(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
  $$$GENERATE(indent_"  If jsontype'=""array"" Goto %JSONImportError")
  $$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
  $$$GENERATE(indent_"  For index=0:1:data.%Size()-1 {")
  $$$GENERATE(indent_"    Set jsontype=$$$JSONGetTypeOf(data,index)")
  $$$GENERATE(indent_"    If jsontype=""null"" {")
  $$$GENERATE(indent_"      Do .."_$$$jsonpropertyQN(propertyMap)_".Insert("""")")
  $$$GENERATE(indent_"    } Else {")
  $$$GENERATE(indent_"      Set value=data.%Get(index)")
  Do ..GenImportField(class,propertyMap,indent_"    ",$$$isCollectionList)
  $$$GENERATE(indent_"  }}")
}

ClassMethod GenImportArray(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
  $$$GENERATE(indent_"  If jsontype'=""object"" Goto %JSONImportError")
  $$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
  $$$GENERATE(indent_"  Set iterator=data.%GetIterator()")
  $$$GENERATE(indent_"  While iterator.%GetNext(.index,.value) {")
  $$$GENERATE(indent_"    Set jsontype=$$$JSONGetTypeOf(data,index)")
  $$$GENERATE(indent_"    If jsontype=""null"" {")
  $$$GENERATE(indent_"      Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt("""",index)")
  $$$GENERATE(indent_"    } Else {")
  Do ..GenImportField(class,propertyMap,indent_"    ",$$$isCollectionArray)
  $$$GENERATE(indent_"  }}")
}

ClassMethod GenImportField(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) As %Boolean [ Internal ]
{
  Set membercat=$$$jsonmembercat(propertyMap)
  If membercat["OBJ" {
    Set reference=$$$jsonreference(propertyMap)
    If reference=$$$jsonrefid {
      Do ..GenImportID(class,propertyMap,indent,isCollectionValue)
    } ElseIf reference=$$$jsonrefoid {
      Do ..GenImportOID(class,propertyMap,indent,isCollectionValue)
    } ElseIf reference=$$$jsonrefguid {
      Do ..GenImportGUID(class,propertyMap,indent,isCollectionValue)
    } Else {
      Do ..GenImportObject(class,propertyMap,indent,isCollectionValue)
    }
  } ElseIf membercat["STREAM" {
    If membercat="BSTREAM" {
      Do ..GenImportBinaryStream(class,propertyMap,indent,isCollectionValue)
    } Else {
      Do ..GenImportCharacterStream(class,propertyMap,indent,isCollectionValue)
    }
  } Else {
    Do ..GenImportLiteral(class,propertyMap,indent,isCollectionValue)
  }
  $$$GENERATE(indent_"}")
}

ClassMethod GenImportID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  $$$GENERATE(indent_"  If jsontype'=""string"",jsontype'=""number"" Goto %JSONImportError")
  If isCollectionValue {
    Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
    $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectIdAt(value,"_indexarg_")")
  } Else {
    $$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObjectId")_"(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_")")
  }
}

ClassMethod GenImportOID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  $$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
  Set var=$select(isCollectionValue:"value",1:"data")
  Set exp="$lb($piece("_var_","","",2,*),$piece("_var_","","",1))"
  If isCollectionValue {
    Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
    $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectAt("_exp_","_indexarg_")")
  } Else {
    $$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
    $$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObject")_"("_exp_")")
  }
}

ClassMethod GenImportGUID(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  $$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
  If isCollectionValue {
    Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
    $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetObjectAt(##class(%Library.GUID).%GUIDFind(value),"_indexarg_")")
  } Else {
    $$$GENERATE(indent_"  Do .."_$$$QN($$$jsonproperty(propertyMap)_"SetObject")_"(##class(%Library.GUID).%GUIDFind(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_"))")
  }
}

ClassMethod GenImportObject(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set mappingName=$$$jsonmapping(propertyMap)
  $$$GENERATE(indent_"  If jsontype=""object"" {")
  $$$GENERATE(indent_"    Set newobj=##class("_$$$jsontype(propertyMap)_").%JSONNew(%JSONObject,$this)")
  $$$GENERATE(indent_"    Set saveJSON=%JSONObject")
  If mappingName'="" {
    $$$GENERATE(indent_"    Set saveMapping=%mappingName,%mappingName="""_mappingName_"""")
  }
  $$$GENERATE(indent_"    Set %JSONObject="_$select(isCollectionValue:"value",1:"%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))))
  $$$GENERATE(indent_"    Set sc=newobj.%JSONImportInternal()")
  $$$GENERATE(indent_"    Set %JSONObject=saveJSON")
  If mappingName'="" {
    $$$GENERATE(indent_"    Set %mappingName=saveMapping")
  }
  $$$GENERATE(indent_"    If $$$ISERR(sc) Goto %JSONImportExit")
  If isCollectionValue=$$$isCollectionList {
    $$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(newobj)")
  } ElseIf isCollectionValue=$$$isCollectionArray {
    $$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(newobj,index)")
  } Else {
    $$$GENERATE(indent_"    Set .."_$$$jsonpropertyQN(propertyMap)_"=newobj")
  }
  $$$GENERATE(indent_"  } ElseIf jsontype=""oref"" {")
  If isCollectionValue=$$$isCollectionList {
    $$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(value)")
  } ElseIf isCollectionValue=$$$isCollectionArray {
    $$$GENERATE(indent_"    Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(value,index)")
  } Else {
    $$$GENERATE(indent_"    Set .."_$$$jsonpropertyQN(propertyMap)_"=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
  }
  $$$GENERATE(indent_"  } Else { Goto %JSONImportError }")
}

ClassMethod GenImportCharacterStream(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set property=$$$jsonproperty(propertyMap)
  $$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
  If isCollectionValue {
    Set indexarg=$select(isCollectionValue=$$$isCollectionList:"index+1",1:"index")
    $$$GENERATE(indent_"  Set stream=..##class("_$$$jsontype(propertyMap)_").%New()")
    $$$GENERATE(indent_"  Set sc=stream.Write(value) If $$$ISERR(sc) Goto %JSONImportExit")
    If isCollectionValue=$$$isCollectionList {
      $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Insert(stream)")
    } Else {
      $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt(stream,index)")
    }
  } Else {
    $$$GENERATE(indent_"  Set stream=.."_$$$jsonpropertyQN(propertyMap)_" Do stream.Rewind()")
    $$$GENERATE(indent_"  Set sc=stream.Write(%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))_") If $$$ISERR(sc) Goto %JSONImportExit")
  }
}

ClassMethod GenImportLiteral(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set property=$$$jsonproperty(propertyMap)
  Set type=$$$jsontype(propertyMap)
  Set literaltype=$$$jsonliteraltype(propertyMap)
  If literaltype="double" {
    $$$GENERATE(indent_"  If jsontype'=""number"",jsontype'=""string"" Goto %JSONImportError")
  } Else {
    $$$GENERATE(indent_"  If jsontype'="""_$piece(literaltype,"/",1)_""" Goto %JSONImportError")
  }
  If isCollectionValue {
    Set var="value"
  } Else {
    Set var="data"
  }
  Set useProperty='isCollectionValue
  If literaltype'="boolean" { 
    Do ##class(%Compiler.XML.Generator.Adaptor).getPropertyParameters(class,property,.parms)
    Set haveJSONToLogical=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"JSONToLogical",.parms,var,.codeJSONToLogical)
    If 'haveJSONToLogical {
      Set haveJSONToLogical=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"XSDToLogical",.parms,var,.codeJSONToLogical)
    }
    Set haveIsValid=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"IsValid",.parms,var,.codeIsValid)
    Set line=""
    If haveJSONToLogical {
      Set line=line_" Set "_var_"="_codeJSONToLogical_" Goto:"_var_"="""" %JSONImportError"
    }
    If haveIsValid {
      Set line=line_" If $$$ISERR("_codeIsValid_") Goto %JSONImportError"
    }
    If line'="" {
      If useProperty {
        Set useProperty=0
        $$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
      }
      $$$GENERATE(indent_" "_line)
    }
    If literaltype="string",'$$$jsonignorenull(propertyMap) {
      If useProperty {
        Set useProperty=0
        $$$GENERATE(indent_"  Set data=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
      }
      $$$GENERATE(indent_"  If "_var_"="""" Set "_var_"=$c(0)")
    }
  }
  If isCollectionValue=$$$isCollectionList {
    $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".Insert("_var_")")
  } ElseIf isCollectionValue=$$$isCollectionArray {
    $$$GENERATE(indent_"  Do .."_$$$jsonpropertyQN(propertyMap)_".SetAt("_var_",index)")
  } Else {
    If useProperty Set var="%JSONObject."_$$$QN($$$jsonfieldname(propertyMap))
    $$$GENERATE(indent_"  Set .."_$$$jsonpropertyQN(propertyMap)_"="_var)
  }
}

ClassMethod GenerateAllExportInternal(class As %String, ByRef mapping As %String, useWrite As %Boolean) As %Status [ Internal ]
{
  New %code,%outputCode,%exitCode,%objectCode
  Set %code=0
  Set sc=$$$OK
  Try {
    If useWrite {
      Set %outputCode="Write "
      Set %exitCode="%JSONExportExit"
      Set %objectCode="%JSONExportInternal"
    } Else {
      Set %outputCode="Set %export=%export_"
      Set %exitCode="%JSONExportExitToString"
      Set %objectCode="%JSONExportToStringInternal"
    }
    $$$GENERATE("  Set sc=$$$OK")
    $$$GENERATE("  "_%outputCode_"""{"" Set sep=""""")
    Set indent=""
    Set mappingName=$c(1)
    Set count=0
    For {
      Set mappingName=$order(mapping(mappingName))
      If mappingName="" Quit
      $$$GENERATE("  "_$select(count=0:"If",1:"} ElseIf")_" %mappingName="""_mappingName_""" {")
      Set count=count+1
      Set indent="  "
      Set sc=..GenerateExportInternal(class,indent,mappingName,.mapping)
      If $$$ISERR(sc) Quit
    }
    If $$$ISERR(sc) Quit
    If count>0 $$$GENERATE("  } Else {")
    Set sc=..GenerateExportInternal(class,indent,$c(1),.mapping)
    If $$$ISERR(sc) Quit
    If count>0 $$$GENERATE("  }")
    $$$GENERATE("  "_%outputCode_"""}""")
    $$$GENERATE(%exitCode_" Quit sc")
    Merge $$$tEXTcode("%JSONExport"_$select(useWrite:"",1:"ToString")_"Internal")=%code
  } Catch ex {
    Set sc=ex.AsStatus()
  }
  Quit sc
}

ClassMethod GenerateExportInternal(class As %String, indent As %String, mappingName As %String, ByRef mapping As %String) As %Status [ Internal ]
{
  Set sc=$$$OK
  For index=1:1:$$$jsonpropertycount(mapping,mappingName) {
    Set propertyMap=$$$jsongetprop(mapping,mappingName,index)
    Set fieldname=$$$jsonfieldname(propertyMap)
    If $$$jsoninclude(propertyMap)'["out" Continue
    Set membercat=$$$jsonmembercat(propertyMap)
    If membercat["Collection" {
      $$$GENERATE("    Set aval=.."_$$$jsonpropertyQN(propertyMap))
      If membercat["List" {
        Do ..GenExportList(class,propertyMap,indent)
      } Else {
        Do ..GenExportArray(class,propertyMap,indent)
      }
    } Else {
      $$$GENERATE(indent_"  Set value=.."_$$$jsonpropertyQN(propertyMap))
      Do ..GenExportField(class,propertyMap,fieldname,indent,0)
    }  }
  Quit sc
}

ClassMethod GenExportList(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
  Set jsonreference=$$$jsonreference(propertyMap) 
  If jsonreference=$$$jsonrefoid {
    Set nextFunction="GetObjectNext"
  } ElseIf jsonreference=$$$jsonrefguid {
    Set nextFunction="GetNext"
  } ElseIf jsonreference=$$$jsonrefid {
    Set nextFunction="GetObjectIdNext"
  } Else {
    Set nextFunction="GetNext"
  }
  $$$GENERATE(indent_"  If aval.Count()>0 {")
  Do ..GenWriteField($$$jsonfieldname(propertyMap),indent_"  ","")
  $$$GENERATE(indent_"    Set sep=""[""")
  $$$GENERATE(indent_"    Set k="""" For {")
  $$$GENERATE(indent_"      Set value=aval."_nextFunction_"(.k) If k="""" Quit")
  Do ..GenExportField(class,propertyMap,"","      ",$$$isCollectionList)
  $$$GENERATE(indent_"    }")
    $$$GENERATE(indent_"    "_%outputCode_"""]""")
    $$$GENERATE(indent_"  }")
}

ClassMethod GenExportArray(class As %String, propertyMap As %List, indent As %String) As %Boolean [ Internal ]
{
  Set jsonreference=$$$jsonreference(propertyMap)
  If jsonreference=$$$jsonrefoid {
    Set nextFunction="GetObjectNext"
  } ElseIf jsonreference=$$$jsonrefguid {
    Set nextFunction="GetNext"
  } ElseIf jsonreference=$$$jsonrefid {
    Set nextFunction="GetObjectIdNext"
  } Else {
    Set nextFunction="GetNext"
  }
  $$$GENERATE(indent_"  If aval.Count()>0 {")
  Do ..GenWriteField($$$jsonfieldname(propertyMap),indent_"  ","")
  $$$GENERATE(indent_"    Set sep=""{""")
  $$$GENERATE(indent_"    Set aval=.."_$$$jsonpropertyQN(propertyMap)_",k=""""")
  $$$GENERATE(indent_"    For {")
  $$$GENERATE(indent_"      Set value=aval."_nextFunction_"(.k) If k="""" Quit")
  Do ..GenExportField(class,propertyMap,$c(1)_"k",indent_"    ",$$$isCollectionArray)
  $$$GENERATE(indent_"    }")
    $$$GENERATE(indent_"    "_%outputCode_"""}""")
    $$$GENERATE(indent_"  }")
}

ClassMethod GenExportField(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) As %Integer [ Internal ]
{
  Set needClosingBrace=1
  Set membercat=$$$jsonmembercat(propertyMap)
  If membercat["OBJ" {
    Set serialTest=$select(membercat["SERIAL":"&&'value.%IsNull()",1:"")
    $$$GENERATE(indent_"  If value'="""""_serialTest_" {")
    Set indent=indent_"  "
    Set reference=$$$jsonreference(propertyMap)
    If reference=$$$jsonrefid {
      Do ..GenExportID(class,propertyMap,fieldName,indent,isCollectionValue)
    } ElseIf reference=$$$jsonrefoid {
      Do ..GenExportOID(class,propertyMap,fieldName,indent,isCollectionValue)
    } ElseIf reference=$$$jsonrefguid {
      Do ..GenExportGUID(class,propertyMap,fieldName,indent,isCollectionValue)
    } Else {
      Do ..GenExportObject(class,propertyMap,fieldName,indent,isCollectionValue)
    }
  } ElseIf membercat["STREAM" {
    If $$$jsonliteraltype(propertyMap)="string",$$$jsonignorenull(propertyMap) {
      Set needClosingBrace=0
    } Else {
      $$$GENERATE(indent_"  If (value'="""")&&'value.IsNull() {")
      Set indent=indent_"  "
    }
    If membercat="BSTREAM" {
      Do ..GenExportBinaryStream(class,propertyMap,fieldName,indent,isCollectionValue)
    } Else {
      Do ..GenExportCharacterStream(class,propertyMap,fieldName,indent,isCollectionValue)
    }

  } Else {
    If $$$jsonliteraltype(propertyMap)="string",$$$jsonignorenull(propertyMap) {
      Set needClosingBrace=0
    } Else {
      $$$GENERATE(indent_"  If value'="""" {")
      Set indent=indent_"  "
    }
    Do ..GenExportLiteral(class,propertyMap,fieldName,indent,isCollectionValue)
  }
    If needClosingBrace {
    If isCollectionValue || ($$$jsonnull(propertyMap) && '$$$jsonignorenull(propertyMap)) {
      $$$GENERATE(indent_"} Else {")
      Do ..GenWriteField(fieldName,indent,"""null""")
        $$$GENERATE(indent_"}")
        $$$GENERATE(indent_"Set $extract(sep,1)="",""")
    } Else {
        $$$GENERATE(indent_"  Set $extract(sep,1)="",""")
        $$$GENERATE(indent_"}")
    }
  } Else {
      $$$GENERATE(indent_"  Set $extract(sep,1)="",""")
  }
}

ClassMethod GenExportID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  If isCollectionValue {
    Do ..GenWriteField(fieldName,indent,"""""""""_$zcvt(value,""O"",""JSON"")_""""""""")
  } Else {
    Do ..GenWriteField(fieldName,indent,"""""""""_$zcvt(value.%Id(),""O"",""JSON"")_""""""""")
  }
}

ClassMethod GenExportOID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
 If isCollectionValue {
    Do ..GenWriteField(fieldName,indent,"""""""""_$select($listget(value,2)="""":$listget(aval.GetAt(k).%Oid(),2),1:$listget(value,2))_"",""_$listget(value)_""""""""")
  } Else {
    Do ..GenWriteField(fieldName,indent,"""""""""_$listget(value.%Oid(),2)_"",""_$listget(value.%Oid())_""""""""")
  }
}

ClassMethod GenExportGUID(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Do ..GenWriteField(fieldName,indent,"""""""""_value.%GUID(value.%Oid())_""""""""")
}

ClassMethod GenExportObject(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set mappingName=$$$jsonmapping(propertyMap)
  If mappingName'="" {
    $$$GENERATE(indent_"  Set saveMapping=%mappingName,%mappingName="""_mappingName_"""")
  }
  Do ..GenWriteField(fieldName,indent,"")
  $$$GENERATE(indent_"  Set sc=value."_%objectCode_"() If $$$ISERR(sc) Goto "_%exitCode)
  If mappingName'="" {
    $$$GENERATE(indent_"  Set %mappingName=saveMapping")
  }
}

ClassMethod GenExportCharacterStream(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Do ..GenWriteField(fieldName,indent,"")
  $$$GENERATE(indent_"  "_%outputCode_""""""""" Do value.Rewind() If value.Size>0 { While 'value.AtEnd { "_%outputCode_"$zcvt(value.Read(,.sc),""O"",""JSON"") If $$$ISERR(sc) Goto "_%exitCode_" }} "_%outputCode_"""""""""")
}

ClassMethod GenExportLiteral(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set property=$$$jsonproperty(propertyMap)
  Set type=$$$jsontype(propertyMap)
  Do ##class(%Compiler.XML.Generator.Adaptor).getPropertyParameters(class,property,.parms)
  Set haveLogicalToJSON=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"LogicalToJSON",.parms,"value",.codeLogicalToJSON)
  If 'haveLogicalToJSON {
    Set haveLogicalToJSON=##class(%Compiler.XML.Generator.Adaptor).getSingleLine(class,property,type,"LogicalToXSD",.parms,"value",.codeLogicalToJSON)
  }
  If 'haveLogicalToJSON Set codeLogicalToJSON="value"
  Set literaltype=$$$jsonliteraltype(propertyMap)
  If $piece(literaltype,"/",1)="string" {
    If literaltype="string" {
      Set codeLogicalToJSON="$select("_$select($$$jsonignorenull(propertyMap):"(value="""""""")||",1:"")_"(value=$c(0)):"""",1:$zcvt("_codeLogicalToJSON_",""O"",""JSON""))"
    }
    Set codeLogicalToJSON="""""""""_"_codeLogicalToJSON_"_"""""""""
  } ElseIf literaltype="boolean" {
    Set codeLogicalToJSON="$select(value:""true"",1:""false"")"
  }
  Do ..GenWriteField(fieldName,indent,codeLogicalToJSON)
}

ClassMethod GenWriteField(fieldName As %String, indent As %String, valueText As %String)
{
  If fieldName'="" {
    If $extract(fieldName,1)=$c(1) {
      Set field="""_"_$replace($zcvt($extract(fieldName,2,*),"O","JSON"),"""","""""")_"_"""
    } Else {
      set field=$replace($zcvt(fieldName,"O","JSON"),"""","""""")
    }
    If valueText'="" {
      $$$GENERATE(indent_"  "_%outputCode_"sep_"_""""""""_field_""""""_$select($extract(valueText,1)="""":":"_$extract(valueText,2,*),1:":""_"_valueText))
    } Else {
      $$$GENERATE(indent_"  "_%outputCode_"sep_"_""""""""_field_""""":""")
    }
  } Else {
    $$$GENERATE(indent_"  "_%outputCode_"sep"_$select(valueText="":"",1:"_")_valueText)
  }
}

/// Generate code for getting the field value from a binary stream and storing in variable named data.
ClassMethod GenImportBinaryStream(class As %String, propertyMap As %List, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Set property=$$$jsonproperty(propertyMap)
  
  // If present, then must be the expected JSON type
  $$$GENERATE(indent_"  If jsontype'=""string"" Goto %JSONImportError")
  // Get the field value
  // Code to use property stream
  $$$GENERATE(indent_"  Set stream=.."_$$$jsonpropertyQN(propertyMap)_" Do stream.Rewind()")
  $$$GENERATE(indent_"  Set tBase64=%JSONObject."_$$$QN($$$jsonfieldname(propertyMap)))
  $$$GENERATE(indent_"  Set tBase64=$Translate(tBase64, ""=""_$Char(10,13))")
  $$$GENERATE(indent_"  Set tLen=$Length(tBase64)")
  $$$GENERATE(indent_"  For i=1:1:tLen\30020+1 {")
  $$$GENERATE(indent_"    Set sc=stream.Write($system.Encryption.Base64Decode($Extract(tBase64, i-1*30020+1, i*30020))) If $$$ISERR(sc) Goto %JSONImportExit")
  $$$GENERATE(indent_"  }")
}

/// Generate code for exporting a binary stream as JSON.
ClassMethod GenExportBinaryStream(class As %String, propertyMap As %List, fieldName As %String, indent As %String, isCollectionValue As %Integer) [ Internal ]
{
  Do ..GenWriteField(fieldName,indent,"")
  $$$GENERATE(indent_"  "_%outputCode_"""""""""")
  $$$GENERATE(indent_" Do value.Rewind()")
  $$$GENERATE(indent_" If value.Size>0 { While 'value.AtEnd {")
  $$$GENERATE(indent_" "_%outputCode_"$system.Encryption.Base64Encode(value.Read(22515,.sc),1)")
  $$$GENERATE(indent_" If $$$ISERR(sc) Goto "_%exitCode_" }} "_%outputCode_"""""""""")
}

}
