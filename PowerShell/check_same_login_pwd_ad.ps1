# Este script recupera todos os usernames em uma OU do Active Directory e tenta autenticar, 
# usando o proprio login como senha.

# O intuito desse código é identificar usuários que usaram o próprio login como senha.

################ Parâmetros ################

$OU_BASE="DC=CONTOSO,DC=COM"

################### Função ##################
# Extraido de https://gist.github.com/cainejunkazama/6178856

Function Test-ADAuthentication {
    param(
        $username,
        $password)
    
    (New-Object DirectoryServices.DirectoryEntry "",$username,$password).psbase.name -ne $null
}
################### MAIN ################# 
$LOGINS_TO_CHANGE = @()

$AD_USERS = Get-ADUser -Filter * -SearchBase $OU_BASE -Properties "SamAccountName" | Select -expandproperty SamAccountName
$AD_USERS | ForEach-Object {
    Write-Host -NoNewLine "Usuario: $_ "
    $result = Test-ADAuthentication -username $_ -password $_
        
    if ($result -eq $true){ 
        Write-Host "Login e senha IGUAIS" -ForegroundColor Red
        $LOGINS_TO_CHANGE += $_
    }
    else {
        Write-Host "Login e senha DIFERENTES"
    }
}
Write-Host "Resultado:" $LOGINS_TO_CHANGE.Split(" ").Count "usuarios encontrados:"
Write-Host "A lista foi salva no arquivo 'logins_change.txt'"
$LOGINS_TO_CHANGE.Split(" ")
$LOGINS_TO_CHANGE.Split(" ") | Out-File -FilePath .\logins_change.txt
