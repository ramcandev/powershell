#
#Creator: Ramazan Can
#Last Modified: 06/11/14
#
#		- Quick & Dirty detection of VMs heartbeat state
#		- can run from any machine which has failovercluster powershell commandlet installed
# 		- check only for VMs with state running (bug with saved state VMs)
#V1.0	- better output view

cls 
""
$clu=Read-Host "Cluster name which should be checked "
$Clusternodes=(Get-Cluster $clu | Get-Clusternode).Name | Sort-Object
$ClusternodeCount=$Clusternodes.Count
[array]$NoHBVMs=@{} | Out-Null
""
Write-Host "scan heartbeat status for any VM running in cluster $clu" -foregroundcolor green
Write-Host "found"$ClusternodeCount" nodes in cluster $clu" -foregroundcolor green
" "
foreach ($node in $clusternodes) {
$AllVMs=get-vm -ComputerName $node | Sort-Object
$AllVMsCount=$AllVMs.Count
" "
Write-Host "scanning node $node...." -foregroundcolor green
Write-Host "found"$AllVMsCount" VMs at node $node" -foregroundcolor green
foreach ($VM in $AllVMs) {
$VMN=$VM.Name
$VMStat=(get-vm -computer $node "$VMN").State
if ($VMStat -match "Running") {
$HBStatus=(Get-VMIntegrationService -computername $node -VMName $VMN Heartbeat).PrimaryStatusDescription
if ($HBStatus -match "No Contact")
{Write-Host ""$VM.Name"has HB status - No Contact ! detected on host -> $node" -foregroundcolor yellow
$NoHBVMs+=$VM.Name}
}}}
" "
if ($NoHBVMs -ne $null) {
Write-Host "Following VMs need to be checked :" -foregroundcolor green
$NoHBVMs} else
{Write-Host "Great - No VMs detected in cluster $clu which has failed heartbeat" -foregroundcolor green}
" "
