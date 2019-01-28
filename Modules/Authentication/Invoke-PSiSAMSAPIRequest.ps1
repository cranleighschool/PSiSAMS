function Invoke-PSiSAMSAPIRequest
{
    <#
    .SYNOPSIS
    Invokes a generic request to the iSAMS REST API.

    .DESCRIPTION
    This is an internal function, called by other function which should supply
    the request method, resource/endpoint, query and body information.

    .PARAMETER Resource
    The iSAMS resource to be requested from the API. For example, pupils, applicants or employees.

    .PARAMETER Method
    The HTTP method for the request. This can be GET, PUT or POST.

    .PARAMETER Query
    Query parameters supplied with the request. For example, page, pageSize or filter

    .PARAMETER Body
    Body parameters supplied with the request, typically used by PUT or POST.

    #>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory,HelpMessage="Which resource are you conecting to? E.g. students, applicants")]
        [string]$Resource,

        [parameter(Mandatory,HelpMessage="Request method is required. E.g. GET, POST, PUT")]
        [ValidateSet("GET","POST","PUT")]
        [string]$Method,

        [parameter()]
        [string]$Query,

        [parameter()]
        [string]$Body
    )

    $BaseURL = "https://isams.cranleigh.ae/api/"
    $URI = $BaseURL + $Resource
    if($Query)
    {
        $URI = $URI + "?" + $Query
    }

    $query_params = @{
        Uri = $URI
        Method = $Method
        Headers = @{
            "Content-Type"='application/json'
            "Authorization"="Bearer $(Get-iSAMSAPIToken)"
        }
        Body = switch($Method){
            GET  {@{}}
            POST {$Body}
            PUT  {$Body}
        }
    }

    try
    {
        $response = Invoke-RestMethod @query_params -ErrorAction Stop
    }
    catch
    {
        Write-Error "$URI ($Method). $($_.Exception.Message)"
        if($Body) {Write-Verbose $Body}
    }

    Write-Output $response
}