#Creator: Mario Sambol
#Info: Add Percentage more mailbox space on Exchnage On-premise



$IncreaseByPercentage="30"  # Percentage more
$Mailbox=""             #User AD samaccountname
$default=Get-Mailbox $Mailbox | select -ExpandProperty UseDatabaseQuotaDefaults

#exchange unlimited bug

if($default -eq "True"){

Set-Mailbox $Mailbox -UseDatabaseQuotaDefaults $false -IssueWarningQuota "600MB" -ProhibitSendQuota "700MB" -ProhibitSendReceiveQuota "800MB"
Start-Sleep -Seconds 15

}

$quotas=Get-Mailbox $Mailbox | select IssueWarningQuota, ProhibitSendReceiveQuota , ProhibitSendQuota


    Function Convert-QuotaStringToKB() {

        Param([string]$CurrentQuota)

        [string]$CurrentQuota = ($CurrentQuota.Split("("))[1]
        [string]$CurrentQuota = ($CurrentQuota.Split(" bytes)"))[0]
        $CurrentQuota = $CurrentQuota.Replace(",","")
        [int]$CurrentQuotaInKB = "{0:F0}" -f ($CurrentQuota/1024)

        return $CurrentQuotaInKB
    }

#Convert to String

[string]$strIssueWarningQuota = $quotas.IssueWarningQuota.ToString()
[string]$strProhibitSendQuota = $quotas.ProhibitSendQuota.ToString()
[string]$strProhibitSendReceiveQuota = $quotas.ProhibitSendReceiveQuota.ToString()


#Convert current 

$CurrentIssueWarningQuotaInKB = Convert-QuotaStringToKB $strIssueWarningQuota
$CurrentProhibitSendQuotaInKB = Convert-QuotaStringToKB $strProhibitSendQuota
$CurrentProhibitSendReceiveQuotaInKB = Convert-QuotaStringToKB $strProhibitSendReceiveQuota

#Calculate Diffrence
      
$NewIssueWarningQuotaInKB = $CurrentIssueWarningQuotaInKB + ($CurrentIssueWarningQuotaInKB * $IncreaseByPercentage)/100
$NewProhibitSendQuotaInKB = $CurrentProhibitSendQuotaInKB + ($CurrentProhibitSendQuotaInKB * $IncreaseByPercentage)/100
$NewProhibitSendReceiveQuotaInKB = $CurrentProhibitSendReceiveQuotaInKB + ($CurrentProhibitSendReceiveQuotaInKB * $IncreaseByPercentage)/100

#round decimals

$NewProhibitSendQuotaInKB=[math]::Round($NewProhibitSendQuotaInKB)
$NewProhibitSendReceiveQuotaInKB=[math]::Round($NewProhibitSendReceiveQuotaInKB)
$NewIssueWarningQuotaInKB=[math]::Round($NewIssueWarningQuotaInKB)

#set new qouta

Set-Mailbox $Mailbox -IssueWarningQuota "$($NewIssueWarningQuotaInKB)KB" -ProhibitSendQuota "$($NewProhibitSendQuotaInKB)KB" -ProhibitSendReceiveQuota "$($NewProhibitSendReceiveQuotaInKB)KB" -UseDatabaseQuotaDefaults $false 
