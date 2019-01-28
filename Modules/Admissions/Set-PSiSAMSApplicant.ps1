function Set-PSiSAMSApplicant
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Medium")]
    param
    (
        [parameter(Mandatory,
                   HelpMessage="The iSAMS txtSchoolID is required",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$SchoolID,

        [string]$AdmissionStatus,
        [string]$BoardingStatus,
        [int]$CurrentSchoolID,
        [datetime]$DateOfBirth,
        [int]$EnrolmentAcademicHouseID,
        [int]$EnrolmentBoardingHouseID,
        [string]$EnrolmentSchoolForm,
        [string]$EnrolmentSchoolTerm,
        [int]$EnrolmentSchoolYear,
        [int]$EnrolmentSchoolYearGroup,
        [string]$Forename,
        [string]$Gender,
        [string]$Initials,
        [string[]]$Languages,
        [string]$MiddleNames,
        [string[]]$Nationalities,
        [string]$PreferredName,
        [datetime]$RegisteredDate,
        [string]$ResidentCountry,
        [string]$SchoolCode,
        [string]$Surname,
        [string]$Title,
        [string]$UniquePupilNumber
    )

    BEGIN{}
    PROCESS
    {
        # Retrieve applicant details from iSAMS. If nothing is retrieved, issue a warning and exit.
        try
        {
            $pupil = Get-iSAMSApplicant -SchoolID $SchoolID -Verbose:$false -ErrorAction Stop
        }
        catch
        {
            Write-Warning ("Applicant $SchoolID not found in iSAMS. Hint: they may be a current pupil.")
            Return

        }
        $resource = "admissions/applicants/$SchoolID"
        $method   = "PUT"

        # Update fields from parameter values:
        $target = "$SchoolID ($($pupil.forename) $($pupil.surname))"
        $delta = @()
        foreach ($p in $PSBoundParameters.GetEnumerator())
        {
            $key   = $p.key
            $new_value = $p.value
            $current_value = $pupil.($key)
            $excluded_keys = @("SchoolID","Verbose","WhatIf","Debug","ErrorAction","ErrorVariable","WarningAction","WarningVariable")

            if($key -notin $excluded_keys)
            {
                if($new_value -ne $current_value)
                {
                    Write-Verbose "$($key): $current_value >> $new_value ($target)"
                    $pupil.($key) = $new_value
                    $delta += $key
                }
            }
        }

        # Handle any bugs in the iSAMS API:
        if($pupil.enrolmentSchoolTerm -eq "termofentry")
        {
            Write-Verbose "Fixing enrolmentSchoolTerm='termofentry'"
            $pupil.enrolmentSchoolTerm = ""
        }

        # Remove the schoolid and convert to JSON format:
        $body=($pupil | Select-Object * -ExcludeProperty schoolid | ConvertTo-Json)

        if($delta)
        {
            if ($PSCmdlet.ShouldProcess($target))
            {
                try {
                    $pupil = Invoke-iSAMSAPIRequest -Resource $resource -Method $method -Body $body -ErrorAction Stop
                    Write-Output "Success! Updated [$($delta -join ",")] for $target"
                } catch {
                    Write-Warning "Failed to update applicant data for $target. $($_.Exception.Message)"
                    Return
                }
            }
        }
        else
        {
            Write-Verbose "Nothing to update for $target"
        }
    }
    END{}
}