#Script allows you to add PAR2 repair data to a zip or 7z archive
#Use in Total Commander
#Add a new button to the toolbar where:
#Command: powershell.exe
#Parameters: -command c:\Programs\MultiPar\par_into_zip.ps1 %WL
#It is important that the path you specify points to the location of this script.
#Additionally, for convenience, place the PAR2 command line executable (par2j.exe or par2j64.exe) in the same location.
#The project page to download PAR2 files is https://github.com/Yutaka-Sawada/MultiPar
#In parameters %WL means preparing a file that is a list of archive files to be processed by the script.
#File is placed in the %TEMP% directory and deleted after closing the script window.
#This is necessary because TC incorrectly transfers names with spaces or commas as parameters to PS

#after adding the recovery data the archive will still be usable, but it will be larger in size due to the recovery data.
#in case of archive damage open the file in MULTIPAR (as repair, not creation)
#MultiPar will automatically detect the recovery data and allow repair, that is to restore to the original file without the recovery data.
#Warning!, do not repair a correct file, as this will delete the recovery data.

#########################script parameters, adjust to your needs 
#Path to command line par2 executable
$parPath='c:\programy\MultiPar\par2j64.exe'

#allowed extensions
#in the case of basic archives (zip and 7z) files are still usable. In the case of other files, data added at the end may make such a file unusable. Individual tests are necessary!
$rozszerzenia = @(".zip", ".7z")

#recovery data size [%]
$redundancja=10

##################### proper script

#check if the required PAR file is in the specified location
if (!(Test-Path $parPath)) {
    #No PAR2 executable in the location specified in the script
    #checking if the required file is in the script directory
    $parPath = $PSScriptRoot+"\par2j64.exe"
    if (!(Test-Path $parPath)) {
        #no 64bit file, checking 32bit
        $parPath = $PSScriptRoot+"\par2j.exe"
        if (!(Test-Path $parPath)) {
            write-host "PAR2 executable not found." -ForegroundColor Red
            write-host "Place it in the script directory, or point the script to the appropriate location." -ForegroundColor Yellow
            Read-Host -Prompt "`nScript stopped, press any key."
            exit
        }
    }
} 


#checking what operating system to display messages properly
if ([System.Environment]::OSVersion.Version.Major -lt 11) {
    $blad = "  "+[char][int]"0x2573"
    $ok = "  "+[char][int]"0x221A"
    }
else {
    $blad = "  ?"
    $ok = "  ?"
    }

#check if the path to the temporary file passed in the parameter exists
$plikPliki=$args[0]
if (!(Test-Path $plikPliki)) {
    write-host "Problem reading a file passed by TC containing files to be processed. Interrupting"
    exit
}
#reading the contents of a text file
$listaPlikow = @(Get-Content $plikPliki)


#determining the number of files transferred
$ile=$listaPlikow.Count

#go through all files in list
for ($i=0; $i -lt $ile; $i++) {
    $sciezka=$listaPlikow[$i]
	write-host -NoNewline "$($i+1)/$ile $sciezka"
    #check if file exists.
    if (!(Test-Path $sciezka)) {
        write-host "$blad - file not found." -ForegroundColor Red
        continue
    } 
    #checking if path is a directory
    if (Test-Path $sciezka -PathType Container) {
        Write-Host "$blad - This is a directory, skip." -ForegroundColor Gray
        continue
    }
    
    #checking if file extension is correct
    $PlikRozszerzenie = [System.IO.Path]::GetExtension($sciezka)
    if ($rozszerzenia -contains $PlikRozszerzenie) { #file processing
        #check if the file contains recovery data
        $polecenie = 'cmd /c "'+$parPath+'" l '+$sciezka
        $wynik = Invoke-Expression $polecenie
        if ($wynik | Select-String -Pattern "valid file is not found") {
            #file does not contain recovery data. Adding
            $katalog = [System.IO.Path]::GetDirectoryName($sciezka)
            $plik = [System.IO.Path]::GetFileNameWithoutExtension($sciezka)
            $plikPar="$katalog\$plik.par2"
            $polecenie = 'cmd /c "'+$parPath+'" c /sm2048 /rr'+$redundancja+' /rf1 /ri /in /lr32767 /lp4 "'+$plikPar+'" "'+$sciezka+'"'
            $wynik = Invoke-Expression $polecenie
            #Checking if the file was (not) created correctly
            if (!($wynik | Select-String -Pattern "Created successfully")) {
                Write-host "$blad - Error creating recovery file" -ForegroundColor Red
                continue
                }
            #combine files
            $wynikowyPlikPar="$katalog\$plik.vol_1.par2"
            #Opening the first file in append mode and opening the second file in read mode
            $firstFileStream = [System.IO.File]::Open($sciezka, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
            $secondFileStream = [System.IO.File]::OpenRead($wynikowyPlikPar)

            try {
                #We create a buffer to read data (e.g. 4MB)
                $buffer = New-Object byte[] (4MB)
                $bytesRead = 0

                #While we read data from the second file
                while (($bytesRead = $secondFileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    #Saving read data to the first file
                    $firstFileStream.Write($buffer, 0, $bytesRead)
                    }
                }
            finally {
                #Closing the stream to free up resources
                $firstFileStream.Close()
                $secondFileStream.Close()
                }
            #deleting the resulting PAR file
            Remove-Item -Path $wynikowyPlikPar -Force
            Write-Host $ok 
            } 
         else {
            #file contains recovery data skipping
            write-host "$blad - Repair data exists." -ForegroundColor DarkYellow
            continue
            }
        }
    else {
    #file does not have a valid extension go to next file
    write-host "$blad - Invalid file type." -ForegroundColor Red
    continue
    }
}

Read-Host -Prompt "Press Enter to exit"