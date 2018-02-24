#####################################################################################################################
#                                                     
#  Creator: Ramazan Can 
#  Date Created: 16/02/2018
#  Last Modified:                         
#                          
#   - this script is to add FW rule for VMM ports 5982-5987, the port number can be modified at line28
#
#
#####################################################################################################################

cls
""
""

$vmms=Read-Host "VMMServer "
""
"Getting all VMM Managed Computers..."
$allvmmmanagedcomputers= (Get-SCVMMManagedComputer -VMMServer $vmms).Name | sort
$allcompcount=$allvmmmanagedcomputers.Count
"Done - $allcompcount total SCVMM managed computers found - starting foreach loop..."
""

foreach ($comp in $allvmmmanagedcomputers) {
""
    Write-Host "Adding FW Rule for SCVMM BITS Traffic Allow port 5985-5986-5987 on $comp"
    Invoke-Command -ComputerName $comp -ScriptBlock { 
        New-NetFirewallRule -DisplayName 'VMM Inbound Ports' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('5985', '5986', '5987')

    }
    
}




    
