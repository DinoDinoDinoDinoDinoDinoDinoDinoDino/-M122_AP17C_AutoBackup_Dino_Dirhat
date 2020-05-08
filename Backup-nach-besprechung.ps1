#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@
#
#clean code backup von Dino nach besprechung
#
#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@#@


#Kopiert nach gewählter Ordner
$Destination="C:\Users\Beast\Desktop\backup" 
#Welche Ordner gebackupt werden sollten
$BackupDirs="C:\Users\Beast\Desktop\Start" 
#wie viele backups von dem user behaltet werden wollen dies ist auf default 9
$Versions="9" 
#Erstellt pfad ... Backup ordner wird erstellt in angebenen Ziel ordner 
#ind em Ordner PFad wird zusätzlich hinzugefügt: ein datum in tag - monat - jahr format und eine zufällige nummer, welche als Backup:"ID" gilt
$Backupdir=$Destination +"\Backup-Dino-Dirhart"+ (Get-Date -format dd-MM-yyyy)+"-"+(Get-Random -Maximum 9999)+"\"
#Variablen welch eich brauche für ienen Progress baar
$Items=0
$Count=0
#Create-Backupdir Funktion... gibt dem User aus, wie dass der Prozess startet
Function Create-Backupdir {
    Write-Host "ERSTELLE AUTOBACK VON DINO UMIKER" $Backupdir
    New-Item -Path $Backupdir -ItemType Directory | Out-Null
}
 
#löscht alte Version des Backups
#dies passiert falls mehr als 9 Versionen bereits exisiteren
#gibt dem Usder bescheid falls dies eintreifft
Function Delete-Backupdir {
    Write-Host "ALTES BACKUP LÖSCHEN"
    $Delete=$Count-$Versions+1
    Get-ChildItem $Destination -Directory | Sort-Object -Property $_.LastWriteTime -Descending  | Select-Object -First $Delete | Remove-Item -Recurse -Force
}
 
#Überprüft korrekt ob pfade vorhanden sind gilt für start und end path
function Check-Dir {
    if (!(Test-Path $BackupDirs)) {
        return $false
    }
    if (!(Test-Path $Destination)) {
        return $false
    }
}
 
#Erstellt backup und sichert die Files ab
#in diesem Process wird auch de Progresssbar angezeigt
Function Make-Backup {
    $Files=@()
    $SumItem=0
	#"berechnung" für progressbar
    foreach ($Backup in $BackupDirs) {
        $colItems = (Get-ChildItem $Backup -recurse | Measure-Object -property length -sum) 
        $Items=0
        $FilesCount += Get-ChildItem $Backup -Recurse | Where-Object {$_.mode -notmatch "h"}  
        Copy-Item -Path $Backup -Destination $Backupdir -Force -ErrorAction SilentlyContinue
        $SumItem+=$colItems.Sum.ToString()
        $SumItems+=$colItems.Count
    }
	#nachricht an den user den eigentlichen Progressbar
    $TotalMB="{0:N2}" -f ($SumItem / 1MB) + " MB von Files"
    Write-Host "Es werden"$TotalMB "kopiert und es sind noch:"$filesCount.Count "Files zu kopieren"
	#eigneltiche backup wird hier ausgeführt
	#Hauptprocess: Hier wird kopiert
	##########################################################
    foreach ($Backup in $BackupDirs) {
        $Index=$Backup.LastIndexOf("\")
        $SplitBackup=$Backup.substring(0,$Index)
        $Files = Get-ChildItem $Backup -Recurse | Where-Object {$_.mode -notmatch "h"} 
        foreach ($File in $Files) {
            $restpath = $file.fullname.replace($SplitBackup,"")
            Copy-Item  $file.fullname $($Backupdir+$restpath) -Force -ErrorAction SilentlyContinue |Out-Null
			#Hier wird dem User ausgebeben wie weit das Kopieren ist.
            $Items += (Get-item $file.fullname).Length
            $status = "Kopier Files {0} von {1} und es wurde kopiert: {3} MB of {4} MB: {2}" -f $count,$filesCount.Count,$file.Name,("{0:N2}" -f ($Items / 1MB)).ToString(),("{0:N2}" -f ($SumItem / 1MB)).ToString()
            $Text="DateinOrt... {0} of {1}" -f $BackupDirs.Rank ,$BackupDirs.Count
            Write-Progress -Activity $Text $status -PercentComplete ($Items / $SumItem*100)  
            $count++
        }
    }
    $SumCount+=$Count
	#Ende Des Backup als nachricht für user lesbar
    Write-Host "BACKUP-ED" $SumCount "Alle FILES IN ORDNER" ("{0:N2}" -f ($Items / 1MB)).ToString()" MB"
}
 
#Schaut ob Backup version vorhanden ist und bereinigt falls nötig
$Count=(Get-ChildItem $Destination -Directory).count
if ($count -lt $Versions) {
    Create-Backupdir
} else {
    Delete-Backupdir
    Create-Backupdir
}
 
#Abfangung Gültigkeit aller Benötigten Vairablen Pfade
$CheckDir=Check-Dir
if ($CheckDir -eq $false) {
    Write-Host "FEHLER! PFADE NICHT GEFUNDEN! BESSER KORREKT EINGEBEN!!!"
} else {
    Make-Backup
	 Write-Host "BACKUO WIRD ERSTELLT"
}

#alternative für erneut backupen button
 
Write-Host "BACKUP WURDE ERSTEL FÜHRE ERNEUT AUS UM NEUES BACKUP ZU ERSTELLEN."
 
