# Blood & Glory Revival: export installed APK + OBB from selected phone.
# Read-only for Android. Requires ADB; does not export private saves.
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$pkg='com.glu.gladiator'
function Run([string[]]$argList) {
  $old=$ErrorActionPreference; $ErrorActionPreference='Continue'
  try { $output=(& $script:adb @argList 2>&1 | Out-String); $code=$LASTEXITCODE }
  finally { $ErrorActionPreference=$old }
  if ($code -ne 0) { throw ('ADB failed: '+($argList -join ' ')+' '+$output) }
  return $output.Trim()
}
try {
  $list=@()
  if ($env:ADB_PATH) {$list+=$env:ADB_PATH}
  if ($env:LOCALAPPDATA) {$list+=(Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe')}
  if ($env:ANDROID_HOME) {$list+=(Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe')}
  if ($env:ANDROID_SDK_ROOT) {$list+=(Join-Path $env:ANDROID_SDK_ROOT 'platform-tools\adb.exe')}
  $list+=(Join-Path $root 'adb.exe')
  $script:adb=$null
  foreach ($p in $list) {if ($p -and (Test-Path $p -PathType Leaf)) {$script:adb=$p;break}}
  if (!$script:adb) {$cmd=Get-Command adb.exe -ErrorAction SilentlyContinue; if ($cmd) {$script:adb=$cmd.Source}}
  if (!$script:adb) {throw 'ADB not found'}
  [void](Run @('start-server'))
  $dev=@(Run @('devices','-l') -split '[\r\n]+' | Where-Object {$_ -match '^\S+\s+device(\s|$)'})
  if (!$dev.Count) {throw 'No authorized phone connected'}
  for ($i=0;$i -lt $dev.Count;$i++) {Write-Host ('['+($i+1)+'] '+$dev[$i])}
  $index=0
  if ($dev.Count -gt 1) {
    $a=Read-Host 'Select phone number'
    if ($a -notmatch '^\d+$' -or [int]$a -lt 1 -or [int]$a -gt $dev.Count) {throw 'Invalid selection'}
    $index=[int]$a-1
  }
  $serial=([regex]::Match($dev[$index],'^\S+')).Value
  if ($serial -like 'emulator-*' -and (Read-Host 'Emulator selected. Type YES to continue') -ne 'YES') {throw 'Cancelled'}
  $raw=Run @('-s',$serial,'shell','pm','path',$pkg)
  $apks=@($raw -split '[\r\n]+' | Where-Object {$_ -match '^package:/\S+\.apk$'} | ForEach-Object {$_.Substring(8)})
  if (!$apks.Count) {throw 'Game not installed'}
  $dump=Run @('-s',$serial,'shell','dumpsys','package',$pkg)
  $version=[regex]::Match($dump,'\bversionName=(\S+)').Groups[1].Value
  $code=[regex]::Match($dump,'\bversionCode=(\d+)').Groups[1].Value
  $sdk=[regex]::Match($dump,'\btargetSdk=(\d+)').Groups[1].Value
  if (!$version -or !$code) {throw 'Could not read package version'}
  $obbdir='/sdcard/Android/obb/'+$pkg
  $raw=Run @('-s',$serial,'shell','ls','-1',$obbdir)
  $obbs=@($raw -split '[\r\n]+' | Where-Object {$_ -match '^[A-Za-z0-9_.-]+\.obb$'})
  if (!$obbs.Count) {throw 'No OBB found'}
  $stamp=Get-Date -Format yyyyMMdd_HHmmss
  $export=Join-Path $root ('EXPORTS\BLOOD_GLORY_PHONE_'+$stamp)
  $stage=Join-Path $export 'XAPK_CONTENTS'
  $obbStage=Join-Path $stage ('Android\obb\'+$pkg)
  New-Item -ItemType Directory -Force -Path $obbStage | Out-Null
  $split=@();$exp=@();[long]$total=0
  foreach ($p in $apks) {
    $name=($p -split '/')[-1]
    $id=[IO.Path]::GetFileNameWithoutExtension($name)
    if ($name -eq 'base.apk') {$name=$pkg+'.apk';$id='base'}
    if ($name -notmatch '^[A-Za-z0-9_.-]+\.apk$') {throw 'Unrecognized APK name'}
    $local=Join-Path $stage $name
    Write-Host ('Pull APK '+$name)
    [void](Run @('-s',$serial,'pull',$p,$local))
    $size=(Get-Item $local).Length
    $remote=[long](Run @('-s',$serial,'shell','stat','-c','%s',$p))
    if ($size -le 0 -or $size -ne $remote) {throw 'APK size mismatch'}
    $total+=$size;$split+=@{file=$name;id=$id}
  }
  foreach ($name in $obbs) {
    $remotePath=$obbdir+'/'+$name;$local=Join-Path $obbStage $name
    Write-Host ('Pull OBB '+$name)
    [void](Run @('-s',$serial,'pull',$remotePath,$local))
    $size=(Get-Item $local).Length
    $remote=[long](Run @('-s',$serial,'shell','stat','-c','%s',$remotePath))
    if ($size -le 0 -or $size -ne $remote) {throw 'OBB size mismatch'}
    $total+=$size;$exp+=@{file='Android/obb/'+$pkg+'/'+$name;install_location='EXTERNAL_STORAGE'}
  }
  $manifest=[ordered]@{xapk_version=2;package_name=$pkg;name='Blood & Glory Revival';version_name=$version;version_code=[int]$code;target_sdk_version=$sdk;total_size=$total;split_apks=$split;expansions=$exp}
  [IO.File]::WriteAllText((Join-Path $stage 'manifest.json'),($manifest|ConvertTo-Json -Depth 6),[Text.Encoding]::UTF8)
  $files=@(Get-ChildItem $stage -File -Recurse)
  $hashes=@{}
  foreach ($f in $files) {$rel=$f.FullName.Substring($stage.Length+1).Replace('\','/');$hashes[$rel]=(Get-FileHash $f.FullName -Algorithm SHA256).Hash}
  $out=Join-Path $export ('BLOOD_GLORY_REVIVAL_V5_WORKING_PHONE_'+$stamp+'.xapk')
  $tmp=$out+'.building'
  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip=[IO.Compression.ZipFile]::Open($tmp,[IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($f in $files) {
      $rel=$f.FullName.Substring($stage.Length+1).Replace('\','/')
      $entry=$zip.CreateEntry($rel,[IO.Compression.CompressionLevel]::Optimal)
      $src=[IO.File]::OpenRead($f.FullName);$dst=$entry.Open()
      try {$src.CopyTo($dst)}finally{$dst.Dispose();$src.Dispose()}
    }
  } finally {$zip.Dispose()}
  $check=[IO.Compression.ZipFile]::OpenRead($tmp)
  try {
    if ($check.Entries.Count -ne $files.Count) {throw 'File count mismatch'}
    foreach ($entry in $check.Entries) {
      if ($entry.FullName.Contains('\') -or !$hashes.ContainsKey($entry.FullName)) {throw ('Invalid path '+$entry.FullName)}
      $sha=[Security.Cryptography.SHA256]::Create();$stream=$entry.Open()
      try {$hash=[BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','')}
      finally {$stream.Dispose();$sha.Dispose()}
      if ($hash -ne $hashes[$entry.FullName]) {throw ('Hash mismatch '+$entry.FullName)}
    }
  }finally {$check.Dispose()}
  Move-Item $tmp $out
  $sums=@($hashes.Keys|Sort-Object|ForEach-Object{$hashes[$_]+'  XAPK_CONTENTS/'+$_})
  $sums+=(Get-FileHash $out -Algorithm SHA256).Hash+'  '+[IO.Path]::GetFileName($out)
  [IO.File]::WriteAllLines((Join-Path $export 'SHA256SUMS.txt'),[string[]]$sums)
  Write-Host ('DONE '+$out) -ForegroundColor Green
  Write-Host 'Private game saves were not exported.'
} catch {Write-Host ('ERROR '+$_.Exception.Message) -ForegroundColor Red;exit 1}
