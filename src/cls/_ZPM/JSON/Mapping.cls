/// XData block which defines a Adaptor mapping.
Class %ZPM.JSON.Mapping Extends (%RegisteredObject, %XML.Adaptor) [ System = 2 ]
{

Parameter NAMESPACE = "http://www.intersystems.com/jsonmapping";

Parameter XMLFORMAT = "literal";

Parameter XMLIGNOREINVALIDATTRIBUTE = 0;

/// See %JSONIGNOREINVALIDFIELD class parameter in Adaptor
Property IgnoreInvalidField As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONNULL class parameter in Adaptor
Property Null As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONIGNORENULL class parameter in Adaptor
Property IgnoreNull As %Boolean(XMLPROJECTION = "attribute") [ InitialExpression = 0 ];

/// See %JSONMAPPING class parameter in Adaptor
Property Mapping As %String(XMLPROJECTION = "attribute");

/// See %JSONREFERENCE class parameter in Adaptor
Property Reference As %String(XMLPROJECTION = "attribute") [ InitialExpression = "OBJECT" ];

/// The list of property definitions
/// Property propertyList As list Of MappingProperty(XMLNAME = "Property", XMLPROJECTION = "element");
Property propertyList As list Of %ZPM.JSON.MappingProperty(XMLNAME = "Property", XMLPROJECTION = "element");

}
