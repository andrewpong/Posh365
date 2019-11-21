function Invoke-GetMailboxMoveLicenseUserSkuWithType {
    [CmdletBinding()]
    param (
        [Parameter()]
        $UserChoice,

        [Parameter()]
        [switch]
        $SharePoint,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $All,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [switch]
        $AllLicensedOnly,

        [Parameter()]
        [switch]
        $SearchString,

        [switch]
        $OnePerLine,

        [switch]
        $IncludeRecipientType

    )
    end {
        $RecipientList = Get-EXORecipient -ResultSize Unlimited
        $TypeHash = Get-RecipientPrimaryToTypeHash -RecipientList $RecipientList
        $PlanList = Get-AzureADSubscribedSku
        $SkuHash = @{ }
        $PlanList | ForEach-Object {
            $SkuHash[($_.ObjectId).substring($_.ObjectId.length - 36, 36)] = $_.SkuPartNumber }
        switch ($true) {
            $SharePoint {
                if ($UserChoice -ne 'Quit' ) {
                    if (-not $OnePerLine) {
                        foreach ($User in $UserChoice) {
                            $SkuList = (Get-AzureADUser -Filter "mail eq '$($User.PrimarySmtpAddress)' or UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID
                            [PSCustomObject]@{
                                DisplayName          = $User.DisplayName
                                RecipientTypeDetails = $TypeHash[$User.PrimarySmtpAddress]
                                PrimarySmtpAddress   = $User.PrimarySmtpAddress
                                UserPrincipalName    = $User.UserPrincipalName
                                Sku                  = @(($SkuList) -ne '' | ForEach-Object { $SkuHash[$_] }) -ne '' -join '|'
                            }
                        }
                    }
                    else {
                        foreach ($User in $UserChoice) {
                            if ($SkuList = (Get-AzureADUser -Filter "mail eq '$($User.PrimarySmtpAddress)' or UserPrincipalName eq '$($User.UserPrincipalName)'").AssignedLicenses.SkuID) {
                                foreach ($Sku in $SkuList) {
                                    [PSCustomObject]@{
                                        DisplayName          = $User.DisplayName
                                        RecipientTypeDetails = $TypeHash[$User.PrimarySmtpAddress]
                                        PrimarySmtpAddress   = $User.PrimarySmtpAddress
                                        UserPrincipalName    = $User.UserPrincipalName
                                        Sku                  = $SkuHash[$Sku]
                                    }
                                }
                            }
                            else {
                                [PSCustomObject]@{
                                    DisplayName          = $User.DisplayName
                                    RecipientTypeDetails = $TypeHash[$User.PrimarySmtpAddress]
                                    PrimarySmtpAddress   = $User.PrimarySmtpAddress
                                    UserPrincipalName    = $User.UserPrincipalName
                                    Sku                  = 'UNLICENSED'
                                }
                            }
                        }
                    }
                }
            }
            $All {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        if ($User.AssignedLicenses.SkuID) {
                            foreach ($Sku in $User.AssignedLicenses.SkuID) {
                                [PSCustomObject]@{
                                    DisplayName          = $User.DisplayName
                                    RecipientTypeDetails = $Type
                                    PrimarySmtpAddress   = $PrimarySmtpAddress
                                    UserPrincipalName    = $User.UserPrincipalName
                                    Sku                  = $SkuHash[$Sku]
                                }
                            }
                        }
                        else {
                            [PSCustomObject]@{
                                DisplayName          = $User.DisplayName
                                RecipientTypeDetails = $Type
                                PrimarySmtpAddress   = $PrimarySmtpAddress
                                UserPrincipalName    = $User.UserPrincipalName
                                Sku                  = 'UNLICENSED'
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        [PSCustomObject]@{
                            DisplayName          = $User.DisplayName
                            RecipientTypeDetails = $Type
                            PrimarySmtpAddress   = $PrimarySmtpAddress
                            UserPrincipalName    = $User.UserPrincipalName
                            Sku                  = @(@($User.AssignedLicenses -ne '') | ForEach-Object { $SkuHash["$($_.SkuID)"] }) -ne '' -join '|'
                        }
                    }
                }
            }
            $AllLicensedOnly {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        foreach ($Sku in $User.AssignedLicenses.SkuID) {
                            [PSCustomObject]@{
                                DisplayName          = $User.DisplayName
                                RecipientTypeDetails = $Type
                                PrimarySmtpAddress   = $PrimarySmtpAddress
                                UserPrincipalName    = $User.UserPrincipalName
                                Sku                  = $SkuHash[$Sku]
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        [PSCustomObject]@{
                            DisplayName          = $User.DisplayName
                            RecipientTypeDetails = $Type
                            PrimarySmtpAddress   = $PrimarySmtpAddress
                            UserPrincipalName    = $User.UserPrincipalName
                            Sku                  = @(@($User.AssignedLicenses -ne '') | ForEach-Object { $SkuHash["$($_.SkuID)"] }) -ne '' -join '|'
                        }
                    }
                }
            }
            $SearchString {
                if ($OnePerLine) {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        if ($User.AssignedLicenses.SkuID) {
                            foreach ($Sku in $User.AssignedLicenses.SkuID) {
                                [PSCustomObject]@{
                                    DisplayName          = $User.DisplayName
                                    RecipientTypeDetails = $Type
                                    PrimarySmtpAddress   = $PrimarySmtpAddress
                                    UserPrincipalName    = $User.UserPrincipalName
                                    Sku                  = $SkuHash[$Sku]
                                }
                            }
                        }
                        else {
                            [PSCustomObject]@{
                                DisplayName          = $User.DisplayName
                                RecipientTypeDetails = $Type
                                PrimarySmtpAddress   = $PrimarySmtpAddress
                                UserPrincipalName    = $User.UserPrincipalName
                                Sku                  = 'UNLICENSED'
                            }
                        }
                    }
                }
                else {
                    foreach ($User in $UserChoice) {
                        if ($PrimarySmtpAddress = [regex]::Matches("$($User.ProxyAddresses)", "(?<=SMTP:)[^ ]*").value) {
                            $Type = $TypeHash[$PrimarySmtpAddress]
                        }
                        else { $Type = 'NoPrimarySmtp' }
                        [PSCustomObject]@{
                            DisplayName          = $User.DisplayName
                            RecipientTypeDetails = $Type
                            PrimarySmtpAddress   = $PrimarySmtpAddress
                            UserPrincipalName    = $User.UserPrincipalName
                            Sku                  = @(@($User.AssignedLicenses -ne '') | ForEach-Object { $SkuHash["$($_.SkuID)"] }) -ne '' -join '|'
                        }
                    }
                }
            }
        }
    }
}
