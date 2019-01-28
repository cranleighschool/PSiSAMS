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

    BEGIN{}

    PROCESS
    {
        $resource = "students"
        $method   = "GET"

        if($SchoolID)
        {
            foreach($ID in $SchoolID)
            {
                $r="$resource/$ID"
                try
                {
                    $applicant = Invoke-PSiSAMSAPIRequest -Resource $r -Method $method -ErrorAction Stop
                }
                catch
                {
                    Write-Warning "Something went wrong. $($_.Exception.Message)"
                }
                Write-Output $applicant
            }
        }
        else
        {
            $query = $null
            try
            {
                $response = Invoke-PSiSAMSAPIRequest -Resource $resource -Method $method -Query $query
            }
            catch
            {
                Write-Warning "API request failed. $($_.Exception.Message)"
            }

            if($response.students)
            {
                Write-Output $response.students
            }
            else
            {
                Write-Output $response
            }
        }
    }
    END{}
}
