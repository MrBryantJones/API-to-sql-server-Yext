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