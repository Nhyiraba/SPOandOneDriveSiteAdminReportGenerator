# SPO and OneDrive Site Collection Administrator Report Generator
Generates SharePoint and OneDrive site collection admin report




Written by Daniel, if you have any error, reach out to me on techjollof@gmail.com

Comment prove read by Christabel a SharePoint and OneDrive Expert

<p style="color:red;"> <b>NO WARRANTY IS GUARANTEED.</b> SAMPLE – AS IS, NO WARRANTY This script assumes a connection to SharePoint powershell. </p>


<br>

##### SYNOPSIS
>Generate SPO/OneDrive site collection administrators report
        
 
##### DESCRIPTION
>You need to be a site admin to run the command Get-SPOUser.
This script takes care of that work and removes the user after addding and getting the required information.
The account used to connect-sposervice should serve as admin account.Account must GA or SPO admin
    
##### GlobalSPOAdminAddress
>GlobalSPOAdminAddress is the address that will be granted OneDrive/SPO site collection admin permission, if permission does 
not exist, the command Get-SPOUser will generate error "Access is denied. (Exception from HRESULT: 0x80070005 (E_ACCESSDENIED))" 
This should be the address that runs Connect-SPOService. This is mandatory, if not provided, it will requested.

##### SiteAdminReportType
>You can select type of report you want to generate, the values are OneDriveOnly, SharedChannelSiteOnly,PriviteChannelSiteOnly, 
CommunicationSiteOnly, AllTeamsSiteOnly, ParentTeamSiteOnly, ClassicSiteOnly..if this value is not specified, report will be
generated for all SPO/OneDrive sites
  

<h2 style="color:yellow;">  How to use the this script </h2>

- Donwload the folder and extract the content. 
  >E.g C:\Users\NAME\Download\SPOandOneDriveSiteAdminReportGenerator, this is equal to $Home\Downloads\SPOandOneDriveSiteAdminReportGenerator
- Open PowerShell and cd (change directory) in the to the folder by typing the following

``` powershell
cd C:\Users\PNDT\Downloads\SPOandOneDriveSiteAdminReportGenerator
```

- Connect to SPO powershell and replace <i style="color:orange">TENANTNAME</i> by your sharepoint admin name. Sign in the with the admin accont used <i style="color:orange"> GlobalSPOAdminAddress</i>
  ```powershell
  Connect-SPOService -Url https://TENANTNAME-admin.sharepoint.com
  ```
- Then you run the script by the following

        
#### Example 1
<p style="color:yellow;"> This will generate report for all site in the sharepoint environment including OneDrive </p>

```powershell
   .\GetSPOandOneDriveSiteAdminReport.ps1 -GlobalSPOAdminAddress techjollof@constoso.com
```

#### Example 2
 <p style="color:yellow;"> Getting all OneDrive sites only </p>

 ``` powershell
    .\GetSPOandOneDriveSiteAdminReport.ps1 -GlobalSPOAdminAddress techjollof@constoso.com -SiteAdminReportType OneDriveOnly 
 ```

#### Result location
> The report will be generated in the same folder where the script is location

<b><br>

<h3 style="color:yellow;"> Additional steps if the export file is empty but the powershell shows results  </h3>

>The exported csv is tested if its empty
If the file is empty then Excel module is installed in the current user scope or context and results is exported as direct excel xlsx file.
This section of the code will only run if the exported csv us empty

```powershell

   Install-Module ImportExcel -AllowClobber -Force -Scope CurrentUser
   
```

For more information
- <a href ="https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/get-sposite?view=sharepoint-ps" target = "_blank" > Get-SPOSite </a>
- <a href ="https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/get-spouser?view=sharepoint-ps" target = "_blank" > Get-SPOUser</a>
- <a href = "https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online" target = "_blank"> Get started with SharePoint Online Management Shell </a>


## Share, like and commend if you like it and foud it helpful