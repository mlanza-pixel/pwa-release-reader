Option Explicit
Dim fso, shell, base, inputFile, moduleFile, outputFile, excel, wb, vbComp
Set fso = CreateObject("Scripting.FileSystemObject")
base = fso.GetParentFolderName(WScript.ScriptFullName)
inputFile = fso.BuildPath(base, "PWA_Release_Toolkit_v2.5.xlsx")
moduleFile = fso.BuildPath(base, "vba\PWA_Dashboard_v2_5_RC5.bas")
outputFile = fso.BuildPath(base, "PWA_Release_Toolkit_v2.5_RC5.xlsm")
If Not fso.FileExists(inputFile) Or Not fso.FileExists(moduleFile) Then
  WScript.Echo "ERROR: Missing dashboard .xlsx or VBA module. Extract the entire ZIP first."
  WScript.Quit 2
End If
On Error Resume Next
Set excel = CreateObject("Excel.Application")
If Err.Number <> 0 Then
  WScript.Echo "ERROR: Microsoft Excel Desktop is required: " & Err.Description
  WScript.Quit 2
End If
Err.Clear
excel.Visible = False
excel.DisplayAlerts = False
Set wb = excel.Workbooks.Open(inputFile)
If Err.Number <> 0 Then
  WScript.Echo "ERROR: Could not open dashboard: " & Err.Description
  excel.Quit
  WScript.Quit 2
End If
Err.Clear
Set vbComp = wb.VBProject.VBComponents.Import(moduleFile)
If Err.Number <> 0 Then
  WScript.Echo "ERROR: Excel blocked VBA module import. In Excel: File > Options > Trust Center > Trust Center Settings > Macro Settings > check 'Trust access to the VBA project object model'. Re-run this builder; then turn that setting off again. Detail: " & Err.Description
  wb.Close False
  excel.Quit
  WScript.Quit 3
End If
Err.Clear
' Insert actual shape-button controls on Dashboard and bind to imported macros.
Dim s, names, actions, i, sh
Set s = wb.Worksheets("Dashboard")
names = Array("1. Choose Project", "2. Run Doctor", "3. Prepare Safety", "4. Refresh Results", "5. Open Instructions")
actions = Array("PWA_SelectProject", "PWA_RunDoctor", "PWA_PrepareSafety", "PWA_RefreshResults", "PWA_OpenInstructions")
For i = 0 To 4
  Set sh = s.Shapes.AddShape(5, s.Range("A" & (10+i*2)).Left, s.Range("A" & (10+i*2)).Top, 173, 30)
  sh.TextFrame.Characters.Text = names(i)
  sh.OnAction = actions(i)
Next
wb.SaveAs outputFile, 52
If Err.Number <> 0 Then
  WScript.Echo "ERROR: Could not save .xlsm: " & Err.Description
  wb.Close False
  excel.Quit
  WScript.Quit 4
End If
wb.Close False
excel.Quit
WScript.Echo "SUCCESS: " & outputFile
WScript.Echo "Open the .xlsm workbook, enable macros only if you trust these supplied files, and select your project folder."
