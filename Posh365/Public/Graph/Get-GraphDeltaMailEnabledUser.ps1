function Get-GraphDeltaMailEnabledUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string] $Tenant,

        [Parameter()]
        [switch] $Delta
    )
    begin {
        $SelectString = 'DisplayName, mail, mobilePhone, City, State'
    }
    process {
        $Token = Connect-Graph -Tenant $Tenant
        $Headers = @{
            "Authorization" = "Bearer $Token"
        }
        $RestSplat = @{
            Uri     = 'https://graph.microsoft.com/v1.0/users/delta?$select={0}' -f $SelectString
            Headers = $Headers
            Method  = 'Get'
        }
        do {
            if ($Delta) {
                $Headers = @{
                    "Authorization" = "Bearer $Token"
                }
                $RestSplat = @{
                    Uri     = $DN
                    Headers = $Headers
                    Method  = 'Get'
                }
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false
            }
            else {
                $Response = Invoke-RestMethod @RestSplat -Verbose:$false
                if ($Response.'@odata.nextLink') {
                    $Next = $Response.'@odata.nextLink'
                    $Headers = @{
                        "Authorization" = "Bearer $Token"
                    }
                    $RestSplat = @{
                        Uri     = $Next
                        Headers = $Headers
                        Method  = 'Get'
                    }
                }
                elseif ($Response.'@odata.deltaLink') {
                    $DeltaNext = $Response.'@odata.deltaLink'
                    $Headers = @{
                        "Authorization" = "Bearer $Token"
                    }
                    $RestSplat = @{
                        Uri     = $DeltaNext
                        Headers = $Headers
                        Method  = 'Get'
                    }
                    $Script:DN = $DeltaNext
                    $Next = $null
                }
                else {
                    $Next = $null
                }
            }
        } until (-not $Next -or $Delta)

    }
    end {
        $Response
    }

}