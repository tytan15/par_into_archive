#Skrypt pozwala dodać do archiwum zip lub 7z dane naprawcze PAR2
#używać w programie Total Commander
#Dodać nowy przycisk na pasku narzędziowym gdzie:
#polecenie: powershell.exe
#parametry: -command c:\Programy\MultiPar\par_do_zip.ps1 %WL
#Ważne aby wskazana ścieżka wskazywała na lokalizację tego skryptu. 
#Dodatkowo dla wygody w tej samej lokalizacji umieścić plik wykonywalny PAR2 wiersza poleceń (par2j.exe lub par2j64.exe).
#Strona projektu do pobrania plików PAR2 to https://github.com/Yutaka-Sawada/MultiPar
#W parametrach %WL oznacza przygotowanie pliku będącego listą plików archiwum, które mają być przetworzone przez skrypt.
#Plik umieszczany w katalogu %TEMP% i kasowany po zamknięciu okna skryptu.
#Konieczność takiego działania, gdyż TC niepoprawnie przenosi nazwy ze spacjami czy przecinkami jako parametry do PS

#po dodaniu danych naprawczych archiwum będzie dalej użyteczne, ale będzie większe rozmiarowo o dane naprawcze.
#W przypadku uszkodzenia archiwum otworzyć plik w programie MULTIPAR (jako naprawa, a nie tworzenie)
#MultiPar automatycznie wykryje dane naprawcze i umożliwi naprawę, to jest przywrócenie do oryginalnego pliku, czyli bez danych naprawczych.
#Uwaga!, nie naprawiać poprawnego pliku, gdyż spowoduje to usunięcie danych naprawczych.

######################parametry skryptu, dopasować do własnych potrzeb
#Ścieżka do wiersza poleceń par2
$parPath='c:\programy\MultiPar\par2j64.exe'

#dozwolone rozszerzenia
#w przypadku podstawowych archiwum (zip i 7z) pliki dalej są użyteczne. W przypadku innych plików, dodane na końcu dane mogą powodować niemożność korzystania z takiego pliku. Konieczne indywidualne testy!
$rozszerzenia = @(".zip", ".7z")

#rozmiar danych naprawczych
$redundancja=10

#####################właściwy skrypt

#sprawdzenie czy wymagany plik PAR we wskazanej lokalizacji
if (!(Test-Path $parPath)) {
    #Brak pliku PAR w lokalizacji wskazanej w skrypcie
    #sprawdzenie czy w katalogu ze skryptem znajduje się wymagany plik
    $parPath = $PSScriptRoot+"\par2j64.exe"
    if (!(Test-Path $parPath)) {
        #brak pliku w wersji 64bit, sprawdzanie wersji 32bit
        $parPath = $PSScriptRoot+"\par2j.exe"
        if (!(Test-Path $parPath)) {
            write-host "Nie znaleziono pliku wykonywalnego PAR2." -ForegroundColor Red
            write-host "Umieść go w katalogu ze skryptem, lub wskaż w skrypcie odpowiednią lokalizację." -ForegroundColor Yellow
            Read-Host -Prompt "`nPrzerywanie działania, naciśnij dowolny klawisz."
            exit
        }
    }
} 


#sprawdzenie jaki system aby odpowiednio wyświetlać komunikaty
if ([System.Environment]::OSVersion.Version.Major -lt 11) {
    $blad = "  "+[char][int]"0x2573"
    $ok = "  "+[char][int]"0x221A"
    }
else {
    $blad = "  ❌"
    $ok = "  ✔"
    }

#sprawdzenie czy ścieżka do tymczasowego pliku przekazanego w parametrze istnieje
$plikPliki=$args[0]
if (!(Test-Path $plikPliki)) {
    write-host "Problem z odczytem pliku przekazanego przez TC zawierającego plik to przetworzenia. Przerywanie"
    exit
}
#odczytywanie zawartości pliku tekstowego
$listaPlikow = @(Get-Content $plikPliki)


#ustalenie liczby przekazanych plików
$ile=$listaPlikow.Count

#przejście przez wszystkie pliki z listy
for ($i=0; $i -lt $ile; $i++) {
    $sciezka=$listaPlikow[$i]
	write-host -NoNewline "$($i+1)/$ile $sciezka"
    #sprawdzenie czy plik istnieje. Gdy przecinek w nazwie pliku TC nie przekazuje poprawnie nazwy (zamienia na spację).
    if (!(Test-Path $sciezka)) {
        write-host "$blad - nie odnaleziono pliku." -ForegroundColor Red
        continue
    } 
    #sprawdzanie czy ścieżka jest katalogiem
    if (Test-Path $sciezka -PathType Container) {
        Write-Host "$blad - To jest katalog, pomijanie." -ForegroundColor Gray
        continue
    }
    
    #sprawdzanie czy prawidłowe rozszerzeniu pliku
    $PlikRozszerzenie = [System.IO.Path]::GetExtension($sciezka)
    if ($rozszerzenia -contains $PlikRozszerzenie) { #przetwarzanie pliku
        #sprawdzenie czy plik zawiera dane naprawcze
        $polecenie = 'cmd /c "'+$parPath+'" l '+$sciezka
        $wynik = Invoke-Expression $polecenie
        if ($wynik | Select-String -Pattern "valid file is not found") {
            #plik nie zawiera danych naprawczych. Dodawanie
            $katalog = [System.IO.Path]::GetDirectoryName($sciezka)
            $plik = [System.IO.Path]::GetFileNameWithoutExtension($sciezka)
            $plikPar="$katalog\$plik.par2"
            $polecenie = 'cmd /c "'+$parPath+'" c /sm2048 /rr'+$redundancja+' /rf1 /ri /in /lr32767 /lp4 "'+$plikPar+'" "'+$sciezka+'"'
            $wynik = Invoke-Expression $polecenie
            #Sprawdzanie czy plik (nie) utworzony prawidłowo
            if (!($wynik | Select-String -Pattern "Created successfully")) {
                Write-host "$blad - Błąd tworzenia pliku naprawczego" -ForegroundColor Red
                continue
                }
            #łączenie plików  
            $wynikowyPlikPar="$katalog\$plik.vol_1.par2"
            # Otwieramy pierwszy plik w trybie dodawania (Append) i otwieramy drugi plik w trybie odczytu (Read)
            $firstFileStream = [System.IO.File]::Open($sciezka, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write)
            $secondFileStream = [System.IO.File]::OpenRead($wynikowyPlikPar)

            try {
                #Tworzymy bufor do odczytu danych (np. 4MB)
                $buffer = New-Object byte[] (4MB)
                $bytesRead = 0

                #Dopóki odczytujemy dane z drugiego pliku
                while (($bytesRead = $secondFileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    # Zapisujemy odczytane dane do pierwszego pliku
                    $firstFileStream.Write($buffer, 0, $bytesRead)
                    }
                }
            finally {
                #Zamykamy strumienie, aby zwolnić zasoby
                $firstFileStream.Close()
                $secondFileStream.Close()
                }
            #kasowanie wynikowego pliku PAR
            Remove-Item -Path $wynikowyPlikPar -Force
            Write-Host $ok 
            } 
         else {
            #plik zawiera dane naprawcze pomijanie
            write-host "$blad - Dane naprawcze istnieją" -ForegroundColor DarkYellow
            continue
            }
        }
    else {
    #plik nie posiada właściwego rozszerzenia przejście do następnego pliku
    write-host "$blad - Nieprawidłowy rodzaj pliku" -ForegroundColor Red
    continue
    }
}

Read-Host -Prompt "Press Enter to exit"