## This script discovers Child Objects which are going to be managed by the Resource Pools that manage their Root Objects.
## Author: Merijn Overgaauw (GripMatix)

param($sourceId, $managedEntityId)
$params = "SourceId: $sourceId, ManagedEntityId: $managedEntityId"

# Constants
$debug = $true
$objectsToManagePath = "c:\SCOM\ChildObjects.csv"

# Constants used for event logging
$SCRIPT_NAME			= 'Discovery.ChildObjects.ps1'
$EVENT_LEVEL_ERROR 		= 1
$EVENT_LEVEL_WARNING 	= 2
$EVENT_LEVEL_INFO 		= 4

$SCRIPT_STARTED			= 1111
$PROPERTYBAG_CREATED	= 1112
$ERROR_GENERATED        = 1113
$INFO_GENERATED         = 1114
$SCRIPT_ENDED			= 1115

#==================================================================================
# Sub:		LogDebugEvent
# Purpose:	Logs an informational event to the Operations Manager event log
#			only if Debug argument is true
#==================================================================================
function Log-DebugEvent
	{
		param($eventNo, $eventLevel, $message)

		$message = "`n" + $message
		if ($debug)
		{
			$api.LogScriptEvent($SCRIPT_NAME,$eventNo,$eventLevel,$message)
		}
	}

$api = New-Object -comObject 'MOM.ScriptAPI'
$discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId)

$message = "$SCRIPT_NAME script started.`nParameters:`n$params"
Log-DebugEvent $SCRIPT_STARTED $EVENT_LEVEL_INFO $message

$childObjects = Import-Csv "$objectsToManagePath" -Delimiter ","

foreach ($childObject in $childObjects)
	{
	$rootObjectName = $childObject.RootObjectName
	$rootObjectDeviceKey = $childObject.RootObjectDeviceKey
	$childObjectName = $childObject.ChildObjectName
	$childObjectTarget = $childObject.ChildObjectTarget
	$childObjectMeta = $childObject.ChildObjectDescription

	$Instance = $discoveryData.CreateClassInstance("$MPElement[Name='GripMatix.HA.Remote.Monitoring.RootObject']$")
	$Instance.AddProperty("$MPElement[Name='SNL!System.NetworkManagement.Node']/DeviceKey$", "$rootObjectDeviceKey")
	$Instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", "$rootObjectName")
	$discoveryData.AddInstance($Instance)

	$Instance = $discoveryData.CreateClassInstance("$MPElement[Name='GripMatix.HA.Remote.Monitoring.ChildObject']$")
	$Instance.AddProperty("$MPElement[Name='SNL!System.NetworkManagement.Node']/DeviceKey$", $rootObjectDeviceKey)
	$Instance.AddProperty("$MPElement[Name='GripMatix.HA.Remote.Monitoring.ChildObject']/Name$", $childObjectName)
	$Instance.AddProperty("$MPElement[Name='GripMatix.HA.Remote.Monitoring.ChildObject']/Target$", $childObjectTarget)
	$Instance.AddProperty("$MPElement[Name='GripMatix.HA.Remote.Monitoring.ChildObject']/Meta$", $childObjectMeta)
	$Instance.AddProperty("$MPElement[Name='GripMatix.HA.Remote.Monitoring.ChildObject']/RootObjectName$", $rootObjectName)
	$Instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $childObjectName)
	$discoveryData.AddInstance($Instance)
	}	

$discoveryData

$message = "$SCRIPT_NAME script ended.`nParameters:`n$params"
Log-DebugEvent $SCRIPT_ENDED $EVENT_LEVEL_INFO $message