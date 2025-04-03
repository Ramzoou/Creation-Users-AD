# Active Directory Setup and User Import Script

## 🚀 Introduction
Ce script PowerShell automatise l'installation d'**Active Directory Domain Services (ADDS)** et la configuration d'un serveur **DNS**. Il promeut votre serveur en contrôleur de domaine, crée des **Unités Organisationnelles (OUs)**, et importe des utilisateurs à partir de fichiers CSV.

## 📋 Prérequis
- **Système** : Windows Server (2016 ou supérieur)
- **Droits** : Accès administrateur
- **PowerShell** : Disponible
- **Connexion Internet** : Pour télécharger le script
- **Fichiers CSV** : `users.csv` et `admins.csv` (format : `first_name,last_name,password`)

## 💻 Fonctionnement

### 1. Vérification de l'IP
Le script vérifie que l'IP du serveur est statique avant de poursuivre.

### 2. Installation d'ADDS
Si le rôle **Active Directory Domain Services (ADDS)** n'est pas déjà installé, il sera ajouté automatiquement.

### 3. Promotion en contrôleur de domaine
Le serveur sera promu en contrôleur de domaine, et un serveur **DNS** sera installé.

### 4. Création des OUs
Les **Unités Organisationnelles (OUs)** nécessaires (par exemple, **Utilisateurs**, **Administrateurs**) seront créées.

### 5. Importation des utilisateurs
Les utilisateurs et administrateurs seront ajoutés à Active Directory à partir des fichiers CSV fournis.

## 🔧 Installation et Exécution

### 1. Téléchargement du Script
Exécutez les commandes PowerShell suivantes pour télécharger et extraire le script depuis ce dépôt :

```powershell
$RepoUrl = "https://github.com/Ramzoou/Creation-Users-AD.git"
$DestinationPath = "C:\Users\marti\git\Creation-Users-AD"
git clone $RepoUrl $DestinationPath
```
### 2. Configuration des Paramètres
Avant d'exécuter le script, modifiez les paramètres dans le fichier create-users.ps1 pour ajuster le domaine, les OUs, et les chemins des fichiers CSV.

### 3. Exécution du Script
Test en mode DryRun
Vérifiez le script avant d'exécuter les modifications en mode simulation :
```
cd C:\Users\marti\git\Creation-Users-AD
.\create-users.ps1 -DryRun
```

Si le test est concluant, lancez l'exécution complète du script :

```
.\create-users.ps1
```

### 4. Vérification
Une fois l'exécution terminée, vérifiez :

- Le serveur est bien devenu contrôleur de domaine.

- Le serveur DNS fonctionne correctement.

- Les utilisateurs et OUs ont été correctement créés.

### 🛠️ Remarques

Fichiers CSV : Assurez-vous que les fichiers sont bien formatés (les colonnes first_name, last_name, password).

Redémarrage : Après la promotion, le serveur redémarrera automatiquement. Si nécessaire, relancez le script après le redémarrage.