function Get-InedoHubInstaller {
    [Cmdletbinding()]
    Param(
      # URL of the InedoHub download page
      [Parameter()]
      [String]
      $url = "https://proget.inedo.com/upack/Products/download/InedoReleases/DesktopHub?contentOnly=zip&latest"
    )
  
    end {
      #Download the installer using an HttpClient so it's fast
      $client = [System.Net.Http.HttpClient]::new()
      $response = $client.GetAsync($url).Result
      #Get the file bytes so we can write it the file to disk
      $contentBytes = $response.Content.ReadAsByteArrayAsync().Result
  
      #We capture the filename to use by inspecting the Content-Disposition Header
      $matcher = '(?<filename>(?<=filename=")[^"]+(?="))'
      $null = ($response.content.Headers.GetEnumerator() | Where-Object Key -eq 'Content-Disposition' | Select-Object -ExpandProperty Value) -match $matcher
      $fileName = $matches.filename
      #Save the installer to disk using the filename and the bytes from the download
      $filepath = Join-Path $pwd -ChildPath $fileName
      $file = [System.IO.FileStream]::new($filepath, [System.IO.FileMode]::Create)
      $file.write($contentBytes, 0, $contentBytes.Length)
      $file.close()
  
      #Return some data
      $version = (($response.Headers.GetEnumerator() | Where Key -eq 'X-upack-id' | Select-Object -expand Value) -split ':')[-1]
      $fileHash = (Get-FIleHash $filepath -Algorithm SHA256).Hash
      $checksumType = 'SHA256'
  
      [pscustomObject]@{
        Filename     = $fileName
        Filepath     = $filepath
        Version      = $version
        Checksum     = $fileHash
        ChecksumType = $checksumType
      }
    }
  }