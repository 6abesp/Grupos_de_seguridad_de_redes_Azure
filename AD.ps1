
# iniciar sesion
Login-AzAccount
Get-AzSubscription
$subs = read-host "coloca el ID de la subscripción donde desplegaremos"
Set-AzContext -SubscriptionId $subs

#obener datos necesarios para creat el NSG
Get-AzResourceGroup
$rg = read-host "coloca el nombre del grupo de recursos donde desplegaremos"
$name = read-host "coloca el nombre que tendrá el NSG"
$region = read-host "coloca la region en que desplegaremos"
New-AzNetworkSecurityGroup -Name $name -ResourceGroupName $rg  -Location  $region

# Obtener datos del nuevo NSG
$nsg = Get-AzNetworkSecurityGroup -Name $name -ResourceGroupName $rg

#Bloquear el aceso a internet de cualquier puerto de servicio del AD
$nsg | Add-AzNetworkSecurityRuleConfig -Name Internet_IN -Description "Bloquear acceso a internet de puertos de servicio" -Access Deny -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 135,1024-65535,389,636,53,88,445  
$nsg | Add-AzNetworkSecurityRuleConfig -Name Internet_OUT -Description "Bloquear acceso a internet de puertos de servicio" -Access Deny -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix * -SourcePortRange 135,1024-65535,389,636,53,88,445 -DestinationAddressPrefix Internet -DestinationPortRange * 


#Asignador de extremos de RPC, o RPC Endpoint Mapper
$nsg | Add-AzNetworkSecurityRuleConfig -Name RPC_IN -Description "Permitir Inbound RPC Endpoint Mapper" -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 135 
$nsg | Add-AzNetworkSecurityRuleConfig -Name RPC_OUT -Description "Permitir Outbound RPC Endpoint Mapper" -Access Allow -Protocol Tcp -Direction Outbound -Priority 110 -SourceAddressPrefix * -SourcePortRange 135 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 

#  	RPC para LSA, SAM, Netlogon (*), FRS RPC (*)
$nsg | Add-AzNetworkSecurityRuleConfig -Name LSA_SAM_Netlogon_FRS_IN -Description "Permitir Inbound RPC para LSA, SAM, Netlogon (*)" -Access Allow -Protocol Tcp -Direction Inbound -Priority 120 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 
$nsg | Add-AzNetworkSecurityRuleConfig -Name LSA_SAM_Netlogon_FRS_OUT -Description "Permitir Outbound RPC para LSA, SAM, Netlogon (*)" -Access Allow -Protocol Tcp -Direction Outbound -Priority 120 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 

#  	LDAP
$nsg | Add-AzNetworkSecurityRuleConfig -Name LDAP_IN -Description "Permitir Inbound LDAP" -Access Allow -Protocol * -Direction Inbound -Priority 130 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 389 
$nsg | Add-AzNetworkSecurityRuleConfig -Name LDAP_OUT -Description "Permitir Outbound LDAP" -Access Allow -Protocol * -Direction Outbound -Priority 130 -SourceAddressPrefix * -SourcePortRange 389 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 


#  	LDAP SSL, GC y GC SSL
$nsg | Add-AzNetworkSecurityRuleConfig -Name LDAP_SSL-GC_IN -Description "Permitir Inbound LDAP SSL y GC" -Access Allow -Protocol Tcp -Direction Inbound -Priority 140 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 636,3268,3269 
$nsg | Add-AzNetworkSecurityRuleConfig -Name LDAP_SSL-GC_OUT -Description "Permitir Outbound LDAP SSL y GC" -Access Allow -Protocol Tcp -Direction Outbound -Priority 140 -SourceAddressPrefix * -SourcePortRange 636,3268,3269 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 

#  	DNS
$nsg | Add-AzNetworkSecurityRuleConfig -Name DNS_IN -Description "Permitir Inbound DNS" -Access Allow -Protocol * -Direction Inbound -Priority 150 -SourceAddressPrefix * -SourcePortRange 53,1024-65535 -DestinationAddressPrefix * -DestinationPortRange 53 
$nsg | Add-AzNetworkSecurityRuleConfig -Name DNS_OUT -Description "Permitir Outbound DNS" -Access Allow -Protocol * -Direction Outbound -Priority 150 -SourceAddressPrefix * -SourcePortRange 53 -DestinationAddressPrefix * -DestinationPortRange 53,1024-65535 

#  	Kerberos
$nsg | Add-AzNetworkSecurityRuleConfig -Name Kerberos_IN -Description "Permitir Inbound Kerberos" -Access Allow -Protocol * -Direction Inbound -Priority 160 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 88
$nsg | Add-AzNetworkSecurityRuleConfig -Name Kerberos_OUT -Description "Permitir Outbound Kerberos" -Access Allow -Protocol * -Direction Outbound -Priority 160 -SourceAddressPrefix * -SourcePortRange 88 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 

#  	SMB
$nsg | Add-AzNetworkSecurityRuleConfig -Name SMB_IN -Description "Permitir Inbound SMB" -Access Allow -Protocol * -Direction Inbound -Priority 170 -SourceAddressPrefix * -SourcePortRange 1024-65535 -DestinationAddressPrefix * -DestinationPortRange 445
$nsg | Add-AzNetworkSecurityRuleConfig -Name SMB_OUT -Description "Permitir Outbound SMB" -Access Allow -Protocol * -Direction Outbound -Priority 170 -SourceAddressPrefix * -SourcePortRange 445 -DestinationAddressPrefix * -DestinationPortRange 1024-65535 

# Actualizar con lasnuevas reglas
$nsg | Set-AzNetworkSecurityGroup
