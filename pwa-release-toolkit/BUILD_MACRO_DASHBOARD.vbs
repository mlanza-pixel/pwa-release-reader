Option Explicit
' PWA Toolkit v2.5 RC13: diagnostic Excel macro dashboard builder.
' Source workbook preferred; safe reconstruction fallback if Excel refuses to open it.
Dim fso, shell, base, inputFile, moduleFile, outputFile, backupFile, logFile
Dim excel, wb, vbComp, s, names, actions, i, sh, buttonRow, buttonWidth, buttonHeight, shp
Dim detail, usedFallback, f, startDir
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
base = fso.GetParentFolderName(WScript.ScriptFullName)
inputFile = fso.BuildPath(base, "PWA_Release_Toolkit_v2.5.xlsx")
moduleFile = fso.BuildPath(base, "vba\PWA_Dashboard_v2_5_RC13.bas")
backupFile = fso.BuildPath(base, "DASHBOARD_FALLBACK_RC13.tsv")
outputFile = fso.BuildPath(base, "PWA_Release_Toolkit_v2.5_RC13.xlsm")
If Not fso.FolderExists(fso.BuildPath(base, "logs")) Then fso.CreateFolder fso.BuildPath(base, "logs")
logFile = fso.BuildPath(base, "logs\BUILD_MACRO_DASHBOARD_RC13.log")
Sub Log(msg)
  Dim stream
  WScript.Echo msg
  Set stream = fso.OpenTextFile(logFile, 8, True)
  stream.WriteLine Now & " | " & msg
  stream.Close
End Sub
Sub Fatal(code, msg)
  Log "ERROR: " & msg
  On Error Resume Next
  If Not wb Is Nothing Then wb.Close False
  If Not excel Is Nothing Then excel.Quit
  WScript.Quit code
End Sub
Set wb = Nothing
Set excel = Nothing
Log "[1/8] RC13 builder started. Toolkit folder: " & base
If Not fso.FileExists(moduleFile) Then Fatal 2, "VBA module missing: " & moduleFile
If Not fso.FileExists(inputFile) Then Fatal 2, "Source workbook missing: " & inputFile
If Not fso.FileExists(backupFile) Then Fatal 2, "Recovery data missing: " & backupFile
Log "[2/8] Input workbook found (" & fso.GetFile(inputFile).Size & " bytes)."
If fso.FileExists(outputFile) Then
  ' Preserve user-edited workbook; do not silently overwrite.
  Fatal 2, "Output already exists. Rename/move this workbook before rebuilding: " & outputFile
End If
On Error Resume Next
Set excel = CreateObject("Excel.Application")
If Err.Number <> 0 Or excel Is Nothing Then
  detail = Err.Description: Err.Clear
  Fatal 2, "Excel Desktop could not start: " & detail
End If
Err.Clear
excel.Visible = False
excel.DisplayAlerts = False
excel.AskToUpdateLinks = False
excel.AutomationSecurity = 3
Log "[3/8] Excel started. Trying to open original dashboard..."
Set wb = excel.Workbooks.Open(inputFile, 0, False)
If Err.Number <> 0 Or wb Is Nothing Then
  detail = Err.Description: Err.Clear
  Log "WARN: Excel could not open the template: " & detail
  Log "[4/8] Trying offline dashboard reconstruction from packaged data."
  Set wb = Nothing
  Set wb = excel.Workbooks.Add()
  If Err.Number <> 0 Or wb Is Nothing Then Fatal 3, "Could not create a new Excel workbook: " & Err.Description
  Err.Clear
  RebuildFromBackup wb, backupFile
  If Err.Number <> 0 Then Fatal 3, "Backup reconstruction failed: " & Err.Description
  usedFallback = True
  Log "PASS: Recovery workbook created. Original template formatting may differ."
Else
  usedFallback = False
  Log "[4/8] Source workbook opened successfully."
End If
Err.Clear
Log "[5/8] Importing VBA module (requires Excel Trust access to VBA project object model)."
Set vbComp = wb.VBProject.VBComponents.Import(moduleFile)
If Err.Number <> 0 Or vbComp Is Nothing Then
  detail = Err.Description: Err.Clear
  Fatal 4, "VBA import was blocked: " & detail & ". In Excel: File > Options > Trust Center > Trust Center Settings > Macro Settings > Trust access to VBA project object model; enable only while building."
End If
Log "PASS: VBA module imported."
On Error GoTo 0
On Error Resume Next
Set s = wb.Worksheets("Run Log")
If s Is Nothing Then
  Set s = wb.Worksheets.Add(,wb.Worksheets(wb.Worksheets.Count))
  s.Name = "Run Log"
  s.Range("A1").Value = "RUN HISTORY AND DIAGNOSTIC OUTPUT - v2.5 RC13"
  s.Range("A3:I3").Value = Array("RUN ID","UTC START","MODE","PASS","WARN","FAIL","EXIT","PROJECT","ARCHIVE")
  s.Range("K3").Value = "LATEST CONSOLE / WINDOWS STARTUP / EXCEL LAUNCH / BUILDER LOG"
  s.Columns("A").ColumnWidth=34
  s.Columns("B").ColumnWidth=30
  s.Columns("C:G").ColumnWidth=12
  s.Columns("H:I").ColumnWidth=46
  s.Columns("K").ColumnWidth=105
End If
Set s = Nothing
On Error GoTo 0
Set s = wb.Worksheets("Dashboard")
names = Array("1. Choose Project", "2. Run Doctor", "3. Prepare Safety", "4. Refresh Results", "5. Open Instructions", "6. Open Logs", "7. Check GitHub Readiness", "8. Open GitHub", "9. Upload Cookbook", "10. View Run Log")
actions = Array("PWA_SelectProject", "PWA_RunDoctor", "PWA_PrepareSafety", "PWA_RefreshResults", "PWA_OpenInstructions", "PWA_OpenLogs", "PWA_CheckGitHubReadiness", "PWA_OpenGitHubNew", "PWA_OpenUploadGuide", "PWA_OpenRunLog")
Log "[6/8] Creating ten dashboard buttons at A12, A14, ... A30."
For i = s.Shapes.Count To 1 Step -1
  Set shp = s.Shapes(i)
  If Left(shp.Name, 10) = "PWAButton_" Then shp.Delete
Next
s.Range("A10").ClearContents
s.Range("A11").Value = "BUTTON"
s.Range("B11").Value = "ACTION / EXPECTED RESULT"
s.Columns("A").ColumnWidth = 29
s.Columns("B").ColumnWidth = 72
For i = 0 To 9
  buttonRow = 12 + i * 2
  s.Rows(buttonRow).RowHeight = 46
  s.Rows(buttonRow + 1).RowHeight = 16
  s.Range("B" & buttonRow).WrapText = True
  buttonWidth = s.Range("A" & buttonRow).Width - 10
  buttonHeight = s.Range("A" & buttonRow).Height - 8
  Set sh = s.Shapes.AddShape(5, s.Range("A" & buttonRow).Left + 4, s.Range("A" & buttonRow).Top + 4, buttonWidth, buttonHeight)
  sh.Name = "PWAButton_" & CStr(i + 1)
  sh.TextFrame.Characters.Text = names(i)
  sh.TextFrame.Characters.Font.Size = 10
  sh.TextFrame.Characters.Font.Bold = True
  sh.TextFrame.HorizontalAlignment = -4108
  sh.TextFrame.VerticalAlignment = -4108
  sh.OnAction = "'" & fso.GetFileName(outputFile) & "'!" & actions(i)
Next
Log "[7/8] Saving macro-enabled workbook..."
On Error Resume Next
wb.SaveAs outputFile, 52
If Err.Number <> 0 Then
  detail=Err.Description:Err.Clear
  Fatal 5, "Excel SaveAs failed: " & detail
End If
wb.Close False
excel.Quit
On Error GoTo 0
If Not fso.FileExists(outputFile) Then Fatal 5, "Excel returned without creating output workbook"
Log "[8/8] SUCCESS: " & outputFile
If usedFallback Then Log "NOTICE: Recovery was used; check layout, clickable links and data before relying on this workbook."
Log "Open the XLSM in Excel Desktop. Macros are disabled until you explicitly enable them."

Sub RebuildFromBackup(workbook, path)
  Dim stream, line, chunks, current, sheetNo, j, c, val, kind, name
  Set stream = fso.OpenTextFile(path, 1, False, -1)
  Set current = Nothing
  sheetNo = 0
  Do While Not stream.AtEndOfStream
    line = stream.ReadLine
    If Len(line) > 0 And Left(line,1) <> ChrW(&HFEFF) Then
      chunks = Split(line, vbTab)
      If chunks(0) = "S" Then
        sheetNo=sheetNo+1
        name=chunks(1)
        If sheetNo <= workbook.Worksheets.Count Then
          Set current = workbook.Worksheets(sheetNo)
        Else
          Set current = workbook.Worksheets.Add(,workbook.Worksheets(workbook.Worksheets.Count))
        End If
        current.Name=name
      ElseIf chunks(0) = "C" Then
        If UBound(chunks) >= 3 Then
          val=chunks(3)
          val=Replace(val,"%09", vbTab)
          val=Replace(val,"%0A",vbLf)
          val=Replace(val,"%0D",vbCr)
          val=Replace(val,"%25","%")
          kind=chunks(2)
          Set c=current.Range(chunks(1))
          If kind="F" Then
            c.Formula=val
          ElseIf kind="N" Then
            If IsNumeric(val) Then c.Value=CDbl(val) Else c.Value=val
          Else
            c.Value=val
          End If
        End If
      End If
    End If
  Loop
  stream.Close
  Do While workbook.Worksheets.Count > sheetNo
    workbook.Worksheets(workbook.Worksheets.Count).Delete
  Loop
  Dim d
  Set d=workbook.Worksheets("Dashboard")
  d.Columns("A").ColumnWidth=29
  d.Columns("B").ColumnWidth=72
  d.Range("A1:D1").Interior.Color=RGB(24,49,83)
  d.Range("A1:D1").Font.Color=RGB(255,255,255)
  d.Range("A11:B11").Interior.Color=RGB(24,49,83)
  d.Range("A11:B11").Font.Color=RGB(255,255,255)
  d.Range("A11:B11").Font.Bold=True
  For j=12 To 30 Step 2
    d.Rows(j).RowHeight=46
    d.Rows(j+1).RowHeight=16
    d.Range("B" & j).WrapText=True
  Next
End Sub
