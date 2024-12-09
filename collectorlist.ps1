# Define Sumo Logic API endpoint and credentials
$SumoLogicEndpoint = "https://api.[deployment].sumologic.com/api/v1/collectors"  # Update the endpoint based on your region
$AccessId = "yourid"  # Replace with your Sumo Logic Access ID
$AccessKey = "youkey"  # Replace with your Sumo Logic Access Key

# Encode the credentials for Basic Authentication
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AccessId):$($AccessKey)"))
$Headers = @{
    "Authorization" = "Basic $EncodedCredentials"
}

# CSV output file path
$CsvOutputFilePath = "C:\Users\aruns\Desktop\CollectorsInfo.csv"

# Function to fetch collectors
Function Get-Collectors {
    param (
        [string]$ApiUrl
    )
    $Collectors = @()

    # Loop through the pagination
    do {
        $Response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -Method Get
        $Collectors += $Response.collectors
        $ApiUrl = if ($Response.hasNext) { $Response.next } else { $null }
    } while ($ApiUrl)

    return $Collectors
}

# Fetch collectors from the API
$Collectors = Get-Collectors -ApiUrl $SumoLogicEndpoint

# Create a custom object with collector details
$CollectorDetails = $Collectors | ForEach-Object {
    [PSCustomObject]@{
        CollectorName = $_.name
        CollectorType = $_.collectorType
        Status        = $_.alive
	Lastseen      = $_.lastSeenAlive
    }
}

# Output to the console as a table
$CollectorDetails | Format-Table -AutoSize

# Export the collector details to a CSV file
$CollectorDetails | Export-Csv -Path $CsvOutputFilePath -NoTypeInformation -Encoding UTF8

# Print message about CSV export
Write-Host "Collector information has been exported to $CsvOutputFilePath"
