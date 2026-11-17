# Lab 06 — Automating Active Directory Domain Joins

**Windows Server 2022 · Windows 10 Pro · Active Directory · DNS · PowerShell · VMware Workstation**

## Overview

Configured an isolated Active Directory lab with a Windows Server 2022 domain controller and three Windows 10 Pro clients. Joined **PC1** individually, then automated the joins for **PC2** and **PC3** using a CSV-driven PowerShell script.

**Result:** All three clients were verified as members of `lab6.test`, and Active Directory listed all three computer objects.

**Verification:** PC1, PC2 and PC3 were all listed in Active Directory Users and Computers.

## Lab topology

```text
                 VMware Host-Only Network (VMnet1)
                      192.168.50.0/24
                              |
                     DC1 / Windows Server 2022
                     192.168.50.10
                     AD DS + DNS: lab6.test
                              |
                 +------------+------------+
                 |            |            |
                PC1          PC2          PC3
            192.168.50.11 192.168.50.12 192.168.50.13
            Windows 10 Pro / domain-member clients
```

| System | IPv4 address | Role |
|---|---|---|
| DC1 | `192.168.50.10` | Active Directory Domain Services and DNS |
| PC1 | `192.168.50.11` | Individually joined Windows 10 Pro client |
| PC2 | `192.168.50.12` | CSV-driven PowerShell domain join |
| PC3 | `192.168.50.13` | CSV-driven PowerShell domain join |

**Domain:** `lab6.test` · **NetBIOS:** `LAB6` · **Network:** VMware VMnet1 (host-only).

## What I implemented

1. Created three Windows 10 Pro virtual machines and assigned the computer names `PC1`, `PC2`, and `PC3`.
2. Installed Active Directory Domain Services and DNS on Windows Server 2022; promoted it to domain controller `DC1`.
3. Configured static IPv4 addressing and pointed the Windows clients' DNS settings to DC1.
4. Verified domain-controller connectivity using `ping` and `nslookup`.
5. Joined PC1 manually with PowerShell to validate the domain and DNS setup.
6. Created `Computers.csv` for PC2 and PC3, then used `Join-Computers.ps1` with `Import-Csv` and `Add-Computer`.
7. Validated the automated joins through script results, `Get-ADComputer`, Active Directory Users and Computers, and each client's domain-membership status.

## Automation approach

PC1 was joined using PowerShell, and PC2 and PC3 were joined remotely using `Add-Computer` with input from a CSV containing each computer's name and IP address. The script requested local and domain administrator credentials securely rather than storing passwords in plaintext. Both join operations returned `HasSucceeded = True`.

The commands, verification results, and implementation details are documented in [Lab-Report.md](Lab-Report.md).

## Verification and evidence

| Verification | Evidence |
|---|---|
| Active Directory domain configured | Domain controller output |
| PC1 joined to `lab6.test` | PC1 membership |
| PC2 and PC3 connectivity and DNS | PC2 test · PC3 test |
| CSV import | Computer list |
| PowerShell join script | Script |
| Successful remote join requests | Execution results |
| All three AD computer accounts enabled | Get-ADComputer |
| Active Directory Users and Computers | ADUC screenshot |
| PC2 and PC3 local verification | PC2 · PC3 |

The final PowerShell checks returned `PartOfDomain = True` and `Domain = lab6.test` for all three Windows clients.

## Lab report

[**Read the full lab report**](Lab-Report.md), including the procedure, configuration, command examples, captured results, limitations, and conclusion.

The separate submission PDF includes embedded screenshots; those images are not hosted individually in this repository.

## Skills demonstrated

- Active Directory domain controller deployment and administration
- Windows Server / Windows 10 system configuration
- DNS troubleshooting and static IPv4 addressing
- PowerShell automation with CSV input, credentials and error handling
- Remote administration and evidence-based validation

## Scope and security notes

This was an **isolated educational VMware host-only lab**, not a production domain. Remote WMI access was enabled for the domain-join exercise. The worksheet also directed disabling the private-network firewall; the collected evidence **does not establish that the entire firewall was disabled**. Windows 10 is no longer a regularly supported production OS, so these machines are intended only for isolated lab use.