<#
Yext_API_dev20251021_1430_StagePromote.ps1
  Yext Stage/Promote – Locations (Entities), Reviews, Listings
  - PowerShell 5.1 compatible
  - Endpoints:
      * Locations: /entities
      * Reviews:   /reviews
      * Listings:  /listings/listings  (fallback: /listings/entitylistings)
  - Actions: Display | Stage | Promote | All
  - Staging:
      * EntityLocationsRaw: (Id, RawJson, IngestedAt)
      * ReviewsRaw:         (ReviewId, RawJson, IngestedAt)
      * ListingsRaw:        (LocationId, PublisherId, ListingId, Status, Url, UpdatedAt, RawJson, IngestedAt)
  - Promote via stored procs from config:
      * PromoteEntityLocations / PromoteReviews / PromoteListings
#>

param(
  [ValidateSet('Locations','Reviews','Listings')][string]$Dataset = 'Locations',
  [ValidateSet('Display','Stage','Promote','All')][string]$Action = 'Display',

  # Reviews-only (optional)
  [datetime]$Since,

  # Listings filters (all optional)
  [string[]]$LocationIds,
  [string[]]$EntityIds,
  [string[]]$PublisherIds,
  [string[]]$Statuses,
  [string]$Language,

  # Common display & paging
  [int]$PreviewTop = 5,
  [int]$Limit,
  [int]$MaxPagesOverride
)

#========================
# Configuration
#========================
$ErrorActionPreference = 'Stop'
$ConfigPath = "./config/yext_config.psd1"
if (-not (Test-Path $ConfigPath)) { Write-Error "Config not found: $ConfigPath"; exit 1 }
$Config = Import-PowerShellDataFile -Path $ConfigPath

$BaseUrl       = $Config.BaseUrl.TrimEnd('/')
$AccountId     = if ($Config.AccountId) { $Config.AccountId } else { 'me' }
$ApiVersionV   = if ($Config.Version)   { $Config.Version }   else { (Get-Date -Format 'yyyyMMdd') }

$SqlServer     = $Config.SqlServer
$Database      = $Config.Database

$StagingTables = $Config.StagingTables
$TargetTables  = $Config.TargetTables
$StoredProcs   = $Config.StoredProcs

$DefaultApiKey = $Config.ApiKey
$ApiKeys       = $Config.ApiKeys

$EntitiesKey   = if ($ApiKeys.Entities) { $ApiKeys.Entities } else { $DefaultApiKey }
$ReviewsKey    = if ($ApiKeys.Reviews)  { $ApiKeys.Reviews }  else { $DefaultApiKey }
$ListingsKey   = if ($ApiKeys.Listings) { $ApiKeys.Listings } else { $DefaultApiKey }

# Endpoint caps (observed / documented)
$EndpointLimitCaps = @{
  'entities'                 = 50
  'reviews'                  = 50
  'listings/listings'        = 100
  'listings/entitylistings'  = 100
}

$DefaultLimitConfig = if ($Config.Settings.DefaultLimit) { [int]$Config.Settings.DefaultLimit } else { 50 }
$DefaultLimit       = if ($Limit) { [int]$Limit } else { $DefaultLimitConfig }
$MaxPages           = if ($MaxPagesOverride) { [int]$MaxPagesOverride } elseif ($Config.Settings.MaxPages) { [int]$Config.Settings.MaxPages } else { 500 }
$AllowSyntheticIds  = if ($Config.Settings.ContainsKey('AllowSyntheticIds')) { [bool]$Config.Settings.AllowSyntheticIds } else { $false }

#========================
# Logging
#========================
$LogFolder = "./logs"; $null = New-Item -ItemType Directory -Force -Path $LogFolder -ErrorAction SilentlyContinue
$LogFile   = Join-Path $LogFolder ("YextAPI_{0}.log" -f (Get-Date -Format 'yyyyMMdd'))
function Write-Log {
  param([Parameter(Mandatory)][string]$Message,[ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level='INFO')
  $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $line = "[$ts][$Level] $Message"
  Add-Content -Path $LogFile -Value $line
  if ($Level -eq 'ERROR') { Write-Error $Message }
  elseif ($Level -eq 'WARN') { Write-Warning $Message }
  else { Write-Host $Message }
}

#========================
# HTTP helpers
#========================
function New-ApiUri {
  param([Parameter(Mandatory)][string]$Endpoint,[hashtable]$Params,[string]$ApiKeyOverride)
  if ([string]::IsNullOrWhiteSpace($Endpoint)) { throw "New-ApiUri: Endpoint cannot be empty." }
  $key = if ($ApiKeyOverride) { $ApiKeyOverride } else { $DefaultApiKey }
  if (-not $key) { throw "No API key available. Provide dataset-specific key or ApiKey fallback in config." }

  $qs = New-Object System.Collections.Specialized.OrderedDictionary
  $qs.Add("api_key", $key); $qs.Add("v", $ApiVersionV)
  if ($Params) { $Params.GetEnumerator() | ForEach-Object { if (-not $qs.Contains($_.Key)) { $qs.Add($_.Key,$_.Value) } else { $qs[$_.Key]=$_.Value } } }
  $pairs = foreach ($k in $qs.Keys) { "{0}={1}" -f [uri]::EscapeDataString([string]$k), [uri]::EscapeDataString([string]$qs[$k]) }

  $builder = New-Object System.UriBuilder($BaseUrl)
  $path = "accounts/$AccountId/$Endpoint"
  if ($builder.Path.EndsWith('/')) { $builder.Path += $path } else { $builder.Path += "/$path" }
  $builder.Query = ($pairs -join '&')
  return $builder.Uri.AbsoluteUri
}

function Invoke-YextApiRequest {
  param([Parameter(Mandatory)][string]$Endpoint,[hashtable]$Params,[string]$ApiKeyToUse,[int]$MaxRetries=3)
  $attempt = 0
  do {
    try {
      $attempt++
      $uri = New-ApiUri -Endpoint $Endpoint -Params $Params -ApiKeyOverride $ApiKeyToUse
      Write-Log "GET $uri" 'DEBUG'
      return Invoke-RestMethod -Method GET -Uri $uri -ErrorAction Stop
    } catch {
      $bodyText = $null
      try {
        $resp = $_.Exception.Response
        if ($resp) { $reader = New-Object System.IO.StreamReader($resp.GetResponseStream()); $bodyText = $reader.ReadToEnd(); $reader.Close() }
      } catch { }
      if ($attempt -lt $MaxRetries) {
        $delay = [math]::Min(30,[math]::Pow(2,$attempt))
        Write-Log "API request failed (attempt $attempt): $($_.Exception.Message) | Body: $bodyText. Retrying in $delay s..." 'WARN'
        Start-Sleep -Seconds $delay
      } else {
        Write-Log "API request failed after $attempt attempts: $($_.Exception.Message) | Body: $bodyText" 'ERROR'
        throw
      }
    }
  } while ($true)
}

function Get-EffectiveLimit { param([Parameter(Mandatory)][string]$EndpointName)
  $key = $EndpointName.ToLowerInvariant()
  $cap = if ($EndpointLimitCaps.ContainsKey($key)) { [int]$EndpointLimitCaps[$key] } else { $DefaultLimit }
  return [math]::Min($DefaultLimit, $cap)
}

function Invoke-YextPaged {
  param([Parameter(Mandatory)][string]$Endpoint,[hashtable]$BaseParams,[string]$ApiKeyToUse)
  if ([string]::IsNullOrWhiteSpace($Endpoint)) { throw "Invoke-YextPaged: Endpoint cannot be empty." }

  $items      = @()
  $token      = $null
  $page       = 0
  $effLimit   = Get-EffectiveLimit -EndpointName $Endpoint

  do {
    $p = @{}
    if ($BaseParams) { $BaseParams.GetEnumerator() | ForEach-Object { $p[$_.Key]=$_.Value } }
    $p['limit'] = $effLimit
    if ($token) { $p['pageToken'] = $token }

    $res  = Invoke-YextApiRequest -Endpoint $Endpoint -Params $p -ApiKeyToUse $ApiKeyToUse
    $body = $res.response; if (-not $body) { $body = $res }

    # Known array keys across endpoints
    $arrayKeys = @('entities','reviews','listings','entityListings','duplicates','publishers','publisherSuggestions','docs','results','suggestions')
    $foundAny = $false
    foreach ($k in $arrayKeys) {
      if ($body.PSObject.Properties.Name -contains $k -and $body.$k) {
        $items += $body.$k
        $foundAny = $true
      }
    }
    if (-not $foundAny) {
      # Last resort: first enumerable in body
      foreach ($prop in $body.PSObject.Properties) {
        if ($prop.Value -is [System.Collections.IEnumerable] -and -not ($prop.Value -is [string])) {
          $items += $prop.Value
          break
        }
      }
    }

    $token = if ($body.nextPageToken) { $body.nextPageToken } elseif ($body.pageToken) { $body.pageToken } else { $null }
    $page++; Write-Log "Fetched page $page; total items: $($items.Count)" 'INFO'
    if ($page -ge $MaxPages) { Write-Log "Reached MaxPages ($MaxPages); stopping." 'WARN'; break }
  } while ($token)

  return $items
}

#========================
# Helpers (keys, hashing)
#========================
function Get-FirstNonEmpty { param([Parameter(Mandatory=$false)][object]$Candidates)
  if ($null -eq $Candidates) { return $null }
  if ($Candidates -isnot [System.Collections.IEnumerable] -or $Candidates -is [string]) { $Candidates = ,$Candidates }
  foreach ($c in $Candidates) { if ($null -ne $c -and -not [string]::IsNullOrWhiteSpace([string]$c)) { return [string]$c } }
  return $null
}
function Compute-HashHex { param([Parameter(Mandatory)][string]$Text)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $bytes=[System.Text.Encoding]::UTF8.GetBytes($Text); $hash=$sha.ComputeHash($bytes); return -join ($hash|%{ $_.ToString('x2') }) }
  finally { $sha.Dispose() }
}
function Resolve-ItemKey {
  param([Parameter(Mandatory)][psobject]$Item,[ValidateSet('Locations','Reviews','Listings')][string]$Dataset,[Parameter(Mandatory)][string]$RawJson)
  $candidates = @()
  try {
    switch ($Dataset) {
      'Locations' { $candidates += @($Item.id, $Item.entityId, $Item.uid) }
      'Reviews'   { $candidates += @($Item.id, $Item.reviewId, $Item.uid, $Item.entityId) }
      'Listings'  {
        $candidates += @($Item.id, $Item.listingId, $Item.uid)
        if ($Item.publisherId -and $Item.locationId) { $candidates += ("{0}_{1}" -f $Item.publisherId, $Item.locationId) }
        if ($Item.publisherId -and $Item.entityId)   { $candidates += ("{0}_{1}" -f $Item.publisherId, $Item.entityId) } # some payloads
      }
    }
    if ($Item.PSObject.Properties.Match('meta').Count -gt 0 -and $Item.meta) {
      $candidates += @($Item.meta.id, $Item.meta.uid)
    }
  } catch { }
  $key = Get-FirstNonEmpty -Candidates $candidates
  if ($null -eq $key -and $AllowSyntheticIds) { $key = "syn_" + (Compute-HashHex -Text $RawJson).Substring(0,24) }
  return $key
}

#========================
# Dataset fetchers
#========================
function Fetch-Locations { Invoke-YextPaged -Endpoint 'entities'  -BaseParams @{} -ApiKeyToUse $EntitiesKey }
function Fetch-Reviews   {
  param([datetime]$SinceDate)
  $base = @{}
  if ($PSBoundParameters.ContainsKey('SinceDate') -and $SinceDate) { $base.since = [int][double]::Parse((Get-Date $SinceDate -UFormat %s)) }
  Invoke-YextPaged -Endpoint 'reviews' -BaseParams $base -ApiKeyToUse $ReviewsKey
}
function Fetch-Listings {
  param([string[]]$LocationIdsParam,[string[]]$EntityIdsParam,[string[]]$PublisherIdsParam,[string[]]$StatusesParam,[string]$LanguageParam)

  # Build base params per doc (listings/listings accepts: locationIds, publisherIds, statuses, language)
  $base = @{}
  if ($LocationIdsParam -and $LocationIdsParam.Count -gt 0) { $base.locationIds  = ($LocationIdsParam  -join ',') }
  if ($PublisherIdsParam -and $PublisherIdsParam.Count -gt 0){ $base.publisherIds = ($PublisherIdsParam -join ',') }
  if ($StatusesParam -and $StatusesParam.Count -gt 0)       { $base.statuses     = ($StatusesParam     -join ',') }
  if ($LanguageParam)                                        { $base.language     = $LanguageParam }

  # Some stacks expose entity-centric listings (/entitylistings) which take entityIds
  $baseEntity = @{}
  if ($EntityIdsParam -and $EntityIdsParam.Count -gt 0) { $baseEntity.entityIds = ($EntityIdsParam -join ',') }
  if ($PublisherIdsParam -and $PublisherIdsParam.Count -gt 0){ $baseEntity.publisherIds = ($PublisherIdsParam -join ',') }
  if ($StatusesParam -and $StatusesParam.Count -gt 0)       { $baseEntity.statuses     = ($StatusesParam     -join ',') }
  if ($LanguageParam)                                        { $baseEntity.language     = $LanguageParam }

  $candidates = @(
    @{ Ep='listings/listings';       Params=$base      },
    @{ Ep='listings/entitylistings'; Params=$baseEntity}
  )

  foreach ($c in $candidates) {
    try {
      return Invoke-YextPaged -Endpoint $c.Ep -BaseParams $c.Params -ApiKeyToUse $ListingsKey
    } catch {
      $msg = $_.Exception.Message
      if ($msg -match '404' -or $msg -match 'Not Found') {
        Write-Log "Endpoint $($c.Ep) returned 404; trying next candidate..." 'WARN'
        continue
      } else {
        throw
      }
    }
  }

  throw "Listings endpoints tried returned 404. Check key access or adjust filters."
}

#========================
# Display
#========================
function Show-Preview {
  param([Parameter(Mandatory)][object[]]$Items,[int]$Top=5,[string]$Dataset)
  if ($Top -le 0 -or -not $Items -or $Items.Count -eq 0) { return }
  Write-Host ""; Write-Host "Preview (top $Top) — $Dataset" -ForegroundColor Cyan
  switch ($Dataset) {
    'Locations' {
      $Items | Select-Object -First $Top `
        @{n='Id';e={$_.id}}, @{n='Name';e={$_.name}},
        @{n='City';e={$_.address.city}}, @{n='Region';e={$_.address.region}},
        @{n='Phone';e={$_.mainPhone}}, @{n='UpdatedAt';e={$_.updatedAt}} |
        Format-Table -AutoSize | Out-String | Write-Host
    }
    'Reviews' {
      $Items | Select-Object -First $Top `
        @{n='ReviewId';e={$_.id}}, @{n='EntityId';e={$_.entityId}},
        @{n='Rating';e={$_.rating}}, @{n='Date';e={$_.reviewDate}},
        @{n='Source';e={$_.source}}, @{n='Author';e={$_.authorName}} |
        Format-Table -AutoSize | Out-String | Write-Host
    }
    'Listings' {
      $Items | Select-Object -First $Top `
        @{n='Key';e={ Resolve-ItemKey -Item $_ -Dataset 'Listings' -RawJson (($_ | ConvertTo-Json -Depth 10 -Compress)) }},
        @{n='LocationId';e={$_.locationId}}, @{n='EntityId';e={$_.entityId}},
        @{n='Publisher';e={$_.publisherId}}, @{n='Status';e={$_.status}},
        @{n='Url';e={$_.url}}, @{n='UpdatedAt';e={$_.updatedAt}} |
        Format-Table -AutoSize | Out-String | Write-Host
    }
  }
}

#========================
# Staging
#========================
function Build-RawDataTable {
  param([Parameter(Mandatory)][object[]]$Items,[Parameter(Mandatory)][string]$KeyColumn,[ValidateSet('Locations','Reviews')][string]$Dataset)
  $dt = New-Object System.Data.DataTable
  [void]$dt.Columns.Add($KeyColumn); [void]$dt.Columns.Add('RawJson'); [void]$dt.Columns.Add('IngestedAt')
  $now = Get-Date; $skippedNullItems = 0; $skippedNoKey = 0

  foreach ($x in $Items) {
    if ($null -eq $x) { $skippedNullItems++; continue }
    $raw = ($x | ConvertTo-Json -Depth 20 -Compress)
    $key = $null
    try { $key = Resolve-ItemKey -Item $x -Dataset $Dataset -RawJson $raw } catch { $key = $null }
    if ([string]::IsNullOrWhiteSpace($key)) { $skippedNoKey++; continue }

    $row = $dt.NewRow()
    $row[$KeyColumn] = $key; $row['RawJson'] = $raw; $row['IngestedAt'] = $now
    [void]$dt.Rows.Add($row)
  }

  if ($skippedNullItems -gt 0) { Write-Log "Skipped $skippedNullItems null item(s) from API." 'WARN' }
  if ($skippedNoKey -gt 0) { Write-Log "Skipped $skippedNoKey item(s) missing key (Dataset=$Dataset)." 'WARN' }

  return ,$dt
}

function Build-ListingsStageTable {
  param([Parameter(Mandatory)][object[]]$Items)
  $dt = New-Object System.Data.DataTable
  foreach ($col in 'LocationId','PublisherId','ListingId','Status','Url','UpdatedAt','RawJson','IngestedAt') { [void]$dt.Columns.Add($col) }
  $now = Get-Date
  foreach ($x in $Items) {
    if ($null -eq $x) { continue }
    $raw = ($x | ConvertTo-Json -Depth 20 -Compress)

    $locId  = if ($x.PSObject.Properties.Name -contains 'locationId') { [string]$x.locationId }
              elseif ($x.PSObject.Properties.Name -contains 'entityId') { [string]$x.entityId } else { $null }
    $pubId  = if ($x.PSObject.Properties.Name -contains 'publisherId') { [string]$x.publisherId } else { $null }
    $listId = if ($x.PSObject.Properties.Name -contains 'id')          { [string]$x.id }
              elseif ($x.PSObject.Properties.Name -contains 'listingId'){ [string]$x.listingId } else { $null }
    $status = if ($x.PSObject.Properties.Name -contains 'status')      { [string]$x.status } else { $null }
    $url    = if ($x.PSObject.Properties.Name -contains 'url')         { [string]$x.url } else { $null }
    $upd    = $null
    if ($x.PSObject.Properties.Name -contains 'updatedAt' -and $x.updatedAt) {
      try { $upd = [datetime]::Parse([string]$x.updatedAt) } catch { $upd = $null }
    }

    $row = $dt.NewRow()
    $row['LocationId'] = $locId
    $row['PublisherId']= $pubId
    $row['ListingId']  = $listId
    $row['Status']     = $status
    $row['Url']        = $url
    $row['UpdatedAt']  = $upd
    $row['RawJson']    = $raw
    $row['IngestedAt'] = $now
    [void]$dt.Rows.Add($row)
  }
  return ,$dt
}

function Bulk-Stage {
  param([Parameter(Mandatory)][object]$DataTable,[Parameter(Mandatory)][string]$DestTable)
  if ($DataTable -is [System.Object[]]) { if ($DataTable.Count -eq 1 -and $DataTable[0] -is [System.Data.DataTable]) { $DataTable = $DataTable[0] } }
  if ($DataTable -isnot [System.Data.DataTable]) {
    $t = if ($DataTable) { $DataTable.GetType().FullName } else { '<null>' }
    throw "Bulk-Stage expected [System.Data.DataTable], but received: $t"
  }
  $cn = New-Object System.Data.SqlClient.SqlConnection ("Server=$SqlServer;Database=$Database;Integrated Security=True")
  $cn.Open()
  try {
    $bulk = New-Object System.Data.SqlClient.SqlBulkCopy($cn)
    $bulk.DestinationTableName = $DestTable
    foreach ($c in $DataTable.Columns) { [void]$bulk.ColumnMappings.Add($c.ColumnName,$c.ColumnName) }
    $bulk.WriteToServer($DataTable)
    Write-Log "Staged $($DataTable.Rows.Count) rows to $DestTable." 'INFO'
  } catch { Write-Log "Bulk stage failed: $($_.Exception.Message)" 'ERROR'; throw }
  finally { $cn.Close() }
}

#========================
# Promotion
#========================
function Promote-WithProc {
  param([Parameter(Mandatory)][string]$ProcName)
  $cn = New-Object System.Data.SqlClient.SqlConnection ("Server=$SqlServer;Database=$Database;Integrated Security=True")
  $cn.Open()
  try { $cmd = $cn.CreateCommand(); $cmd.CommandText = "EXEC $ProcName"; [void]$cmd.ExecuteNonQuery(); Write-Log "Promotion executed: $ProcName" 'INFO' }
  catch { Write-Log "Promotion failed ($ProcName): $($_.Exception.Message)" 'ERROR'; throw }
  finally { $cn.Close() }
}

#========================
# Orchestrate
#========================
try {
  Write-Log "Start. Dataset=$Dataset; Action=$Action; Since=$Since; Limit=$DefaultLimit; MaxPages=$MaxPages" 'INFO'

  switch ($Dataset) {
    'Locations' {
      if ($Action -in @('Display','Stage','All')) {
        $items = Fetch-Locations
      }
      if ($Action -in @('Display','All')) {
        Show-Preview -Items $items -Top $PreviewTop -Dataset 'Locations'
      }
      if ($Action -in @('Stage','All')) {
        $dt = Build-RawDataTable -Items $items -KeyColumn 'Id' -Dataset 'Locations'
        Bulk-Stage -DataTable $dt -DestTable $StagingTables.EntityLocationsRaw
      }
      if ($Action -in @('Promote','All')) {
        Promote-WithProc -ProcName $StoredProcs.PromoteEntityLocations
      }
    }

    'Reviews' {
      if ($Action -in @('Display','Stage','All')) {
        if ($PSBoundParameters.ContainsKey('Since') -and $Since) { $items = Fetch-Reviews -SinceDate $Since } else { $items = Fetch-Reviews }
      }
      if ($Action -in @('Display','All')) {
        Show-Preview -Items $items -Top $PreviewTop -Dataset 'Reviews'
      }
      if ($Action -in @('Stage','All')) {
        $dt = Build-RawDataTable -Items $items -KeyColumn 'ReviewId' -Dataset 'Reviews'
        Bulk-Stage -DataTable $dt -DestTable $StagingTables.ReviewsRaw
      }
      if ($Action -in @('Promote','All')) {
        Promote-WithProc -ProcName $StoredProcs.PromoteReviews
      }
    }

    'Listings' {
      if ($Action -in @('Display','Stage','All')) {
        $items = Fetch-Listings -LocationIdsParam $LocationIds -EntityIdsParam $EntityIds -PublisherIdsParam $PublisherIds -StatusesParam $Statuses -LanguageParam $Language
      }
      if ($Action -in @('Display','All')) {
        Show-Preview -Items $items -Top $PreviewTop -Dataset 'Listings'
      }
      if ($Action -in @('Stage','All')) {
        $dt = Build-ListingsStageTable -Items $items
        Bulk-Stage -DataTable $dt -DestTable $StagingTables.ListingsRaw
      }
      if ($Action -in @('Promote','All')) {
        Promote-WithProc -ProcName $StoredProcs.PromoteListings
      }
    }
  }

  Write-Log "Completed." 'INFO'
} catch {
  Write-Log "Unhandled error: $($_.Exception.Message)" 'ERROR'
  throw
}
