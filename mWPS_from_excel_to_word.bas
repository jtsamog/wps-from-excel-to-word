Attribute VB_Name = "mWPS_from_excel_to_word"
Option Explicit

Sub read_wps_data()
Attribute read_wps_data.VB_ProcData.VB_Invoke_Func = "w\n14"

    Dim MySheet As Excel.Worksheet
    Dim MyTable As Excel.ListObject
    Dim MyCell, MyRow As Range
    Dim PropertyName As Collection
    Dim PropertyValue As Collection
    Dim TargetDocument As Object
    Dim WordApp As Object
    Dim TargetDocumentPath As String
    Dim StartTime
        
    Set MySheet = ActiveWorkbook.Worksheets("WPS")
    
    Set MyTable = MySheet.ListObjects(1)
    
    ' Legge le intestazioni di colonna della tabella e le mette in un array
    Set PropertyName = New Collection
    For Each MyCell In MyTable.HeaderRowRange.Cells
     PropertyName.Add MyCell.Text
    Next
    
    Set PropertyValue = New Collection
    Set MyRow = MyTable.Range.Rows(ActiveCell.Row - MyTable.Range.Row + 1)
    
    For Each MyCell In MyRow.Cells
        PropertyValue.Add Item:=MyCell.Text, key:=MyTable.HeaderRowRange.Columns(MyCell.Column).Text
    Next
    
    'Crea un oggetto Applicazione di Word
    Set WordApp = CreateObject("Word.Application")
    
    'Seleziona il file di destinazione
    With Application.FileDialog(msoFileDialogOpen)
        .AllowMultiSelect = False
        .Show
        TargetDocumentPath = .SelectedItems(1)
    End With
    
    WordApp.documents.Open FileName:=TargetDocumentPath, ReadOnly:=False
    
    WordApp.Visible = True
    
    Set TargetDocument = WordApp.ActiveDocument
    
    StartTime = Timer
    
    'Call CreateCustomProperties(TargetDocument, PropertyName, PropertyValue)
    Call CreateCustomProperties(TargetDocument, PropertyName, PropertyValue)
    
    TargetDocument.Fields.Update
    
    Debug.Print "Elapsed time: " & Timer - StartTime
    
    'Esporta il file in pdf:
    'Attenzione: perch� funzionino le costanti di Word bisogna aggiungere
    'ai riferimenti la libreria "Microsoft Word x.x Object Library"
    Dim FileNamePdfExport As String
    Dim MyAnswer As Variant
    
    MyAnswer = MsgBox("Vuoi salvare il documento in pdf?", vbYesNo)
    
    If MyAnswer = vbYes Then
        FileNamePdfExport = Replace(TargetDocument.FullName, TargetDocument.Name, "") & _
            Replace("WPS_" & PropertyValue("wps_number") & "_rev" & PropertyValue("wps_rev") & ".pdf", _
                    "/", "-")
        
        TargetDocument.ExportAsFixedFormat OutputFileName:= _
            FileNamePdfExport, _
            ExportFormat:=wdExportFormatPDF, OpenAfterExport:=False, OptimizeFor:= _
            wdExportOptimizeForPrint, Range:=wdExportAllDocument, Item:= _
            wdExportDocumentContent, IncludeDocProps:=False, KeepIRM:=True, _
            CreateBookmarks:=wdExportCreateNoBookmarks, DocStructureTags:=True, _
            BitmapMissingFonts:=True, UseISO19005_1:=False
    End If
    
End Sub
