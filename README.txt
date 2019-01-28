PSiSAMS

A wrapper module for the iSAMS REST API, currently being used by Cranleigh Abu Dhabi.




Notes
-----

To set up the client secret:

$secret_path = "<Enter path here>"	# e.g. Module root or Program Files
Get-Credential -Credential (Get-Credential) | Export-Clixml $secret_path
	Username: <Client ID from iSAMS> E.g. cranleighae
	Password: <Client secret from iSAMS>