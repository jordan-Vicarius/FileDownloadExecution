function Getlinks {
    $WebResponse = Invoke-WebRequest "https://www.trellix.com/en-us/downloads/security-updates.html"
    $WebResponse.links | Where-Object {$_.href -like "*dat.exe*"}
    $hrefs = $WebResponse.links | Where-Object {$_.href -like "*dat.exe*"} | Select outerText, outherHTML, innerHTML, innerText, href 
    #$hrefs | export-csv -path .\datfiles.csv
    $links = @()
    $v3 = $hrefs | where-object {$_.outerText -like "*V3*dat.exe*"} | Select href, innerText
    $v3file = $v3.innerText
    $v3file = $v3file -replace '\s',''
    $v3href = $v3.href
    $v2href = $hrefs[0].href
    $v2file = $hrefs[0].innerText
    $v2file = $v2file -replace '\s',''
    $link = New-Object -TypeName pscustomobject
    $link | Add-Member -MemberType NoteProperty -name "version" -Value "v2"
    $link | Add-Member -MemberType NoteProperty -name "fileName" -Value $v2file
    $link | Add-Member -MemberType NoteProperty -name "href" -Value $v2href
    $links += $link
    $link = New-Object -TypeName pscustomobject
    $link | Add-Member -MemberType NoteProperty -name "version" -Value "v3"
    $link | Add-Member -MemberType NoteProperty -name "fileName" -Value $v3file
    $link | Add-Member -MemberType NoteProperty -name "href" -Value $v3href
    $links += $link

    return $links
}
function downloadDat ($datLink){
    $datLink = $links | Where-Object {$_.version -eq "v2"}
    $date = get-date -Format dd-MM-yyyy_hhmmss
    $outpath = "C:\temp\McAfee-" + $datLink.fileName
    Invoke-WebRequest -Uri $datLink.href -OutFile $outpath
    $i = 0 
    do {
        if (!(test-path -Path $outpath)) {
            $i = 5
        }
        else {
            start-sleep -s 30 
            $i += 1
        }
    }
    while ($i -le 4)
    return $outpath
}
function executeDat ($datPath) {
    start-process -FilePath $datPath
}
# Retrive download links, and File Names
$links = Getlinks
# Set the link Objects
$v2 = $links | Where-Object {$_.version -eq "v2"}
$v3 = $links | Where-Object {$_.version -eq "v3"}
# Download the specified link object
#Version 2 dat file 
$datFilePath = downloadDat $v2
#Version 3 dat file
#$datFilePath = downloadDat $v3
# Execute the dat file - This may need more adjustment as I am not sure if there are any specific flags or arguments to run with the exe. 
executeDat $datFilePath
