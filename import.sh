PS C:\Users\marti\git\user-importer> # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>> $users = import-csv -path "C:\Users\Administrateur\Downloads\import.csv" -delimiter ","
>> # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>> foreach($user in $users)
>> {
>>      # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>>      $nom = $user.nom
>>      $prenom= $user.prenom
>>      # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>>      $nomComplet = $prenom + " " + $nom
>>      $idSAM = $prenom.substring(0,1) + $nom
>>      $id = $idSAM + "@m2m.lan"
>>      # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>>      $pass= ConvertTo-SecureString "Tech2024$" -AsPlainText -Force
>>      # xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
>>      New-ADUser -name $idSAM -DisplayName $nomComplet -givenname $prenom -surname $nom -Path "OU=Utilisateurs,DC=m2m,DC=lan" -UserPrincipalName $id -AccountPassword $pass -Enabled $true
>> }
