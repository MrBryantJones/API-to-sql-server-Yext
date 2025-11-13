<#

NEW V4 20251112 1723

#>


@{
  BaseUrl   = 'https://api.yextapis.com/v2'
  AccountId = 'me'

  SqlServer = 'PLACEHOLDER'
  Database  = 'PLACEHOLDER'

  # REQUIRED by Yext: the 'v' parameter on API calls (use today's or a stable version date)
  Version = '20251016'

  ApiKeys = @{
    Entities  = 'PLACEHOLDER'  # for Locations
    Reviews   = 'PLACEHOLDER'
    Listings  = 'PLACEHOLDER'
    Analytics = 'PLACEHOLDER'  # ADD: if you keep per-scope keys; else reuse an existing key
  }

  StagingTables = @{
    EntityLocationsRaw = 'staging.YextEntityLocationsRaw'
    ReviewsRaw         = 'staging.YextReviewsRaw'
    ListingsRaw        = 'staging.YextListingsRaw'
    AnalyticsRaw       = 'staging.YextAnalyticsListingsPerformanceRaw'  # ADD
  }

  TargetTables = @{
    EntityLocations = 'dbo.YextEntityLocations'
    Reviews         = 'dbo.YextReviews'
    Listings        = 'dbo.YextListings'
    Analytics       = 'dbo.YextAnalyticsListingsPerformance'            # ADD
  }

  StoredProcs = @{
    PromoteEntityLocations = 'dbo.usp_PromoteYextEntityLocationsFromRaw'
    PromoteReviews         = 'dbo.usp_PromoteYextReviewsFromRaw'
    PromoteListings        = 'dbo.usp_PromoteYextListingsFromRaw'
    PromoteAnalytics       = 'dbo.usp_PromoteYextAnalyticsListingsPerformanceFromRaw'  # ADD
  }

  Settings = @{
    DefaultLimit      = 50
    MaxPages          = 500
    AllowSyntheticIds = $true   # used by Locations/Reviews raw staging when natural keys are missing

    # ADD: Analytics-specific runtime options
    Analytics = @{
      Metrics         = @(
        'GOOGLE_SEARCH_IMPRESSIONS',
        'GOOGLE_MAPS_IMPRESSIONS',
        'BING_SEARCH_IMPRESSIONS',
        'FACEBOOK_PAGE_IMPRESSIONS',
        'NETWORK_SEARCH_IMPRESSIONS',
        'GOOGLE_DIRECTIONS_CLICKS',
        'GOOGLE_CALL_CLICKS',
        'GOOGLE_WEBSITE_CLICKS',
        'GOOGLE_ORDER_NOW_CLICKS',
        'FACEBOOK_CTA_CLICKS',
        'PROFILE_VIEWS'
      )
      Dimensions      = @('DATE','ENTITY')
      Mode            = 'Incremental'  # Incremental | Backfill | OneShot
      LastNDays       = 35             # replay window for late data
      DataLagDays     = 2              # cap at Today-2 (UTC)
      StartDate       = $null          # for Backfill/OneShot
      EndDateOverride = $null          # optional cap (e.g., '2025-09-28')
      PageSize        = 250
      RetryPolicy     = @{ MaxRetries = 3; BackoffSec = @(2,5,10) }
      TimeoutSec      = 120
    }
  }
}



<#

WAS


@{
  BaseUrl   = 'https://api.yextapis.com/v2'
  AccountId = 'me'

  SqlServer = 'CXPVWSQL30'
  Database  = 'Marketing'

  # REQUIRED by Yext: the 'v' parameter on API calls (use today's or a stable version date)
  Version = '20251016'

  ApiKeys = @{
    Entities = '72fed2832aa757cf82dbdc9c9cfc022c'  # for Locations
    Reviews  = '66d81b2a563335f9208f1b467034ba04'
    Listings = 'a73a40d38b413458aef00f675866e58a'
  }

  StagingTables = @{
    EntityLocationsRaw = 'staging.YextEntityLocationsRaw'  
    ReviewsRaw         = 'staging.YextReviewsRaw'
    ListingsRaw        = 'staging.YextListingsRaw'
  }

  TargetTables = @{
    EntityLocations = 'dbo.YextEntityLocations'  
    Reviews         = 'dbo.YextReviews'
    Listings        = 'dbo.YextListings'
  }

  StoredProcs = @{
    PromoteEntityLocations = 'dbo.usp_PromoteYextEntityLocationsFromRaw' 
    PromoteReviews         = 'dbo.usp_PromoteYextReviewsFromRaw'
    PromoteListings        = 'dbo.usp_PromoteYextListingsFromRaw'
  }

  Settings = @{
    DefaultLimit      = 50
    MaxPages          = 500
    AllowSyntheticIds = $true   # used by Locations/Reviews raw staging when natural keys are missing
  }
}


#>