function Get-TDSchedule
{
    <#
    .SYNOPSIS
    Retrieves all schedules associated with a Telldus Live! account.

    .DESCRIPTION
    This command will list all schedules associated with an Telldus Live!-account

    .EXAMPLE
    Get-TDSchedule

    Fetch all schedules in the Telldus Live! account

    .EXAMPLE
    Get-TDSchedule -ScheduleID 1234567

    Fetch the schedule with id 1234567 from the Telldus Live! account

    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('id')]
        [string] $ScheduleID
    )

    BEGIN {
        if ($TelldusLiveAccessToken -eq $null) {
            throw "You must first connect using the Connect-TelldusLive cmdlet"
        }
    }

    PROCESS {

        if ($ScheduleID) {
            $response = InvokeTelldusAction -URI "scheduler/jobInfo?id=$ScheduleID"
            $jobList = $response
        }
        else {
            $response = InvokeTelldusAction -URI 'scheduler/jobList'
            $jobList = $response.job
        }

        foreach ($job in $jobList) {
            $job | Add-Member -MemberType NoteProperty -Name ScheduleID -Value $job.id

            $job
        }
    }

    END { }
}