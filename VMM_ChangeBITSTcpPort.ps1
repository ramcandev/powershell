#####################################################################################################################
#                                                     
#  Creator: Ramazan Can 
#  Date Created: 16/02/2018
#  Last Modified:                         
#                          
#   - this script is to change the registry value for BITSTcpPort, the port number can be modified at line34
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
    Write-Host "Checking key on node $comp"
    Invoke-Command -ComputerName $comp -ScriptBlock { 
            $RegVMMAgent ="HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Agent\Setup"
            $RegVMMServer ="HKLM:\SOFTWARE\Microsoft\Microsoft System Center Virtual Machine Manager Server\Settings"
            $keypresentVMMServer=Get-ItemProperty -Path $RegVMMServer -ea 0
            $keypresentVMMAgent=Get-ItemProperty -Path $RegVMMAgent -ea 0
            [int]$BITSTcpPort="5987"

                if ($keypresentVMMServer) {
                        Write-Host "VMMServer Key found, doing required BITSTcpPort change"
                        Set-ItemProperty -Path $RegVMMServer -Name BITSTcpPort -Value $BITSTcpPort
                        Write-Host "Done - New BITSPort is changed to $BITSTcpPort, please restart manually VMM Server service to take effect" -ForegroundColor Yellow
                        #Restart-Service SCVMMService # VMM Server service
                        #Restart-Service SCVMMAgent # VMM Agent service
                        }

                if ($keypresentVMMAgent) {
                        Write-Host "VMMAgent Key found, doing required BITSTcpPort change"
                        Set-ItemProperty -Path $RegVMMAgent -Name BITSTcpPort -Value $BITSTcpPort
                        Write-Host "Done - New BITSPort is changed to $BITSTcpPort, restarting VMM Agent to take effect" -ForegroundColor Green
                        Restart-Service SCVMMAgent
                        }
    }
    
}




    
