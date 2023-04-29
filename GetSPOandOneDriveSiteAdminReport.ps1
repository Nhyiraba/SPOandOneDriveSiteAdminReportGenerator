
# Written by Narh Daniel Tetteh, if you have any error, reach out to me on techjollof@gmail.com
# NO WARRENT GUARANTEED
# SAMPLE – AS IS, NO WARRANTY This script assumes a connection to SharePoint powershell.

<#

<#
    .SYNOPSIS
        Generate SPO/OneDrive site administrators report
    
    .DESCRIPTION
        You need to be a site admin to run the command Get-SPOUser.
        This script takes care of that work and removes the user after addding and getting the required information.
        The account used to connect-sposervice should serve as admin account.Account must GA or SPO admin
    
    .PARAMETER GlobalSPOAdminAddress
        GlobalSPOAdminAddress is the address that will be granted OneDrive/SPO site collection admin permission, if permission does 
        not exist, the command Get-SPOUser will generate error "Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))" 
        This should be the address that runs Connect-SPOService.

    .PARAMETER SiteAdminReportType
        You can select type of report you want to generate, the values are OneDriveOnly, SharedChannelSiteOnly,PriviteChannelSiteOnly, 
        CommunicationSiteOnly, AllTeamsSiteOnly, ParentTeamSiteOnly, ClassicSiteOnly..if this value is not specified, report will be
        generated for all SPO/OneDrive sites

    .EXAMPLE
        Getting all OneDrive sites only
        .\GetSPOandOneDriveSiteAdminReport.ps1 -GlobalSPOAdminAddress techjollof@constoso.com -SiteAdminReportType OneDriveOnly

    .EXAMPLE
        Getting all Sites
        .\GetSPOandOneDriveSiteAdminReport.ps1 -GlobalSPOAdminAddress techjollof@constoso.com
    
#>
 

[CmdletBinding()]
param(
    
    [Parameter(HelpMessage="GlobalSPOAdminAddress to given access to the OneDrive site collection admin, thsi should be the address run Connect-SPOService.")]
    [string]
    $GlobalSPOAdminAddress,
    

    # This will be the type of reports
    [Parameter()]
    [ValidateSet("OneDriveOnly","SharedChannelSiteOnly","PriviteChannelSiteOnly","CommunicationSiteOnly","AllTeamsSiteOnly","ParentTeamSiteOnly","ClassicSiteOnly")]
    $SiteAdminReportType
)
 
#console write
function Write-Result ([string]$TextData, [switch]$isError) {
    if($isError){
        Write-Host $TextData -ForegroundColor Red
    }else{
        Write-Host $TextData -ForegroundColor Yellow
    }
}

#get all sites
$AllSPOSites = Get-SPOSite -IncludePersonalSite:$true -Limit All

#filter target sites according site type
$SPOSiteURL = if ($SiteAdminReportType -eq "OneDriveOnly") {
    $AllSPOSites.Where{$_.Template -eq "SPSPERS#10"}
}elseif ($SiteAdminReportType -eq "SharedChannelSiteOnly") {
    $AllSPOSites.Where{$_.Template -like "TEAMCHANNEL*" -and $_.TeamsChannelType -eq "SharedChannel"}
}elseif ($SiteAdminReportType -eq "PriviteChannelSiteOnly") {
    $AllSPOSites.Where{$_.Template -like "TEAMCHANNEL*" -and $_.TeamsChannelType -eq "PrivateChannel"}
}elseif ($SiteAdminReportType -eq "CommunicationSiteOnly") {
    $AllSPOSites.Where{$_.Template -eq "SITEPAGEPUBLISHING#0"}
}elseif ($SiteAdminReportType -eq "AllTeamsSiteOnly") {
    $AllSPOSites.Where{$_.Template -in "GROUP#0","TEAMCHANNEL#0","TEAMCHANNEL#1"}
}elseif ($SiteAdminReportType -eq "ParentTeamSiteOnly") {
    $AllSPOSites.Where{$_.Template -eq "GROUP#0"}
}elseif ($SiteAdminReportType -eq "ClassicSiteOnly") {
    $AllSPOSites.where{$_.Template -in "STS#0","STS#1","STS#2","STS#3"}
}else {
    $AllSPOSites
}

$SiteOwnerResults = @()

#grant your self access to all sites
$SPOSiteURL | ForEach-Object { 

    $SiteURL = $_
    if($SiteURL.Owner -ne $GlobalSPOAdminAddress){

        #gettings site information
        try {
            $SiteCollectionAdmins = Get-SPOUser -Site $SiteURL.Url  | Where-Object {$_.IsSiteAdmin}
        }
        catch {
            # adding site admin
            Write-Result "`nAdmin $($GlobalSPOAdminAddress) is the not the site owner for $($SiteURL.Url)" -isError
            Write-Result "`tAdding admin to site owners"
            Set-SPOUser -Site $SiteURL.Url -LoginName $GlobalSPOAdminAddress -IsSiteCollectionAdmin:$true > $null
            Write-Result "`tAdmin added successfully" 
            Write-Result "`tGetting all site admin and removing admin from site owners"
            $SiteCollectionAdmins = Get-SPOUser -Site $SiteURL.Url  | Where-Object {$_.IsSiteAdmin -and $_.LoginName -ne $GlobalSPOAdminAddress}
            Set-SPOUser -Site $SiteURL.Url -LoginName $GlobalSPOAdminAddress -IsSiteCollectionAdmin:$false > $null
        }
    }else{
        Write-Result "`nUser: $($GlobalSPOAdminAddress)  is already an ower  $($SiteURL.Url)"
        $SiteCollectionAdmins = Get-SPOUser -Site $SiteURL.Url | Where-Object {$_.IsSiteAdmin}
    }

    #adding and collating collected data
    $SiteOwnerResults += [PSCustomObject]@{
        PrimaryOwner            = $SiteURL.Title
        PrimaryOwnerEmail       = $SiteURL.Owner
        OtherAdminsDisplayName  = $SiteCollectionAdmins.DisplayName -join ','
        OtherAdminsEmail        = $SiteCollectionAdmins.LoginName -join ','
        IsGroup                 = $SiteCollectionAdmins.IsGroup -join ','
        SiteURL                 = $SiteURL.Url
    }

}

#Exporting results of the generation
Write-Result "`n`nExorting the report......... to the same location`n"
if ($SiteAdminReportType) {
    $SiteOwnerResults | Export-Csv ".\SiteCollectionAdministrator_Report_for_$($SiteAdminReportType).csv" -NoTypeInformation
}else{
    $SiteOwnerResults | Export-Csv ".\SiteCollectionAdministrator_Report_for_All.csv" -NoTypeInformation
}