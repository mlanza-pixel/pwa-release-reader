Attribute VB_Name = "PWA_Dashboard_v25"
Option Explicit
' 2.5 RC5: Excel <-> Python controller. No developer secrets are stored in the workbook.
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
    picker.Title = "Select YOUR PWA project folder (must contain package.json)"
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
Private Sub RunTool(ByVal command As String)
    Dim sh As Object, proc As Object, path As String, python As String, line As String
    Dim args As String, cmd As String, base As String, current As String, logFile As String
    path = ProjectPath()
    If Len(path) = 0 Or Dir(path, vbDirectory) = "" Then
        MsgBox "Click Choose Project first and pick your actual PWA project folder.", vbExclamation
        Exit Sub
    End If
    python = PythonExe()
    If Len(python) = 0 Then
        MsgBox "Python was not found. Install Python 3 for Windows, close Excel, and reopen it.", vbCritical
        Exit Sub
    End If
    base = ToolkitFolder()
    If Dir(base & "logs", vbDirectory) = "" Then MkDir base & "logs"
    logFile = base & "logs\last_console.txt"
    args = Q(base & "python\pwa_console.py") & " " & command & " --project " & Q(path) & " --output " & Q(base & "logs\last_doctor.json") & " --progress " & Q(base & "logs\progress.txt") & " --status-tsv " & Q(base & "logs\checks.tsv") & " --console-log " & Q(logFile)
    cmd = "python " & args
    ShowState "RUNNING", "Starting " & command & "; results are written to logs."
    Set sh = CreateObject("WScript.Shell")
    On Error GoTo Failed
    Set proc = sh.Exec(cmd)
    Do While proc.Status = 0
        current = ReadProgress(base & "logs\progress.txt")
        If Len(current) > 0 Then ShowState "RUNNING", current
        DoEvents
    Loop
    Dim outputText As String, fOut As Object
    outputText = proc.StdOut.ReadAll & vbCrLf & proc.StdErr.ReadAll
    Set fOut = CreateObject("Scripting.FileSystemObject").CreateTextFile(logFile, True, False)
    fOut.Write outputText
    fOut.Close
    PWA_RefreshResults
    If proc.ExitCode = 0 Then
        ShowState "FINISHED", command & " finished. Review Checks and any WARN items."
    Else
        ShowState "NEEDS ATTENTION", command & " returned exit code " & proc.ExitCode & ". Check logs\last_console.txt"
    End If
    Exit Sub
Failed:
    ShowState "ERROR", "Cannot launch Python: " & Err.Description
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
    ShowState "REFRESHED", "Imported " & rowNum - 3 & " checks. Manual checkpoints are unchanged."
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
