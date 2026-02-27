# --- CONFIGURAZIONE PERCORSI ---
$excelPath = "\\10.10.10.200\export\ING90DAT\giacenze_isolpack.xlsx"
$outputFolder = "C:\Varie\Inventario\github\data"

# --- DEFINIZIONE COLONNE ---
$colsCoperturaParete = @("Isolante","Altezza","SP_EST","SP_INT","Cod_Colore_EST","Colore_EST","Cod_Colore_INT","Colore_INT","Modello","Lunghezza","Quantita_1","UM_1","Quantita_2","UM_2","Unita_locale","Descrizione","Articolo")
$colsPolicarbonati  = @("Articolo","Descrizione","Unita_locale","UM_1","Quantita_1","UM_2","Quantita_2","Modello","Extramodello","Modulo","Spessore","Colore","ProtezioneUV","Lunghezza")
$colsGrecate        = @("Modello","Tipo_Materiale","Cod_Colore","Colore","Spessore","Lunghezza","Quantita_1","UM_1","Quantita_2","UM_2","Unita_locale","Lavorazione","Anticondensa","Descrizione","Articolo","Cod_Materiale")

$mappaFogli = [ordered]@{
    "Copertura"     = $colsCoperturaParete
    "Parete"        = $colsCoperturaParete
    "Policarbonati" = $colsPolicarbonati
    "Lam Grecate"   = $colsGrecate
}

if (!(Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder }

foreach ($entry in $mappaFogli.GetEnumerator()) {
    $nomeFoglio = $entry.Key
    $colonne = $entry.Value
    
    Write-Host "---"
    Write-Host "Elaborazione foglio: ${nomeFoglio}..." -ForegroundColor Cyan
    
    try {
        # Import-Excel con Header personalizzati per saltare i duplicati dell'originale
        $data = Import-Excel -Path $excelPath -WorksheetName $nomeFoglio -StartRow 2 -HeaderName $colonne
        
        if ($data) {
            # Filtro: Escludi righe dove l'Articolo è vuoto (pulisce il fondo del file)
            $dataPulita = $data | Where-Object { $_.Articolo -ne $null -and $_.Articolo -ne "" }
            
            # Formattazione nome file per GitHub
            $fileName = $nomeFoglio.Replace(" ", "_").ToLower() + ".json"
            
            # Esporta in JSON
            $dataPulita | ConvertTo-Json -Depth 10 | Out-File -FilePath "$outputFolder\$fileName" -Encoding utf8
            Write-Host "✅ Generato $fileName con $($dataPulita.Count) righe." -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Errore nel foglio ${nomeFoglio}:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Gray
    }
}

Write-Host "`n🚀 Procedura completata correttamente!" -ForegroundColor Green