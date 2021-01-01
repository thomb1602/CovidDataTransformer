[string]$fileName = 'C:\Git\source\repos\Mine\covid_data\data\covid_data.csv'
[string]$outFileName = 'C:\Git\source\repos\Mine\covid_data\data\output.csv'

$csv = Import-Csv -Path $fileName 
$csv 

$csvDates = $csv | Select-Object date -Unique 
$csvRegions = $csv | Select-Object region -Unique

# pre-populate the new rooutputR objects
$outputRowObjects = [Collections.Generic.List[PSCustomObject]]@()
foreach ($date in $csvDates)
{
    $newRow = "" | Select-Object date, regionPairs
    $newRow.date = $date #with date
    $newRow.regionPairs = [Collections.Generic.List[PSCustomObject]]@()
    foreach ($region in $csvRegions)
    {
        $newRegionPair = [PSCustomObject]@{
            Region = $region
            Number = '-' #default
        }
        $newRow.regionPairs.Add($newRegionPair) #and with regionPair
    }
    $outputRowObjects.Add($newRow)
}

# loop through csv to create newRowObejcts containing its data
foreach ($csvRow in $csv)
{  
    [bool]$numberAdded = $false
    foreach ($outputRow in $outputRowObjects)
    {
        if ($outputRow.date.date -eq $csvRow.date) # find this csvRow's date in outputRowObjects
        {
            foreach ($regionPair in $outputRow.regionPairs)
            {
                if ($regionPair.Region.region -eq $csvRow.region) 
                {
                    $regionPair.number = $csvRow.number  # and add this csvRow's number to the right regionPair
                    $numberAdded = $true
                    break
                }
            }
        } if ($numberAdded) { break } 
    } 
}

# add header row
Add-Content -Path $outFileName -Value '"Date",' -NoNewline
foreach ($region in $csvRegions) 
{ 
    $colLabel = $region.region
    $colLabelWithPuntuation = "`"$colLabel`","
    # remove comma if it's the last item
    if ($csvRegions.IndexOf($region) + 1 -eq $csvRegions.Count) { $colLabelWithPuntuation = $colLabelWithPuntuation.Trim(",") }
    Add-Content -Path $outFileName -Value $colLabelWithPuntuation -NoNewline 
}
Add-Content -Path $outFileName -Value "`r`n" -NoNewline

# write data
foreach ($row in $outputRowObjects)
{
    $rowDate = $row.date.date
    Add-Content -Path $outFileName -Value "`"$rowDate`"," -NoNewline
    foreach ($pair in $row.regionPairs)
    {
        $number = $pair.number
        Add-Content -Path $outFileName -Value "`"$number`"," -NoNewline
    }
    Add-Content -Path $outFileName -Value "`r`n" -NoNewline
}
