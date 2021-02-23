Class %ZPM.cache.MappingProperty Extends (%RegisteredObject, %XML.Adaptor) [ System = 2 ]
{

Parameter NAMESPACE = "http://www.intersystems.com/jsonmapping";

Parameter XMLFORMAT = "literal";

Parameter XMLIGNOREINVALIDATTRIBUTE = 0;

Property Name As %String(XMLPROJECTION = "attribute") [ Required ];

Property FieldName As %String(XMLPROJECTION = "attribute");

Property Include As %String(XMLPROJECTION = "attribute");

Property Null As %Boolean(XMLPROJECTION = "attribute");

Property IgnoreNull As %Boolean(XMLPROJECTION = "attribute");

Property Mapping As %String(XMLPROJECTION = "attribute");

Property Reference As %String(XMLPROJECTION = "attribute");

}
