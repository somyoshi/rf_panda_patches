# Aplica o icone dourado do Golden Siege Kit (slot 12 da folha de siege kits) no item.spr
$ErrorActionPreference = 'Stop'
$dir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$spr   = Join-Path $dir 'item.spr'
$patch = Join-Path $dir 'item_spr_goldkit.patch'
$bak   = Join-Path $dir 'item.spr.bak_goldkit'
function Md5($p) { (Get-FileHash -Algorithm MD5 -LiteralPath $p).Hash.ToLower() }
$p = [IO.File]::ReadAllBytes($patch)
if ([Text.Encoding]::ASCII.GetString($p,0,4) -ne 'RFSP') { throw 'patch invalido' }
$before = ($p[4..19]  | ForEach-Object { $_.ToString('x2') }) -join ''
$after  = ($p[20..35] | ForEach-Object { $_.ToString('x2') }) -join ''
$n = [BitConverter]::ToUInt32($p,36)
$cur = Md5 $spr
if ($cur -eq $after) { Write-Host 'O icone ja esta aplicado. Nada a fazer.'; exit 0 }
if ($cur -ne $before) { Write-Host "item.spr diferente do esperado ($cur). Nada foi alterado."; exit 1 }
if (-not (Test-Path -LiteralPath $bak)) { Copy-Item -LiteralPath $spr -Destination $bak }
$fs = [IO.File]::Open($spr, 'Open', 'ReadWrite')
try {
  $i = 40
  for ($k = 0; $k -lt $n; $k++) {
    $off = [BitConverter]::ToUInt32($p,$i); $len = [BitConverter]::ToUInt32($p,$i+4); $i += 8
    $fs.Seek($off, 'Begin') | Out-Null
    $fs.Write($p, $i, $len); $i += $len
  }
} finally { $fs.Close() }
$cur = Md5 $spr
if ($cur -ne $after) { Copy-Item -LiteralPath $bak -Destination $spr -Force; Write-Host 'MD5 final nao bateu; item.spr restaurado.'; exit 1 }
Write-Host 'Icone do Golden Siege Kit aplicado (item.spr OK).'
