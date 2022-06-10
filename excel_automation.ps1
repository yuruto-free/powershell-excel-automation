# 引数処理
# 書き込むExcel Book
Param(
    [Parameter(Mandatory=$true)]$filename = "sample.xlsx",
    [Parameter(Mandatory=$true)]$listFile = "datalist.txt",
    $relativePath = "."
)

try {
    # 現在のディレクトリを取得
    $currentPath = (Convert-Path $relativePath)
    # テンプレートをコピー
    $templateFile = (Join-Path $currentPath "template.xlsx")
    $excelFile = (Join-Path $currentPath $filename)
    Copy-Item -Path $templateFile -Destination $excelFile -Force

    # Excelの起動
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false      # 画面上に表示させない
    $excel.DisplayAlerts = $true # 警告メッセージは表示する
    # Excel Bookを開く
    $book = $excel.Workbooks.Open($excelFile)

    # 読み込む対象ファイルを逆順で取得
    $lists = @(Get-Content -Path (Join-Path $currentPath $listFile))
    $lists[($lists.Length-1)..0] | ForEach-Object {
        $filepath = $_
        Write-Host $filepath
        # データ取得
        $values = @(Get-Content -Path (Join-Path $currentPath $filepath))

        # 「template」の後ろにシートをコピー
        $templateSheet = $book.Worksheets.item("template")
        $templateSheet.copy([System.Reflection.Missing]::Value, $templateSheet)
        # コピー後のシートを選択・シート名を変更
        $sheet = $book.Sheets($templateSheet.Next.Index)
        $sheet.Name = [System.IO.Path]::GetFileNameWithoutExtension($filepath)
        # 格納先の範囲を指定
        $target = "C3:C{0}" -f (3 + $values.Length - 1)
        # 指定した範囲に値を格納
        $sheet.Range($target).Value2 = $excel.WorksheetFunction.Transpose([double[]]$values)
        # 300ms待機
        Start-Sleep -m 300
    }
    # Excel Bookを保存して閉じる
    $book.Save()
    $excel.Workbooks.Close()
    # Excelの終了
    $excel.Quit()
}
finally {
    # 後処理
    $templateSheet, $sheet, $book, $excel | ForEach-Object{
        if ($null -ne $_) {
            [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($_)
        }
    }
}
