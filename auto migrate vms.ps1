# This script to seperate similar VMs
# If you have too many VMs on one host and you want to seperate them, you can use this one

$fqdn = Read-Host "Enter vCenter FQDN"
$user = Read-Host "Enter username with domain"
$pass = Read-Host "Enter password" #-AsSecureString
#$pwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
$control = Connect-VIServer -Server $fqdn -User $user -Password $pass
if($control -eq $null){
    Write-Output("Check your Username & Password")
}
else{
    $cls_host = Get-Cluster
    [System.Collections.ArrayList]$mig_vms = @()
    foreach($cluster in $cls_host){
        $cls = Get-Cluster -Name $cluster.Name | Get-VMHost
        $cluster.Name
        foreach($hst in $cls){
        $hst.Name
            [System.Collections.ArrayList]$compare_part = @()
            # Find VMs that they include "abc" 
            $a = Get-VMHost -Name $hst.Name | Get-VM | Where-Object{$_.Name -match "abc"}
            # Split before "-abc" and after "-abc" and then save
            foreach($vm in $a){
                $name = $vm.Name
                $split_name = $name -split "-abc"
                $b = $split_name[0]
                $compare_part += $b
            }
            # Compare VM name in the saved list and then saved to the list same ones
            #$c = 0 
            [System.Collections.ArrayList]$tmp = @()
            $temp = $compare_part | Sort-Object | Get-Unique
            if($temp.Count -gt "1"){
                for($i=0; $i -le ($temp.Count)-1; $i++){
                    $tmp += $temp[$i]
                }
            }
            else {
                $tmp += $temp
            }

    
        if($tmp.Count -gt 1){
            for($k=0; $k -le ($tmp.Count)-1; $k++){
                # Concanatenate saved VM name with "-abc" and then check concanatenated names on host, then save same ones to "sim_vms"
                $query_name = $tmp[$k] + "-abc"
                $sim_vms = Get-VMHost -Name $hst.Name | Get-VM | Where-Object{$_.Name -match $query_name}
                if($sim_vms.Count -gt "2"){
                    $mig_vms += $sim_vms 
                    [System.Collections.ArrayList]$tmp_host = @()
                    # İçinde tarattığımız isimli VM bulunmayan hostlar "tmp_host" listesine kaydedilir
                    $l = 0
                    for($l=0; $l -le ($cls.Count)-1; $l++){
                        $temp_host = Get-VMHost -Name $cls[$l] | Get-VM | Where-Object{$_.Name -match $query_name}
                        if($temp_host.Count -eq "0" -and (Get-VMHost -Name $cls[$l]).ConnectionState  -eq "Connected"){
                            $tmp_host += $cls[$l]
                        }            
                    }
                    # Migrate same name VMs to the another host which is not include this name of VM but if there is no left host which isn't include the VM name, migrate the VM randomly
                    $t = 0     
                    for($t=0; $t -le ($sim_vms.Count)-2; $t++){
                        $random_host = $tmp_host[0]
                        if($random_host.Count -eq "0"){
                            $random_host = $cls | Get-Random
                        }
                        Get-Vm -Name $sim_vms[$t] | Move-VM -Destination $random_host
                        [System.Collections.ArrayList]$new_tmp_host = @()
                        foreach($th in $tmp_host){
                            if($th -ne $random_host){
                                $new_tmp_host += $th
                            }
                        }
                        $tmp_host = $new_tmp_host
                    }
                }
            }
        }

        Remove-Variable c -ErrorAction Ignore
        Remove-Variable sim_random -ErrorAction Ignore
        Remove-Variable sim_vms -ErrorAction Ignore
        Remove-Variable tmp -ErrorAction Ignore
        Remove-Variable query_name -ErrorAction Ignore
        Remove-Variable tmp1 -ErrorAction Ignore
        Remove-Variable tmp2 -ErrorAction Ignore
        Remove-Variable i -ErrorAction Ignore
        Remove-Variable j -ErrorAction Ignore
        Remove-Variable split_name -ErrorAction Ignore
        Remove-Variable compare_part -ErrorAction Ignore
        Remove-Variable k -ErrorAction Ignore
        Remove-Variable t -ErrorAction Ignore
        Remove-Variable l -ErrorAction Ignore
        Remove-Variable temp -ErrorAction Ignore
        #clear all
        }
    }


# After all, send mail to the mail address to indicate which VMs were migrated
# Write your own SMTP Server, mail address and subject. Also body message for else situation
    if($mig_vms -ne "0"){
        $body = $mig_vms.Name | Out-String

        Send-MailMessage -From 'migrated@xxx.com' -SmtpServer 'SMTP SERVER' -To 'MAIL ADDRESS' -Subject 'SUBJECT' -Body $body -Encoding utf8
    }
    else{
        $body = "BODY MESSAGE"
        Send-MailMessage -From 'migrated@xxx.com' -SmtpServer 'SMTP SERVER' -To 'MAIL ADDRESS' -Subject 'SUBJECT' -Body $body -Encoding utf8

    }

}
