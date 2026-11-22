Attribute VB_Name = "PWA_Dashboard_v25"
Option Explicit
' 2.5 RC13: Excel <-> Python controller. No developer secrets are stored in the workbook.
Private Const DASH As String = "Dashboard"
Private Const RESULT As String = "Checks"

Private Function ToolkitFolder() As String
    ToolkitFolder = ThisWorkbook.Path & Application.PathSeparator
End Function
Private Function Q(ByVal value As String) As String
    Q = Chr(34) & Replace(value, Chr(34), "") & Chr(34)
End Function
Private Function ProjectPath() As String
    ProjectPath = Trim$(CStr(ThisWorkbook.Worksheets(DASH).Range("B5").Value))
End Function
Private Sub ShowState(ByVal state As String, ByVal detail As String)
    With ThisWorkbook.Worksheets(DASH)
        .Range("B6").Value = state
        .Range("B7").Value = detail
        .Range("B8").Value = Now
    End With
    Application.StatusBar = "PWA Toolkit: " & detail
    DoEvents
End Sub
Public Sub PWA_SelectProject()
    Dim picker As FileDialog
    Set picker = Application.FileDialog(msoFileDialogFolderPicker)
    picker.Title = "Select YOUR PWA project folder (may contain index.html or package.json)"
    If picker.Show <> -1 Then Exit Sub
    ThisWorkbook.Worksheets(DASH).Range("B5").Value = picker.SelectedItems(1)
    ShowState "SELECTED", "Project selected. Click Run Doctor."
End Sub
Private Function PythonExe() As String
    Dim sh As Object, rc As Long
    Set sh = CreateObject("WScript.Shell")
    On Error GoTo NoPython
    rc = sh.Run("cmd.exe /d /c where python >nul 2>nul", 0, True)
    If rc = 0 Then PythonExe = "python" Else PythonExe = ""
    Exit Function
NoPython:
    PythonExe = ""
End Function
Private Function ReadProgress(ByVal name As String) As String
    Dim fso As Object, f As Object, line As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(name) Then Exit Function
    On Error GoTo CleanExit
    Set f = fso.OpenTextFile(name, 1, False, -2)
    If Not f.AtEndOfStream Then line = f.ReadLine
    ReadProgress = line
CleanExit:
    On Error Resume Next
    If Not f Is Nothing Then f.Close
End Function
Private Function ReadFirstLine(ByVal filePath As String) As String
    Dim fso As Object, f As Object
    On Error GoTo FailedRead
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(filePath) Then Exit Function
    Set f = fso.OpenTextFile(filePath, 1, False, -2)
    If Not f.AtEndOfStream Then ReadFirstLine = Trim$(f.ReadLine)
    f.Close
    Exit Function
FailedRead:
    ReadFirstLine = ""
End Function

Private Sub RunTool(ByVal command As String)
    Dim sh As Object, fso As Object, base As String, proj As String
    Dim bat As String, rcFile As String, stateFile As String, startupLog As String
    Dim started As Date, statusText As String, rcText As String, runCmd As String
    On Error GoTo Failed
    base = ToolkitFolder()
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(base & "logs") Then fso.CreateFolder base & "logs"
    startupLog = base & "logs\excel_launch.log"
    Set sh = CreateObject("WScript.Shell")
    Dim f As Object
    Set f = fso.OpenTextFile(startupLog, 8, True)
    f.WriteLine Format$(Now, "yyyy-mm-dd hh:nn:ss") & " Start " & command
    f.Close
    proj = ProjectPath()
    If Len(proj) = 0 Or Not fso.FolderExists(proj) Then
        ShowState "FAILED", "Choose an existing PWA project folder first. See logs\excel_launch.log"
        Set f = fso.OpenTextFile(startupLog, 8, True)
        f.WriteLine "FAIL: Missing or nonexistent project folder"
        f.Close
        MsgBox "Click Choose Project and select your PWA folder. A startup log was written to logs\excel_launch.log", vbExclamation
        Exit Sub
    End If
    bat = base & "RUN_DOCTOR_STEP_BY_STEP.bat"
    If Not fso.FileExists(bat) Then
        ShowState "FAILED", "Missing RUN_DOCTOR_STEP_BY_STEP.bat - extract the entire ZIP"
        Set f = fso.OpenTextFile(startupLog, 8, True)
        f.WriteLine "FAIL: Missing runner batch file"
        f.Close
        Exit Sub
    End If
    rcFile = base & "logs\exit_code.txt"
    stateFile = base & "logs\run_state.txt"
    If fso.FileExists(rcFile) Then fso.DeleteFile rcFile, True
    If fso.FileExists(stateFile) Then fso.DeleteFile stateFile, True
    ShowState "RUNNING", "Step 1: Starting Windows checks; see logs\startup_doctor.log"
    runCmd = Q(bat) & " " & Q(proj) & " " & command
    Set f = fso.OpenTextFile(startupLog, 8, True)
    f.WriteLine "Launching safe diagnostic runner; no credentials passed"
    f.Close
    sh.Run runCmd, 1, False
    started = Now
    Do
        DoEvents
        rcText = ReadFirstLine(rcFile)
        statusText = ReadFirstLine(stateFile)
        If Len(statusText) > 0 Then ShowState "RUNNING", statusText
        If Len(rcText) > 0 Then Exit Do
        If DateDiff("s", started, Now) > 300 Then
            ShowState "TIMEOUT", "No finish signal after 5 minutes. See logs\startup_doctor.log"
            Set f = fso.OpenTextFile(startupLog, 8, True)
            f.WriteLine "TIMEOUT: No exit code file after 300 seconds"
            f.Close
            Exit Sub
        End If
    Loop
    If fso.FileExists(base & "logs\checks.tsv") Then PWA_RefreshResults
    PWA_ImportRunLogs
    If rcText = "0" Then
        ShowState "FINISHED", "Run completed; review Checks for warnings and results"
    Else
        ShowState "NEEDS ATTENTION", "Run returned code " & rcText & ". Open logs\startup_doctor.log"
    End If
    Application.StatusBar = False
    Exit Sub
Failed:
    On Error Resume Next
    ShowState "ERROR", "Could not launch diagnostics. Open logs\excel_launch.log"
    Set f = fso.OpenTextFile(startupLog, 8, True)
    f.WriteLine "ERROR: " & Err.Number & " " & Err.Description
    f.Close
    Application.StatusBar = False
End Sub
Public Sub PWA_RunDoctor()
    RunTool "doctor"
End Sub
Public Sub PWA_PrepareSafety()
    If MsgBox("This adds missing credential-protection patterns to the selected project's .gitignore file. Continue?", vbYesNo + vbQuestion) <> vbYes Then Exit Sub
    RunTool "prepare"
End Sub
Public Sub PWA_RefreshResults()
    Dim fso As Object, f As Object, line As String, cols As Variant
    Dim ws As Worksheet, rowNum As Long, base As String
    base = ToolkitFolder()
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FileExists(base & "logs\checks.tsv") Then
        ShowState "NOT RUN", "No results yet. Run Doctor to create results."
        Exit Sub
    End If
    Set ws = ThisWorkbook.Worksheets(RESULT)
    ws.Range("A3:D150").ClearContents
    Set f = fso.OpenTextFile(base & "logs\checks.tsv", 1, False, -2)
    rowNum = 3
    If Not f.AtEndOfStream Then line = f.ReadLine ' Header
    Do While Not f.AtEndOfStream And rowNum <= 150
        line = f.ReadLine
        cols = Split(line, vbTab)
        If UBound(cols) >= 3 Then
            ws.Cells(rowNum, 1).Value = cols(0)
            ws.Cells(rowNum, 2).Value = cols(1)
            ws.Cells(rowNum, 3).Value = cols(2)
            ws.Cells(rowNum, 4).Value = cols(3)
            rowNum = rowNum + 1
        End If
    Loop
    f.Close
    ThisWorkbook.Worksheets(DASH).Range("B9").Value = rowNum - 3
    PWA_UpdateSummary
    PWA_ImportRunLogs
    ShowState "REFRESHED", "Imported " & rowNum - 3 & " checks; updated summary and Run Log."
End Sub
Public Sub PWA_OpenInstructions()
    ThisWorkbook.FollowHyperlink ToolkitFolder() & "START_HERE_COOKBOOK_v2_5.md"
End Sub
Public Sub PWA_OpenApple()
    ThisWorkbook.FollowHyperlink "https://developer.apple.com/account/"
End Sub
Public Sub PWA_OpenGoogle()
    ThisWorkbook.FollowHyperlink "https://play.google.com/console/"
End Sub

Public Sub PWA_OpenLogs()
    Dim folder As String
    folder = ToolkitFolder() & "logs"
    If Dir(folder, vbDirectory) = "" Then MkDir folder
    CreateObject("WScript.Shell").Run "explorer.exe " & Q(folder), 1, False
End Sub

Public Sub PWA_CheckGitHubReadiness()
    RunTool "github-check"
End Sub
Public Sub PWA_OpenGitHubNew()
    ThisWorkbook.FollowHyperlink "https://github.com/new"
End Sub
Public Sub PWA_OpenUploadGuide()
    ThisWorkbook.FollowHyperlink ToolkitFolder() & "GITHUB_FIRST_UPLOAD_COOKBOOK_RC7.md"
End Sub

' ---------- RC13: summary and run history, separate from manual notes ----------
Public Sub PWA_UpdateSummary()
    Dim ws As Worksheet, dash As Worksheet, r As Long, lastRow As Long, v As String
    Dim p As Long, w As Long, f As Long
    Set ws = ThisWorkbook.Worksheets("Checks")
    Set dash = ThisWorkbook.Worksheets("Dashboard")
    lastRow = ws.Cells(ws.Rows.Count, 2).End(xlUp).Row
    For r = 3 To lastRow
        v = UCase$(Trim$(CStr(ws.Cells(r, 3).Value)))
        Select Case v
            Case "PASS": p = p + 1
            Case "WARN": w = w + 1
            Case "FAIL": f = f + 1
        End Select
    Next r
    dash.Range("C5:E5").Value = Array("PASS", "WARN", "FAIL")
    dash.Range("C6").Value = p
    dash.Range("D6").Value = w
    dash.Range("E6").Value = f
    dash.Range("C7:E7").Value = Array("Latest imported", "Latest imported", "Latest imported")
End Sub

Private Sub AppendFileToLog(ByVal ws As Worksheet, ByVal filePath As String, ByVal heading As String, ByRef outRow As Long)
    Dim fso As Object, ff As Object, line As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    ws.Cells(outRow, 11).Value = heading
    outRow = outRow + 1
    If Not fso.FileExists(filePath) Then
        ws.Cells(outRow, 11).Value = "Not available: " & filePath
        outRow = outRow + 2
        Exit Sub
    End If
    On Error GoTo ErrorRead
    Set ff = fso.OpenTextFile(filePath, 1, False, -2)
    Do While Not ff.AtEndOfStream And outRow < 3000
        line = ff.ReadLine
        ws.Cells(outRow, 11).Value = Left$(line, 32000)
        outRow = outRow + 1
    Loop
    ff.Close
    outRow = outRow + 2
    Exit Sub
ErrorRead:
    ws.Cells(outRow, 11).Value = "Unable to read file: " & Err.Description
    On Error Resume Next
    If Not ff Is Nothing Then ff.Close
    outRow = outRow + 2
End Sub

Public Sub PWA_ImportRunLogs()
    Dim ws As Worksheet, folder As String, fso As Object, ff As Object, line As String
    Dim parts As Variant, r As Long, k As Long, outRow As Long
    On Error GoTo FailedImport
    folder = ToolkitFolder() & "logs\"
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set ws = ThisWorkbook.Worksheets("Run Log")
    ws.Range("A4:I2000").ClearContents
    ws.Range("K4:K3000").ClearContents
    If fso.FileExists(folder & "run_history.tsv") Then
        Set ff = fso.OpenTextFile(folder & "run_history.tsv", 1, False, -2)
        If Not ff.AtEndOfStream Then line = ff.ReadLine
        r = 4
        Do While Not ff.AtEndOfStream And r <= 2000
            line = ff.ReadLine
            parts = Split(line, vbTab)
            If UBound(parts) >= 8 Then
                For k = 0 To 8
                    ws.Cells(r, k + 1).Value = parts(k)
                Next k
                r = r + 1
            End If
        Loop
        ff.Close
    Else
        ws.Range("A4").Value = "No archived runs yet. Run Doctor or Prepare Safety."
    End If
    outRow = 4
    ' Show preserved logs from earlier runs, not just the most recent result.
    Dim archiveFolder As String, hr As Long, lastHistoryRow As Long
    lastHistoryRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For hr = 4 To lastHistoryRow
        archiveFolder = Trim$(CStr(ws.Cells(hr, 9).Value))
        If Len(archiveFolder) > 0 Then
            AppendFileToLog ws, archiveFolder & "\console.txt", "ARCHIVED RUN " & ws.Cells(hr, 1).Value & " / " & ws.Cells(hr, 3).Value, outRow
        End If
    Next hr
    AppendFileToLog ws, folder & "last_console.txt", "LATEST PYTHON CONSOLE", outRow
    AppendFileToLog ws, folder & "startup_doctor.log", "WINDOWS STARTUP LOG", outRow
    AppendFileToLog ws, folder & "excel_launch.log", "EXCEL LAUNCH LOG", outRow
    AppendFileToLog ws, folder & "BUILD_MACRO_DASHBOARD_RC13.log", "EXCEL BUILDER LOG", outRow
    Exit Sub
FailedImport:
    On Error Resume Next
    ThisWorkbook.Worksheets("Dashboard").Range("B7").Value = "Run Log import issue: " & Err.Description
End Sub

Public Sub PWA_OpenRunLog()
    PWA_ImportRunLogs
    ThisWorkbook.Worksheets("Run Log").Activate
End Sub
