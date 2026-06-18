$dirs = @("C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp", "C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp-para asesores")
$excludeDirs = @('.git', 'build', '.dart_tool', 'Pods')
$excludeExtensions = @('.png', '.jpg', '.jpeg', '.zip', '.exe', '.dll', '.so', '.dylib', '.ico')

$modifiedCount = 0

foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Get-ChildItem -Path $dir -Recurse -File | Where-Object {
            $isNotExcludedDir = $true
            foreach ($ex in $excludeDirs) {
                if ($_.FullName -match "\\$ex\\") {
                    $isNotExcludedDir = $false
                    break
                }
            }
            $isNotExcludedExt = $excludeExtensions -notcontains $_.Extension
            $isNotExcludedDir -and $isNotExcludedExt
        } | ForEach-Object {
            try {
                $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
                $originalContent = $content
                
                # Ordered replacements
                $content = $content -creplace 'Banco BCP', 'Caja Tacna'
                $content = $content -creplace 'banco bcp', 'caja tacna'
                $content = $content -creplace 'BANCO BCP', 'CAJA TACNA'
                $content = $content -creplace 'bancobcp', 'cajatacna'
                $content = $content -creplace 'BancoBcp', 'CajaTacna'
                $content = $content -creplace '\bBCP\b', 'CAJATACNA'
                $content = $content -creplace '\bbcp\b', 'cajatacna'
                $content = $content -creplace 'bcp_database', 'cajatacna_database'
                
                if ($content -cne $originalContent) {
                    [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.Encoding]::UTF8)
                    Write-Host "Modified: $($_.FullName)"
                    $modifiedCount++
                }
            } catch {
                # Ignore files that fail to read
            }
        }
    }
}

Write-Host "Total files modified: $modifiedCount"
