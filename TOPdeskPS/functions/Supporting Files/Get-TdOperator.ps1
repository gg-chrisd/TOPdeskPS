﻿function Get-TdOperator {
    <#
.SYNOPSIS
    returns list of operators
.DESCRIPTION
    returns list of operators
.PARAMETER Name
    human readable name to filter for operator by. Uses the dynamcName field
.PARAMETER ResultSize
	The amount of operators to be returned. Requests greater than 100 require multiple api calls
.PARAMETER FirstName
    Retrieve only operators with first name starting with this.
    .PARAMETER LastName
        Retrieve only operators with last name starting with this.
    .PARAMETER Archived
        Whether to return archived operators
    .PARAMETER TOPdeskLoginName
        Retrieve only operators with TOPdesk login name starting with this.
    .PARAMETER Email
        Retrieve only operators with email starting with this.
	.PARAMETER Start
		This is the offset at which you want to start listing incidents.

.EXAMPLE
    PS C:\> Get-TdOperator
    returns list of operators
.EXAMPLE
    PS C:\> Get-TdOperator -Name 'John Support'
    returns operator with name John Support (uses the dynamicName field)
#>
    [CmdletBinding(HelpUri = 'https://andrewpla.github.io/TOPdeskPS/commands/Get-TdOperator')]

    param
    (
        [Parameter(Position = 0)]
        [string]
        $TOPdeskLoginName,

        [ValidateRange(1, 100000)]
        [int]
        $ResultSize = 100,

        [int]
        $Start = 0,

        [string]
        $Email,

        [switch]$Archived,

        [string]$LastName,

        [string]$FirstName

    )
    process {
        Write-PsfMessage "ParameterSetName: $($PsCmdlet.ParameterSetName)" -level internalcomment
        Write-PSfMessage "PSBoundParameters: $($PSBoundParameters | Out-String)" -level internalcomment

        $uri = (Get-TdUrl) + "/tas/api/operators/?"
        switch ($PSBoundParameters.Keys) {
            firstname {
                $uri = "$uri&firstname=$FirstName"
            }
            lastname {
                $uri = "$uri&lastname=$LastName"
            }
            Archived {
                $uri = "$uri&archived=$($archived.tostring().tolower())"
            }
            TOPdeskLoginName {
                $uri = "$uri&topdesk_login_name=$TOPdeskLoginName"
            }
            email {
                $uri = "$uri&email=$Email"
            }
        }

        if ($ResultSize -gt 100) {
            $pageSize = 100
        }
        else {
            $pageSize = $ResultSize
        }

        $uri = $uri.replace('?&', '?')
        $count = 0
        do {
            $operators = @()

            $remaining = $ResultSize - $count

            if ($remaining -le 100) {
                $pageSize = $remaining
                $status = 'finished'
            }

            $loopingUri = "$uri&start=$Start&page_size=$pageSize"
            $Params = @{
                'uri' = $loopingUri
            }

            $operators = Invoke-TdMethod @Params
            foreach ($op in $operators) {
                if ($op.id) { $op | Select-PSFObject -Typename 'TOPdeskPS.Operator' -KeepInputObject }
                else { $status = 'finished' }
            }


            if (($operators.count) -le $remaining) {
                Write-PSFMessage 'No operators remaining.'
                $status = 'finished'
            }

            $count += $operators.count
            $start += $PageSize

        }
        until ($status -like 'finished')

    }
}

