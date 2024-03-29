/// Custom defaults for module
/// Each <Default Name="" Value="" /> element defines one parameter, that can be specified
/// during module installation
Class %ZPM.PackageManager.Developer.ModuleSetting.Default Extends %ZPM.PackageManager.Developer.ModuleSetting
{

Property Name As %String(MAXLEN = 255, XMLPROJECTION = "ATTRIBUTE");

Property Value As %String(MAXLEN = 1000, XMLPROJECTION = "ATTRIBUTE");

ClassMethod GetCustomParameters(Output customParams, module As %ZPM.PackageManager.Developer.Module, ByRef pParams) As %Status
{
    Kill customParams
    Set customParams = ""
    Set key = ""
    For {
        Set default = module.Defaults.GetNext(.key)
        Quit:(key="")
        If (default.%ClassName(1)="%ZPM.PackageManager.Developer.ModuleSetting.Default") {
            Set customParams(default.Name) = default.Value
            If ($Data(pParams("zpm",default.Name))) {
                Set customParams(default.Name) = $Get(pParams("zpm",default.Name))
            }
        }
    }
    return $$$OK
}

ClassMethod EvaluateArgs(ByRef args, ByRef customParams) As %Status
{
    Set key = ""
    For {
        Set key = $Order(args(key))
        Quit:(key="")
        Set args(key) = ..EvaluateAttribute(args(key),.customParams)
    }
    return $$$OK
}

ClassMethod EvaluateAttribute(attribute As %String, ByRef customParams) As %String
{
    Set name=""
    For {
        Set name = $Order(customParams(name))
        Quit:(name="")
        Set regex=##class(%Regex.Matcher).%New("\$\{"_name_"\}", attribute)
        Set attribute = regex.ReplaceAll(customParams(name))
    }
    return attribute
}

Storage Default
{
<Data name="DefaultState">
<Subscript>"Default"</Subscript>
<Value name="1">
<Value>Name</Value>
</Value>
<Value name="2">
<Value>Value</Value>
</Value>
</Data>
<State>DefaultState</State>
<Type>%Library.CacheSerialState</Type>
}

}
