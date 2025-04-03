param (
    [string]$UsersCsvPath = "C:\Scripts\users.csv",
    [string]$AdminsCsvPath = "C:\Scripts\admins.csv",
    [string]$DomainName = "ramzou.local",
    [string]$NetbiosName = "RAMZOU",
    [string]$AdminPassword = "Tech2025$"
)

# Fonction pour vérifier si l'IP est statique
function Check-StaticIP {
    $ipConfig = Get-NetIPAddress | Where-Object { $_.PrefixOrigin -eq 'Manual' }
    if ($ipConfig) {
        Write-Host "✅ L'IP est bien configurée en statique." -ForegroundColor Green
    } else {
        Write-Host "❌ L'IP est en DHCP. Configurez une IP fixe avant d'exécuter ce script !" -ForegroundColor Red
        exit
    }
}

# Vérifier que l'IP est bien statique
Check-StaticIP

# Installer le rôle Active Directory si non présent
if (-not (Get-WindowsFeature AD-Domain-Services).Installed) {
    Write-Host "📦 Installation du rôle Active Directory..." -ForegroundColor Cyan
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
} else {
    Write-Host "✅ Le rôle ADDS est déjà installé." -ForegroundColor Green
}

# Promouvoir le serveur en contrôleur de domaine si ce n'est pas déjà fait
if (-not (Get-ADDomain -ErrorAction SilentlyContinue)) {
    Write-Host "🚀 Promotion du serveur en contrôleur de domaine..." -ForegroundColor Cyan
    Install-ADDSForest ` 
        -DomainName $DomainName `
        -DomainNetbiosName $NetbiosName `
        -ForestMode "Win2016" `
        -DomainMode "Win2016" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force) `
        -InstallDNS:$true `
        -NoRebootOnCompletion:$false
} else {
    Write-Host "✅ Le serveur est déjà un contrôleur de domaine." -ForegroundColor Green
}

# Création des OUs
$OUs = @("CORE", "HUMANS", "Utilisateurs", "ADMIN")
foreach ($OU in $OUs) {
    $ouPath = "OU=$OU,DC=ramzou,DC=local"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $OU -Path "DC=ramzou,DC=local"
        Write-Host "✅ OU $OU créée avec succès." -ForegroundColor Green
    } else {
        Write-Host "ℹ️ OU $OU existe déjà." -ForegroundColor Yellow
    }
}

# Fonction pour ajouter des utilisateurs à Active Directory
function Add-UserToAD {
    param (
        [string]$FirstName,
        [string]$LastName,
        [string]$Password,
        [string]$TargetOU
    )

    $userPrincipalName = "$FirstName.$LastName@$DomainName"
    $SamAccountName = "$FirstName$LastName"

    $userParams = @{
        SamAccountName       = $SamAccountName
        UserPrincipalName    = $userPrincipalName
        Name                 = "$FirstName $LastName"
        GivenName            = $FirstName
        Surname              = $LastName
        DisplayName          = "$FirstName $LastName"
        Path                 = "OU=$TargetOU,DC=ramzou,DC=local"
        AccountPassword      = ConvertTo-SecureString -String $Password -AsPlainText -Force
        Enabled              = $true
        PasswordNeverExpires = $true
    }

    if (-not (Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue)) {
        New-ADUser @userParams
        Write-Host "✅ Utilisateur $FirstName $LastName ajouté dans l'OU $TargetOU." -ForegroundColor Green
    } else {
        Write-Host "ℹ️ L'utilisateur $FirstName $LastName existe déjà." -ForegroundColor Yellow
    }
}

# Importer les utilisateurs standards
if (Test-Path $UsersCsvPath) {
    $Users = Import-Csv -Path $UsersCsvPath
    foreach ($User in $Users) {
        Add-UserToAD -FirstName $User.first_name -LastName $User.last_name -Password $User.password -TargetOU "Utilisateurs"
    }
} else {
    Write-Host "❌ Fichier $UsersCsvPath introuvable !" -ForegroundColor Red
}

# Importer les administrateurs
if (Test-Path $AdminsCsvPath) {
    $Admins = Import-Csv -Path $AdminsCsvPath
    foreach ($Admin in $Admins) {
        Add-UserToAD -FirstName $Admin.first_name -LastName $Admin.last_name -Password $Admin.password -TargetOU "ADMIN"
    }
} else {
    Write-Host "❌ Fichier $AdminsCsvPath introuvable !" -ForegroundColor Red
}

Write-Host "🎉 Installation et importation terminées avec succès !" -ForegroundColor Green
