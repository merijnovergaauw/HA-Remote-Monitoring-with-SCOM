## This script monitors something.
## Author: Merijn Overgaauw (GripMatix)

param($monitorTarget)
$params = "MonitorTarget: $monitorTarget"

# Constants
$debug = $true

# Constants used for event logging
$SCRIPT_NAME			= 'Monitor.Check1'
$EVENT_LEVEL_ERROR 		= 1
$EVENT_LEVEL_WARNING 		= 2
$EVENT_LEVEL_INFO 		= 4

$SCRIPT_STARTED		= 3111
$PROPERTYBAG_CREATED	= 3112
$ERROR_GENERATED        = 3113
$INFO_GENERATED         = 3114
$SCRIPT_ENDED		= 3115

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
#==================================================================================

# Start script by setting up API object
$api = New-Object -comObject 'MOM.ScriptAPI'

$message = "$SCRIPT_NAME script started. Parameters:`n$params"
Log-DebugEvent $SCRIPT_STARTED $EVENT_LEVEL_INFO $message

$random = Get-Random -Minimum 1 -Maximum 100

$cpuPct = Invoke-Command -ComputerName $monitorTarget -ScriptBlock {
	Get-Ciminstance Win32_Processor | ? {$_.LoadPercentage -ne $null} | Measure-Object -Property LoadPercentage -Average | % {$_.Average}
	}

	
$bag = $api.CreatePropertyBag()
$bag.AddValue('CpuPct',$cpuPct)

$bag

$message = "CpuPct: $cpuPct"
Log-DebugEvent $PROPERTYBAG_CREATED $EVENT_LEVEL_INFO $message

$message = "$SCRIPT_NAME script ended. Parameters:`n$params"
Log-DebugEvent $SCRIPT_ENDED $EVENT_LEVEL_INFO $message
