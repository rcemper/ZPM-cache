Class %ZPM.cache.Mapping Extends (%RegisteredObject, %XML.Adaptor) [ System = 2 ]
{

Parameter NAMESPACE = "http://www.intersystems.com/jsonmapping";

Parameter XMLFORMAT = "literal";

Parameter XMLIGNOREINVALIDATTRIBUTE = 0;

Property IgnoreInvalidField As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

Property Null As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

Property IgnoreNull As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

Property Mapping As %String(XMLPROJECTION = "attribute");

Property Reference As %String(XMLPROJECTION = "attribute") [ InitialExpression = "OBJECT" ];

Property propertyList As list Of %ZPM.cache.MappingProperty(XMLNAME = "Property", XMLPROJECTION = "element");

}
