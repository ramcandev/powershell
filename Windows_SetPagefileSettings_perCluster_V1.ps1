#
#Creator: ramacan
#Last Modified: 24/07/14
#
#V1		- configure pagefile at all clusternodes connected to VMM 
#		- disable pagefile automatic manage else Win32_PageFileSetting class is not present
#		- set pagefile initial size to 32768MB (can be configured $PFInitialSize)
#		- set pagefile max size to 32768MB (can be configured $PFMaxSize)
#		- check freespace on pagefile drive and if less or equal disqualify 
#V1.1		- change to apply PF only for cluster 

cls 
" "

import-module failoverclusters
import-module virtualmachinemanager
#$VMMServer = Read-Host "VMMServer Name "
#$VMMClusters=(Get-SCVMHostCluster -vmmserver $VMMServer).Name | sort $VMMClusters.Name
$Clustername=Read-Host "Cluster Name "
[int]$PFInitialSize="32768"
[int]$PFMaxSize="32768"
[array]$ClusterNodes=@{} | Out-Null
[int]$ClusterNodesCount=@{} | Out-Null
[array]$PFFailedtoset=@{} | Out-Null

#foreach ($Cluster in $VMMClusters) {
$ClusterNodes = (Get-Cluster $Clustername | Get-ClusterNode).Name | sort $ClusterNodes.Name
#}
[int]$ClusterNodesCount=$ClusterNodes.Count
" "
"Total $ClusterNodesCount Clusternodes found, starting to configure pagefile settings...."
"Pagefile Initial Size: $PFInitialSize MB"
"Pagefile Maximum Size: $PFMaxSize MB"
" "

foreach ($VMASServer in $ClusterNodes)
{ 
$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $VMASServer -Filter "DeviceID='C:'" |
Select-Object Size,FreeSpace

#freespace calculation in MB
$Freespace=[math]::round($disk.FreeSpace / 1024 / 1024)

#freespace check if below than $PFMaxSize
if ($Freespace -le $PFMaxSize) {
Write-Host "not enough space on $VMASServer to set pagefile need to be done manually...." -foregroundcolor yellow
$PFFailedtoset+=$VMASServer
} else {
    # Disables automatically managed page file setting first
    $CurrentCompWMIClass = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $VMASServer -EnableAllPrivileges
    if ($CurrentCompWMIClass.AutomaticManagedPagefile)
    {
        $CurrentCompWMIClass.AutomaticManagedPagefile = $false
        if ($CurrentCompWMIClass.AutomaticManagedPagefile -eq $false)
        {
            $CurrentCompWMIClass.Put() 
        }}
	
    Write-Host "Setting pagefile on server : $VMASServer" -foregroundcolor green
    try 
    {
        $PageFile = Get-WmiObject -class Win32_PageFileSetting -ComputerName $VMASServer -EnableAllPrivileges 
        $PageFile.InitialSize = $PFInitialSize
        $PageFile.MaximumSize = $PFMaxSize
        $PageFile.Put() 
    } 
    #catch 
    #{
    #   Write-Host "Failed to set pagefile on: $VMASServer, server down?" -foregroundcolor red
	#	$PFFailedtoset+=$VMASServer
        #break
    #}
    finally 
    {
        Write-Host "Pagefile set on : $VMASServer" -foregroundcolor green
		" "
    }
}}
" "
Write-Host "PF Setting failed on servers, need to be set manually ...." -foregroundcolor yellow
$PFFailedtoset