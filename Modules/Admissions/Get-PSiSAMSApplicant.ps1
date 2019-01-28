function Get-PSiSAMSApplicant
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
        $resource = "admissions/applicants"
        $method   = "GET"

        if($SchoolID)
        {
            foreach($ID in $SchoolID)
            {
                $r="$resource/$ID"
                try
                {
                    $applicant = Invoke-iSAMSAPIRequest -Resource $r -Method $method -ErrorAction Stop
                }
                catch
                {
                    Write-Error "Error retrieving $ID. $($_.Exception.Message)"
                }
                Write-Output $applicant
            }
        }
        else
        {
            $query = ""
            if($PageSize)
            {
                $query += "pagesize=$PageSize"
            }
            if($Page)
            {
                $query += "&page=$Page"
            }
            try
            {
                $response = Invoke-iSAMSAPIRequest -Resource $resource -Method $method -Query $query
            }
            catch
            {
                Write-Warning "API request failed. $($_.Exception.Message)"
            }

            if($response.applicants)
            {
                Write-Output $response.applicants
            }
            else
            {
                Write-Output $response
            }
        }
    }
    END{}
}
