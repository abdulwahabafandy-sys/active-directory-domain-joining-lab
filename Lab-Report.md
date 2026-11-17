# Lab 6 — Adding Multiple Computers to an Active Directory Domain

**Sheridan College | Cybersecurity Lab | Completed November 16, 2026**

## Objective

Create three Windows 10 Pro virtual machines, configure their names and static IP addresses, verify connectivity to a Windows Server 2022 domain controller, and automate domain joining from a CSV with PowerShell.

## Lab environment

| System | Address | Role |
|---|---|---|
| DC1 | 192.168.50.10 | Windows Server 2022, AD DS, DNS |
| PC1 | 192.168.50.11 | Windows 10 Pro domain client |
| PC2 | 192.168.50.12 | Windows 10 Pro domain client |
| PC3 | 192.168.50.13 | Windows 10 Pro domain client |

**VMware network:** VMnet1, host-only, 192.168.50.0/24.  
**AD DNS domain:** `lab6.test`  
**NetBIOS name:** `LAB6`  
**Domain controller:** `DC1.lab6.test`

## Procedure and results

### 1. Domain controller

Windows Server 2022 was renamed DC1, assigned 192.168.50.10/24, and configured with AD DS and DNS. It was promoted to host the new forest `lab6.test`.

The `Get-ADDomain` output confirmed `DNSRoot = lab6.test`, `NetBIOSName = LAB6`, and `PDCEmulator = DC1.lab6.test`.

### 2. PC1: baseline membership

PC1 was assigned 192.168.50.11/24, DNS was configured to use 192.168.50.10, and a PowerShell domain join was completed.

```powershell
Get-CimInstance Win32_ComputerSystem | Select-Object Name,Domain,PartOfDomain
```

Result: `PC1 | lab6.test | True`.

### 3. PC2 and PC3 networking

PC2 and PC3 were configured as `192.168.50.12/24` and `192.168.50.13/24` respectively, both using DC1 as DNS server. Ping tests to `192.168.50.10` showed four replies and 0% loss on each machine. `nslookup lab6.test` resolved to 192.168.50.10, despite an initial timeout while resolving the DNS server's displayed name.

DC1 successfully tested TCP 135 connectivity to both clients for remote administration.

### 4. CSV-driven automation

Created `C:\Scripts\Computers.csv` with PC2 and PC3 and verified it using:

```powershell
Import-Csv "C:\Scripts\Computers.csv"
```

The script `Scripts/Join-Computers.ps1` imported this list, requested domain and local administrator credentials securely, used `Add-Computer` to join each PC remotely, and requested each computer restart.

Executed on DC1:

```powershell
& "C:\Scripts\Join-Computers.ps1"
```

Result: `HasSucceeded = True` for both PC2 and PC3.

### 5. Active Directory verification

```powershell
Get-ADComputer -Filter * |
Where-Object {$_.Name -in @("PC1","PC2","PC3")} |
Select-Object Name,Enabled,DistinguishedName
```

Returned three enabled computer accounts under `CN=Computers,DC=lab6,DC=test`. The three computer objects also appeared together in Active Directory Users and Computers.

### 6. Client-side verification

PC2 and PC3 were checked independently with `Win32_ComputerSystem` after the automated join and restart. Both reported `Domain = lab6.test` and `PartOfDomain = True`.

| Client | Domain | PartOfDomain |
|---|---|---|
| PC1 | lab6.test | True |
| PC2 | lab6.test | True |
| PC3 | lab6.test | True |

## Screenshot evidence captured

The original screenshots and PDF report are prepared for upload, but are not yet hosted inside this repository. Screenshots captured during the session were:

1. `Get-ADDomain` showing the new domain controller.
2. PC1 reporting successful domain membership.
3. PC2 ping and DNS connectivity.
4. PC3 ping and DNS connectivity.
5. CSV import with PC2 and PC3.
6. `Join-Computers.ps1` displayed in Notepad.
7. Script execution returning `HasSucceeded = True` for PC2 and PC3.
8. `Get-ADComputer` listing all three enabled accounts.
9. Active Directory Users and Computers showing PC1, PC2 and PC3.
10. PC2 reporting domain membership.
11. PC3 reporting domain membership.

## Conclusion

The objective was achieved: three Windows 10 Pro machines were joined to the `lab6.test` Active Directory domain, including two successful remote joins using a CSV-driven PowerShell script. DC1 confirmed the computer objects, and each client independently verified domain membership.

**Scope note:** The worksheet directs disabling the Windows private-network firewall. Collected evidence demonstrates enabling the WMI rules for remote joins, but does not prove that the whole private firewall was disabled. This was an isolated educational host-only network; these settings should not be copied unchanged into production.
