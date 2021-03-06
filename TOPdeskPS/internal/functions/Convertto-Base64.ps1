﻿
function Convertto-Base64 {
    <#
	.SYNOPSIS
		Converts an object to base64

	.DESCRIPTION
		A detailed description of the Convertto-Base64 function.

	.PARAMETER InputObject
		A description of the InputObject parameter.

	.EXAMPLE
		PS C:\> Convertto-Base64 -InputObject 'string'
		Converts the string to Base64

#>

    [CmdletBinding(HelpUri = 'https://andrewpla.github.io/TOPdeskPS/commands/Convertto-Base64')]
    [OutputType([System.String])]
    param
    (
        $InputObject
    )


    process {
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($InputObject)
        [System.Convert]::ToBase64String($bytes)
    }
}
