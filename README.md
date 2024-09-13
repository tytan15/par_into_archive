# Język
[English description](english-description)<br>
[Opis w języku polskim](opis-w-jezyku-polskim)

# English description
## Information
As you know, some of the more popular archives (7z and zip) do not support adding recovery data.
I once found a command line script online[^1] that allowed me to add PAR2 recovery data to the above-mentioned archives. Unfortunately, this script had its flaws. Therefore, I decided to rewrite it to PowerShell.
This script is used to run in the TotalCommander environment - after selecting files and using the button on the toolbar.

## Requirements
For correct operation, PAR2 executables are required. They are available on the  project page [MultiPar](https://github.com/Yutaka-Sawada/MultiPar).
You should edit the script and enter your own location of the par2j.exe or par2j64.exe file, alternatively you can place one of these files in the same directory as this script.

Installation
* Choose the language version that suits you.
* Place the script in any location (along with the PAR2 executable).
* In Total Commander, add a new button by setting the following parameters:

   > Command: powershell.exe<br>
   > Parameters: -command c:\PATH_TO_FOLDER\par_into_archive.ps1 %WL

It is important to indicate the correct location of the script file.
The `%WL` parameter causes the paths to all selected files (before using the button) to be saved to a text file, and the path to this file is passed to the script as a parameter. This temporary file is saved in the `%TEMP%` directory and deleted after the script is finished.
The remaining fields fill as you wish.
* If necessary, you can set three parameters inside the script: the path to the par2j64.exe executable file, a list of allowed extensions [^2], the size of the recovery data (default 10%)

# Opis w języku polskim
## Informacje
Jak wiadomo jedne z bardziej popularnych archiwów (7z i zip) nie obsługują dołączania danych naprawczych.
Znalazłem kiedyś w sieci[^3] skrypt wiersza poleceń, dzięki któremu możliwe było dodanie do wspomnianych wyżej archiwów danych naprawczych PAR2. Niestety ten skrypt miał swoje wady. W związku z tym postanowiłem przepisać go do PowerShell.
Skrypt ten wykorzystywany jest do uruchamiania w środowisku TotalCommander - po wskazaniu plików i wybraniu przycisku na pasku narzędziowym.

## Wymagania
Do poprawnego działania konieczne są pliki wykonywalne PAR2. Dostępne są one na stronie projektu [MultiPar](https://github.com/Yutaka-Sawada/MultiPar).
Należy edytować skrypt i wpisać własną lokalizację pliku par2j.exe lub par2j64.exe, alternatywnie można umieścić jeden z tych plików w jednym katalogu z tym skryptem.

## Instalacja
  * Wybierz odpowiednią dla siebie wersję językową.
  * Umieścić skrypt w dowolnej lokalizacji (razem z plikiem wykonywalnym PAR2).
  * W Total Commander dodaj nowy przycisk ustawiając ustawiając następujące parametry:
    
   > Command: powershell.exe<br>
   > Parameters: -command c:\PATH_TO_FOLDER\par_into_archive.ps1 %WL
    
  Ważne aby wskazać prawidłową lokalizację pliku ze skryptem.
  Parametr `%WL` powoduje, że ścieżki do wszystkich zaznaczonych plików (przed wybraniem przycisku) będą zapisane do pliku tekstowego, a ścieżka do tego pliku przekazana do skryptu jako parametr. Ten plik tymczasowy zapisywany jest w katalogu `%TEMP%` i po zakończeniu skryptu kasowany.
    Pozostałe pola według własnego uznania.
* W razie potrzeby wewnątrz skryptu można ustawić trzy parametry: ścieżkę do pliku wykonywalnego par2j64.exe, listę dozwolonych rozszerzeń [^4], wielkość danych naprawczych (domyślnie 10%)
  

# Użytkowanie
W Total Commander wybierz interesujące Cię pliki z archiwami, do których chcesz dodać dane naprawcze. Następnie po wybraniu zdefiniowanego przycisku uruchomiony zostanie skrypt. Dla wskazanych plików sprawdzi czy istnieją już dane naprawcze. Jeżeli tak to kolejne nie będą dodawane. Jeżeli nie to zostanie wygenerowany plik PAR2 z danymi naprawczymi i doklejony na końcu oryginalnego pliku.
Tak powstały plik archiwum jest nadal poprawnie obsługiwany przez popularne programy. Nie "zauważają", że doklejone są dane naprawcze.
W przypadku problemów z otwarciem pliku - gdy został on uszkodzony - należy otworzyć go w programie [MultiPar](https://github.com/Yutaka-Sawada/MultiPar). Po przeskanowaniu pliku zostanie zaproponowana jego naprawa, czyli przywrócenie do stanu oryginalnego gdzie brak jest danych naprawczych.
Z tego względu jeżeli plik nie został uszkodzony nie należy go naprawiać, gdyż spowoduje to usunięcie dołączonych danych naprawczych.

[^1]: I am unable to find it now and name the author, for which I am very sorry
[^2]: Adding recovery data to an archive consists of generating such data and appending it to the end of the actual archive file. In some cases, it may happen that after such appending, the file cannot be used correctly. In the case of `*.zip` and `*.7z` files, they can be used normally. No program reported errors. This does not mean that recovery data cannot be added to other files. It is necessary to conduct tests in this area.
[^3]: Nie jestem w stanie teraz go odnaleźć i wymienić autora, za co bardzo przepraszam.
[^4]: Dodawanie danych naprawczych do archiwum polega na wygenerowaniu takich danych i doklejeni ich na końcu właściwego pliku archiwum. W niektórych przypadkach może się zdarzyć, że po takim doklejeniu plik nie może być prawidłowo użytkowany. W przypadku plików `*.zip` oraz `*.7z` mogą one być normalnie użytkowane. Żaden program nie zgłaszał błędów. Nie znaczy to, że do innych plików nie mogą być dodane dane naprawcze. Konieczna jest wykonanie w tym kierunku testów.
