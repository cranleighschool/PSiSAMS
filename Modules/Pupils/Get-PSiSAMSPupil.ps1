function Get-PSiSAMSPupil
{
    [CmdletBinding()]
    param
    (
        [parameter(ParameterSetName="ID",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$SchoolID,

        [int]$Page=1,

        [ValidateRange (1,1000)]
        [int]$PageSize=100,
        
        [string]$Filter=""
    )

    BEGIN
    {
        $QueryParams = @{
            Resource = "students"
            Method   = "GET"
        }
    }

    PROCESS
    {
        if($SchoolID)
        {
            foreach($ID in $SchoolID)
            {
                $QueryParams["Resource"] = "students/$ID"
                try
                {
                    $pupil = Invoke-PSiSAMSAPIRequest @QueryParams -ErrorAction Stop
                }
                catch
                {
                    Write-Warning "Something went wrong. $($_.Exception.Message)"
                }
                Write-Output $pupil
            }
        }
        else
        {
            # Todo: add Page/Pagesize/Filter here:
            $QueryParams["Query"] = $null

            try
            {
                $response = Invoke-PSiSAMSAPIRequest @QueryParams -ErrorAction Stop
            }
            catch
            {
                Write-Warning "API request failed. $($_.Exception.Message)"
            }

            # Multiple pupils:
            if($response.students)
            {
                Write-Output $response.students
            }
            # Single pupil:
            else
            {
                Write-Output $response
            }
        }
    }
    END{}
}
