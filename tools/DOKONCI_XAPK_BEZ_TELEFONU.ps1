# Rebuild XAPK from already exported APK+OBB. Does not touch the phone.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
try {
  $base = Join-Path $root 'EXPORTS'
  if (!(Test-Path $base)) { throw 'EXPORTS folder missing' }
  $candidates = @(Get-ChildItem $base -Directory -Filter 'BLOOD_GLORY_PHONE_*' | Sort-Object LastWriteTime -Descending)
  $source = $null; $manifest = $null
  foreach ($item in $candidates) {
    $dir = Join-Path $item.FullName 'XAPK_CONTENTS'
    $mp = Join-Path $dir 'manifest.json'
    if (!(Test-Path $mp)) { continue }
    try { $m = Get-Content $mp -Raw | ConvertFrom-Json } catch { continue }
    if ($m.package_name -ne 'com.glu.gladiator') { continue }
    $valid=$true
    foreach ($part in @($m.split_apks)+@($m.expansions)) {
      $p=[string]$part.file
      if ($p -notmatch '^[a-zA-Z0-9_.\/-]+$' -or $p.Contains('..') -or !(Test-Path (Join-Path $dir $p.Replace('/','\')) -PathType Leaf)) { $valid=$false; break }
    }
    if ($valid) { $source=$item; $manifest=$m; break }
  }
  if (!$source) { throw 'No complete export found under EXPORTS' }
  $stage = Join-Path $source.FullName 'XAPK_CONTENTS'
  $files = @(Get-ChildItem $stage -File -Recurse | Sort-Object FullName)
  $hashes = @{}; [long]$total=0
  foreach ($part in @($manifest.split_apks)+@($manifest.expansions)) {
    $total += (Get-Item (Join-Path $stage ([string]$part.file).Replace('/','\'))).Length
  }
  if ($null -ne $manifest.total_size -and $total -ne [long]$manifest.total_size) { throw 'APK/OBB total size mismatch' }
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($stage.Length+1).Replace('\','/')
    $hashes[$rel]=(Get-FileHash $f.FullName -Algorithm SHA256).Hash
  }
  if (!$hashes.ContainsKey('manifest.json') -or !$hashes.ContainsKey('com.glu.gladiator.apk')) { throw 'Missing manifest or APK' }
  $stamp=$source.Name.Replace('BLOOD_GLORY_PHONE_','')
  $output=Join-Path $source.FullName ("BLOOD_GLORY_REVIVAL_V5_WORKING_PHONE_"+$stamp+"_FIXED.xapk")
  if (Test-Path $output) { $output=Join-Path $source.FullName ("BLOOD_GLORY_REVIVAL_V5_WORKING_PHONE_"+$stamp+"_FIXED_"+(Get-Date -Format HHmmss)+".xapk") }
  $tmp=$output+'.building'
  if (Test-Path $tmp) { throw 'Temporary archive exists' }
  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip=[IO.Compression.ZipFile]::Open($tmp,[IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($f in $files) {
      $rel=$f.FullName.Substring($stage.Length+1).Replace('\','/')
      $entry=$zip.CreateEntry($rel,[IO.Compression.CompressionLevel]::Optimal)
      $input=[IO.File]::OpenRead($f.FullName); $stream=$entry.Open()
      try { $input.CopyTo($stream) } finally { $stream.Dispose(); $input.Dispose() }
    }
  } finally { $zip.Dispose() }
  $zip=[IO.Compression.ZipFile]::OpenRead($tmp)
  try {
    if ($zip.Entries.Count -ne $files.Count) { throw 'Wrong file count' }
    foreach ($entry in $zip.Entries) {
      if ($entry.FullName.Contains('\') -or !$hashes.ContainsKey($entry.FullName)) { throw ('Invalid archive path: '+$entry.FullName) }
      $sha=[Security.Cryptography.SHA256]::Create(); $stream=$entry.Open()
      try { $actual=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','') }
      finally { $stream.Dispose(); $sha.Dispose() }
      if ($actual -ne $hashes[$entry.FullName]) { throw ('Hash mismatch: '+$entry.FullName) }
    }
  } finally { $zip.Dispose() }
  Move-Item $tmp $output
  $lines=@($hashes.Keys|Sort-Object|ForEach-Object{ $hashes[$_]+'  XAPK_CONTENTS/'+$_ })
  $lines += (Get-FileHash $output -Algorithm SHA256).Hash+'  '+[IO.Path]::GetFileName($output)
  [IO.File]::WriteAllLines((Join-Path $source.FullName 'SHA256SUMS_FIXED.txt'),[string[]]$lines)
  [IO.File]::WriteAllLines((Join-Path $source.FullName 'REPORT_FIXED_CZ.txt'),[string[]]@('BLOOD GLORY REVIVAL V5 - XAPK verified','APK+OBB bytes: '+$total,'Archive: '+$output,'Private save files are not included.'))
  Write-Host ('HOTOVO: '+$output) -ForegroundColor Green
} catch { Write-Host ('CHYBA: '+$_.Exception.Message) -ForegroundColor Red; exit 1 }
