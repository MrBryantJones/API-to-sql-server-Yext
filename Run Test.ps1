# Set working directory
cd "C:\xxx\xxx"

# Locations (Entities)
    # Run this to display records on screen 
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Locations -Action Display -PreviewTop 5
    # Run this to load Locations (Entities) data into the staging tables 
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Locations -Action Stage
    # Run this to promote\load Locations (Entities) data into the final tables
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Locations -Action Promote

# Reviews 
    # Run this to display records on screen
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Reviews -Action Display -PreviewTop 5
    # Run this to load Reviews data into the staging tables
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Reviews -Action Stage
    # Run this to promote\load Reviews data into the final tables
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Reviews -Action Promote

# Listings 
    # Run this to display records on screen
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Listings -Action Display -PreviewTop 5
    # Run this to load Listings data into the staging tables
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Listings -Action Stage
    # Run this to promote\load Listings data into the final tables
        .\Yext_Data_Pipeline_v20251024.ps1 -Dataset Listings -Action Promote
