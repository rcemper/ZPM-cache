Include (%syPrompt, %ZPM.PackageManager.Common)

Class %ZPM.PackageManager.Client.ServerDefinition Extends (%Persistent, %ZEN.DataModel.Adaptor) [ Abstract ]
{

Parameter DOMAIN = "ZPM";

/// Display name for this type of repository, shown in the UI and package manager shell.
Parameter DISPLAYNAME As STRING [ Abstract ];

/// Short/logical name for this type of repository, used in the package manager shell as an alternative to the full class name.
Parameter MONIKER As STRING [ Abstract ];

Index ServerDefinitionKey On Name [ Unique ];

Property Name As %String(MAXLEN = 100) [ Required ];

Property Enabled As %Boolean [ InitialExpression = 1 ];

Property Details As %String(MAXLEN = "") [ SqlComputeCode = {Set {*} = ""}, SqlComputed ];

Property Snapshots As %Boolean [ InitialExpression = 0 ];

Property Prereleases As %Boolean [ InitialExpression = 0 ];

/// Returns a client to interact with this server.
Method GetPackageService() As %ZPM.PackageManager.Core.IPackageService [ Abstract ]
{
}

/// Returns a client to publish modules/applications to this server.
Method GetPublishService() As %ZPM.PackageManager.Core.IPublishService [ Abstract ]
{
}

ClassMethod SortOrder(pID As %String) As %Integer [ SqlProc ]
{
	Set tServer = ..%OpenId(pID)
	Quit tServer.GetSortOrder()
}

/// Outputs information about this server to the current device.
/// Subclasses may override to show additional information, but should typically call ##super() at the beginning.
Method Display()
{
	Write !,..Name
	Write !,$c(9),"Source: ",$c(9),..Details
	Write !,$c(9),"Enabled?",$c(9),$$$YesNo(..Enabled)
	Write !,$c(9),"Available?",$c(9),$$$YesNo(..GetPackageService().IsAvailable())
	Write !,$c(9),"Use for Snapshots?",$c(9),$$$YesNo(..Snapshots)
	Write !,$c(9),"Use for Prereleases?",$c(9),$$$YesNo(..Prereleases)
}

/// Called from package manager shell to create or update an instance of this class.
/// Acceptable values in <var>pModifiers</var> and <var>pData</var> may vary between classes, but
/// some (such as "name", "enabled", "snapshots", and "prereleases") are common to all.
/// For a full list of modifiers, see the Commands XDATA block in <class>%ZPM.PackageManager</class>.
ClassMethod Configure(pInteractive As %Boolean = 1, ByRef pModifiers, ByRef pData) As %Status [ Final ]
{
	Set tSC = $$$OK
	Try {
		Set tName = $Get(pModifiers("name"))
		
		If (pInteractive && (tName = "")) {
			Set tResponse = ##class(%Library.Prompt).GetString("Name: ",.tName)
			If (tResponse '= $$$SuccessResponse) {
				$$$ThrowStatus($$$ERROR($$$GeneralError,"Operation cancelled."))
			}
		}
		
		Set tIsNew = 0
		Set tInstance = $$$NULLOREF
		If ..ServerDefinitionKeyExists(tName) {
			Set tInstance = ..ServerDefinitionKeyOpen(tName,,.tSC)
			$$$ThrowOnError(tSC)
		}
		
		If '$IsObject(tInstance) {
			Set tInstance = ..%New()
			Set tIsNew = 1
			Set tInstance.Name = tName
		}
		
		If $Data(pModifiers("disable")) {
			Set tInstance.Enabled = 0
		} ElseIf (tIsNew || $Data(pModifiers("enable"))) {
			Set tInstance.Enabled = 1
		}
		
		If $Data(pModifiers("snapshots"),tSnapshots) {
			Set tInstance.Snapshots = tSnapshots
		} ElseIf (tIsNew) {
			Set tInstance.Snapshots = 1
		}
		If $Data(pModifiers("prereleases"),tPrereleases) {
			Set tInstance.Prereleases = tPrereleases
		} ElseIf (tIsNew) {
			Set tInstance.Prereleases = 1
		}
		
		$$$ThrowOnError(..OnConfigure(tInstance,pInteractive,.pModifiers,.pData))
		
		$$$ThrowOnError(tInstance.%Save())
	} Catch e {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

/// Subclasses must override. Allows handling of any custom modifiers/data attributes provided from the package manager shell.
ClassMethod OnConfigure(pInstance As %ZPM.PackageManager.Client.ServerDefinition, pInteractive As %Boolean = 1, ByRef pModifiers, ByRef pData) As %Status [ Abstract ]
{
}

/// Subclasses must override. Orders repositories by type and possibly other factors.
Method GetSortOrder() As %Integer [ Abstract, Private ]
{
}

Query Catalog() As %Query(ROWSPEC = "Classname:%String,Moniker:%String,Description:%String") [ SqlProc ]
{
}

ClassMethod CatalogExecute(ByRef qHandle As %Binary) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tRes = ##class(%SQL.Statement).%New()
		Set tSC = tRes.%PrepareClassQuery("%Dictionary.ClassDefinition","SubclassOf")
		$$$ThrowOnError(tSC)
		Set qHandle = tRes.%Execute($classname())
	} Catch e {
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

ClassMethod CatalogFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = CatalogExecute ]
{
	Set AtEnd = 'qHandle.%Next(.tSC)
	If 'AtEnd {
		Set tClass = qHandle.%Get("Name")
		Set Row = $ListBuild(tClass,$parameter(tClass,"MONIKER"),$parameter(tClass,"DISPLAYNAME"))
	}
	Quit tSC
}

ClassMethod CatalogClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = CatalogExecute ]
{
	Quit $$$OK
}

Storage Default
{
<Data name="ServerDefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>Credentials</Value>
</Value>
<Value name="7">
<Value>Enabled</Value>
</Value>
<Value name="8">
<Value>IsLocalCache</Value>
</Value>
<Value name="9">
<Value>Details</Value>
</Value>
<Value name="10">
<Value>Snapshots</Value>
</Value>
<Value name="11">
<Value>Prereleases</Value>
</Value>
</Data>
<DataLocation>^%ZPM.Client.ServerDefD</DataLocation>
<DefaultData>ServerDefinitionDefaultData</DefaultData>
<IdLocation>^%ZPM.Client.ServerDefD</IdLocation>
<IndexLocation>^%ZPM.Client.ServerDefI</IndexLocation>
<StreamLocation>^%ZPM.Client.ServerDefS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

