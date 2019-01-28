function Get-PSiSAMSAPIToken
{

    [CmdletBinding()]

    # Bearer token storage, in the user's local appdata folder:
    $psisams_appdata = Join-Path -Path $env:LOCALAPPDATA -ChildPath "PSiSAMS"
    $secret_path = Join-Path -Path $psisams_appdata -ChildPath "client_secret.xml"
    Write-Verbose "Client secret path: $secret_path"
    try
    {
        $isams_credentials = Import-Clixml $secret_path
    }
    catch
    {
        if(-not (Test-Path $psisams_appdata)) {New-Item -ItemType Directory -Path $psisams_appdata -Force}
        Get-Credential (Get-Credential) | Export-Clixml -Path $secret_path
        $isams_credentials = Import-Clixml $secret_path
    }

    # This is where the latest bearer token will be stored, along with timestamp to check expiry:
    $auth_path = Join-Path -Path $psisams_appdata -ChildPath "auth.xml"
    Write-Verbose "XML Path: $auth_path"

    # First, check if we have a bearer token stored locally:
    try
    {
        $auth = Import-Clixml -Path $auth_path -ErrorAction Stop
        $expires_in = [int]($auth.timestamp-(Get-Date)).TotalSeconds+$auth.expires_in
        Write-Verbose "Bearer token retrieved from auth.xml. Expires in $expires_in seconds."
    }
    catch
    {
        Write-Verbose "No valid authentication object was imported. A new bearer token will be requested."
        $expires_in = 0
    }

    # If the bearer token has expired, request a new one:
    if($expires_in -le 0)
    {
        Write-Verbose "Expired. Requesting a new bearer token..."
        $auth_params = @{
            uri="https://isams.cranleigh.ae/Main/sso/idp/connect/token"
            method="POST"
            headers = @{
                "Content-Type"  = "application/x-www-form-urlencoded"
            }
            body = @{
                "client_id"     = $isams_credentials.UserName
                "client_secret" = $isams_credentials.GetNetworkCredential().Password
                "grant_type"    = "client_credentials"
                "scope"         = "api"
            }
        }

        try
        {
            $auth = Invoke-RestMethod @auth_params -ErrorAction Stop
        }
        catch
        {
            Write-Error "Failed to get bearer token. $($_.Exception.Message)"
            Remove-Item $secret_path,$auth_path
            Return
        }
        $expires_in = $auth.expires_in
        $auth.access_token = ConvertTo-SecureString $auth.access_token -AsPlainText -Force
        $auth | Add-Member timestamp (Get-Date)


        Write-Output $auth | Export-Clixml -Path $auth_path
    }

    # Decode the bearer token:
    $token = (New-Object pscredential "user",$auth.access_token).GetNetworkCredential().Password
    Write-Verbose "Auth token: $token. Expires in $expires_in seconds"

    Write-Output $token
}