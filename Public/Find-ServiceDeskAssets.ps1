function Find-ServiceDeskAssets {
    param (
        [Parameter(Mandatory)]
        $AccessToken,

        [Parameter(Mandatory)]
        $Portal,

        # Results per page
        [ValidateRange(1, 100)]
        $RowCount = 100,

        [ValidateNotNull()]
        $ProductType,

        [ValidateNotNull()]
        $Technician
    )

    $Headers = @{
        Authorization = "Zoho-Oauthtoken $AccessToken"
        Accept = "application/vnd.manageengine.sdp.v3+json"
    }

    # Make at least one initial request, after which start_index is determined by response
    $CurrentIndex = 1
    
    $Assets = $null

    Do {
        $Data = @{
            list_info = @{
                row_count = 100
                start_index = $CurrentIndex
                get_total_count = $true
                search_criteria = @(
                )

            }
        }
    
        if ($ProductType) {
            $Data.list_info.search_criteria += @{
                field = "product_type.name"
                condition = "is"
                values = $ProductType
            }
        }
    
        $Body = @{
            input_data = ($Data | ConvertTo-Json -Depth 4 -Compress)
        }
    
        $RestMethodParameters = @{
            Uri = "https://sdpondemand.manageengine.com/app/$Portal/api/v3/assets/"
            Headers = $Headers
            Method = "Get"
            Body = $Body
        }
    
        $Response = Invoke-RestMethod @RestMethodParameters
    
        $Assets += $Response.assets 
        
        # Increment the index to the start of the next page
        $CurrentIndex = $Response.list_info.start_index + $RowCount


    } while ([System.Convert]::ToBoolean($Response.list_info.has_more_rows))


    $Assets


}