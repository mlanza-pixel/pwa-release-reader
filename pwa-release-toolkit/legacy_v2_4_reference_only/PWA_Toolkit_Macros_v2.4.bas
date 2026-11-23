Attribute VB_Name = "PWAToolkit"
Option Explicit

' ============================================================
' PWA Release Toolkit - VBA Macros
' ============================================================
' To install: Press Alt+F11 in Excel, then File > Import File,
' select this .bas file. Save the workbook. Done!
' ============================================================

' Open a file in its default application
Public Sub OpenFile(filePath As String)
    On Error GoTo ErrHandler
    Dim fullPath As String
    fullPath = ThisWorkbook.Path & "\" & filePath
    Shell "cmd /c start """" """ & fullPath & """", vbNormalFocus
    Exit Sub
ErrHandler:
    MsgBox "Could not open: " & fullPath & vbCrLf & _
           "Error: " & Err.Description, vbExclamation, "Open File"
End Sub

' Run a .bat file in a new CMD window (stays open)
Public Sub RunBat(filePath As String)
    On Error GoTo ErrHandler
    Dim fullPath As String
    fullPath = ThisWorkbook.Path & "\" & filePath
    Shell "cmd /k """ & fullPath & """", vbNormalFocus
    Exit Sub
ErrHandler:
    MsgBox "Could not run: " & fullPath & vbCrLf & _
           "Error: " & Err.Description, vbExclamation, "Run Bat"
End Sub

' Run doctor.bat diagnostic
Public Sub RunDoctor()
    RunBat "bat_files\doctor.bat"
End Sub

' Run deploy.bat
Public Sub RunDeploy()
    RunBat "bat_files\deploy.bat"
End Sub

' Run generate_apple_keys.bat
Public Sub RunAppleKeys()
    RunBat "bat_files\generate_apple_keys.bat"
End Sub

' Run generate_android_keystore.bat
Public Sub RunAndroidKeys()
    RunBat "bat_files\generate_android_keystore.bat"
End Sub

' Run encode_base64.bat
Public Sub RunBase64()
    RunBat "bat_files\encode_base64.bat"
End Sub

' Open capacitor.config.json
Public Sub OpenCapacitor()
    OpenFile "config_files\capacitor.config.json"
End Sub

' Open .gitignore
Public Sub OpenGitignore()
    OpenFile "config_files\.gitignore"
End Sub

' Open build-ios.yml
Public Sub OpenIOSWorkflow()
    OpenFile "workflow_files\build-ios.yml"
End Sub

' Open build-android.yml
Public Sub OpenAndroidWorkflow()
    OpenFile "workflow_files\build-android.yml"
End Sub

' Open PRIVACY.md
Public Sub OpenPrivacy()
    OpenFile "templates\PRIVACY.md"
End Sub

' Open manifest.json
Public Sub OpenManifest()
    OpenFile "templates\manifest.json"
End Sub

' Open sw.js
Public Sub OpenSW()
    OpenFile "templates\sw.js"
End Sub

' Open github_secrets_checklist.txt
Public Sub OpenSecretsChecklist()
    OpenFile "text_files\github_secrets_checklist.txt"
End Sub

' Open preflight_checklist.txt
Public Sub OpenPreflight()
    OpenFile "text_files\preflight_checklist.txt"
End Sub

' Count completed steps
Public Sub CountDone()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Command Guide")
    Dim doneCount As Integer
    Dim totalCount As Integer
    doneCount = 0
    totalCount = 0
    Dim r As Integer
    For r = 5 To 100
        If ws.Cells(r, 1).Value <> "" Then
            totalCount = totalCount + 1
            Dim val As String
            val = UCase(Trim(ws.Cells(r, 7).Value))
            If val = "X" Or val = "DONE" Or val = "Y" Or val = "YES" Then
                doneCount = doneCount + 1
            End If
        End If
    Next r
    MsgBox doneCount & " out of " & totalCount & " steps completed." & vbCrLf & _
           IIf(doneCount = totalCount, "All done! You are ready to ship!", _
               (totalCount - doneCount) & " steps remaining."), _
           vbInformation, "Progress Tracker"
End Sub

' Open README
Public Sub OpenREADME()
    OpenFile "README.md"
End Sub
