$DomainName = "lab6.test"
$DomainCreds = Get-Credential -UserName "LAB6\Administrator" -Message "Enter the domain admin password"

$LocalPw = Read-Host -Prompt "Enter the local Administrator password for PC2 and PC3" -AsSecureString

# Import computers from CSV
$Computers = Import-Csv -Path "C:\Scripts\Computers.csv"

foreach ($computer in $Computers) {
    $pc = $computer.Name
    $ip = $computer.IPAddress

    Write-Host "Joining $pc ($ip) to $DomainName..." -ForegroundColor Cyan

    $LocalCreds = New-Object System.Management.Automation.PSCredential("$pc\Administrator", $LocalPw)

    try {
        Add-Computer -ComputerName $ip `
            -LocalCredential $LocalCreds `
            -DomainName $DomainName `
            -Credential $DomainCreds `
            -Restart -Force -PassThru -ErrorAction Stop

        Write-Host "$pc domain join initiated." -ForegroundColor Green
    }
    catch {
        Write-Host "$pc failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
