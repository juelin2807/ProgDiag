unit Unit1;

{*

Hersteller:
           LinSoft Jürgen linder (juelin) dg5uap@darc.de

Lizens:
           Opensource entsprechend

Hardware:
           keine zusätzliche Hardware

Software:

           Folgende Files
           ProgDiag.exe muß im Soucepfad vorhanden sein

wie Compelieren:
           Lazarus IDE mit FPC
           Printer4Lazarus muss im Objektinspektor als neue
           Anforderung hinzugefügt sein

wie Ausführen:
           Ausführen ProgDiag.exe (Icon)

*}


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, Eingabe, Printers, FileCtrl, PrintersDlgs,
  System.UITypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    FileListBox1: TFileListBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);                                    // Laden lpr-File mit Projektname und allen Units
                                                                                // Projektname und Anzahl Units in Label6 anzeigen und ComboBox1 mit Units laden
    procedure Button2Click(Sender: TObject);                                    // Programm beenden mit Sicherheitsabfrage
    procedure Button3Click(Sender: TObject);                                    // Springen zwischen Variablen und Procedure/Funktion im StringGrid1
    procedure Button4Click(Sender: TObject);                                    // Erfassen Kurztext (Edit1) und bei Procedure/Funktion Langtext (Memo1)
    procedure Button5Click(Sender: TObject);                                    // Drucken Projekt/Unit (Querformat)
    procedure Button6Click(Sender: TObject);                                    // Laden Projekt/Unit von File (.diag)
    procedure Button7Click(Sender: TObject);                                    // Saven Projekt/Unit in File (projektname_Unitname)
                                                                                // zuvor entspechende Zeile im StringGrid1 anklicken
    procedure ComboBox1Change(Sender: TObject);                                 // Auswahl der Unit die angezeigt werden soll
    procedure Edit1KeyPress(Sender: TObject; var Key: char);                    // Prüfung der Eingabe mit Modul Eingabe
    procedure Edit1KeyUp(Sender: TObject; var Key: Word);                       // Auswertung der Eingabe, abspeichern und weiter leiten
    procedure FormActivate(Sender: TObject);                                    // Initialisierung der Variablen und Form-Elemente
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);        // Programm beenden
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);           // Abfrage ob Programm beendet werden soll
    procedure FormCreate(Sender: TObject);                                      // Initialisierung der Variablen und Form-Elemente
    procedure Memo1KeyDown(Sender: TObject; var Key: Word);                     // Abfrage auf RSC-Taste und speichern des Textes in Tabelle prozname
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;       // Merken, welche Zeile im StringGrid1 angeklickt wurde
      var CanSelect: Boolean);
  private
    function Nummer(Komma: Boolean; var Ntextstring: string): string;           // prüfen ob Ntextstring numerisch ist
                                                                                // wenn nicht wird Result leer zurück gegeben
                                                                                // Kamma=True wenn Komma erlaubt ist
                                                                                // Bei Komma wird aus '.' ein ',' gemacht
    function Blankweg(Art: integer; var Btextstring: string): string;           // Blanks in Btextstring entfernen und in Result zurück geben
                                                                                // Art 1 = vor dem Text
                                                                                // Art 2 = hinter dem Text
                                                                                // Art 3 = vor und hinter dem Text
    function Blankdazu(Pos, Lan: integer; var Htextstring: string): string;     // Blanks im Htextstring einfügen und in Result zurück geben
                                                                                // Lan = Ausgabelänge von Result
                                                                                // Pos 1 = vor dem Text
                                                                                // Pos 2 = hinter dem Text
    procedure AnzeigeLoe;                                                       // Löschen alle Ein- und Ausgabefelder der Bildschirmanzeige
    procedure LadenVariable;                                                    // Laden Tabelle varname ins Stringgrid
    procedure LadenProcedure;                                                   // Laden Tabelle prozname ins Stringgrid
    procedure Kopfvar;                                                          // Überschrift für Variable drucken
    procedure Kopfproc;                                                         // Überschrift für Procedure/Funktion drucken
  public
  end;

type tvarn = record                                                             // Satzaufbau Globale Variable
  einheit: string;
  name: string;
  art: string;
  kurzbeschreibung: string;
end;

type tprozn = record                                                            // Satzaufbau Procedure/Funktion
  einheit: string;
  name: string;
  kurzbeschreibung: string;
  langbeschreibunganz: integer;
  langbeschreibung: array of string;
end;

var
  Form1: TForm1;                                                                // Formular (Windows-Fenster)
  JaNein: word;                                                                 // Ergebnis Ja/Nein Abfrage
  Closestat: integer;                                                           // Merker ob Programm beendet werden darf. 0=Ja 1=Nein
  abbruch: Boolean;                                                             // Programm-Abbruch. Wenn True wird ohne Abfrage das Programm abgebrochen
  mtasts: integer;                                                              // Dürfen die Buttons betätigt werden. 1=Ja 0=Nein
  mlauf: integer;                                                               // Welche Eingabe ist zulässig (1..n) 0=keine Eingabe
  mart: integer;                                                                // Art der bearbeitung. 1=Anlegen, 2=Updaten, 3=Löschen
  Tag: integer;                                                                 // Datum Tag
  Monat: integer;                                                               // Datum Monat
  Jahr: integer;                                                                // Datum Jahr
  BUser: string;                                                                // Username der angemeldet ist
  FSatz: string;                                                                // Hilfsvariable
  sta: integer;                                                                 // Status für Initialisierung der Variablen bei Programmstart. 1=vor Init, 2=nach Init
  vers: string;                                                                 // Versionsnummer des Programms
  pfad: string;                                                                 // Verzeichnis der Datenfiles
  filename: string;                                                             // Filename des lpi-Files
  fileadr: TextFile;                                                            // Opennummer eines Textfiles (Assign)
  einheitname: string;                                                          // Unitname
  Datenanzeigeart: integer;                                                     // Anzeigeart für StringGrid. 1=Variable 2=Procedure/Funktion
  progname: string;                                                             // Projektname
  unitnamet: array [1..50, 1..2] of string;                                     // Temporäre Tabelle Unitnamen
  unitzaehlt: integer;                                                          // Zähler temporäre Tabelle Unitnamen
  unitnamen: array [1..50] of string;                                           // Tabelle Unitnamen
  unitzaehl: integer;                                                           // Zähler Tabelle Unitnamen
  varname: array [1..500] of tvarn;                                             // Tabelle Variable
  varzaehl: integer;                                                            // Zähler Tabelle Variable
  prozname: array [1..500] of tprozn;                                           // Tabelle Procedure/Funktion
  prozzaehl: integer;                                                           // Zähler Tabelle Procedure/Funktion
  egrid: integer;                                                               // angeklickte Zeilennummer im StringGrid1
  tabnummer: integer;                                                           // Index der angeklickte Zeilennummer in den Tabellen prozname oder varname
  gridklick: Boolean;                                                           // StringGrid1 anklicken zulässig
  drucker: string;                                                              // Druckername
  druckn: integer;                                                              // Druckernummer für Tabelle
  px: integer;                                                                  // X aktuell in Pixel
  py: integer;                                                                  // Y aktuell in Pixel
  vpx: integer;                                                                 // X-Differenz in Pixel
  vpy: integer;                                                                 // Y-Differenz in Pixel
  format: TPrinterOrientation;                                                  // Druckerformat
  seite: integer;                                                               // Seitenanzahl Frucker
  zeile: integer;                                                               // Zeilenanzahl Drucker

implementation

{$R *.lfm}

procedure TForm1.Kopfvar;
  var h1: string;
  var h2: string;
  var h3: string;
  var h4: string;
begin
  if seite > 0 then
  begin
    Printers.Printer.NewPage;
  end;
  seite:=seite+1;
  py:=vpy;
  zeile:=0;
  h1:=progname;
  h2:=Blankdazu(2, 32, h1);
  h1:=einheitname;
  h3:=Blankdazu(2, 32, h1);
  h1:=IntToStr(seite);
  h4:=Blankdazu(1, 4, h1);
  Printers.Printer.Canvas.TextOut(px, py, 'Globale Variablen für Projekt: '+h2+' und Unit: '+h3+'                          Seite: '+h4+'    Datum: '+DateToStr(now));
  py:=py+vpy;
  zeile:=zeile+1;
  Printers.Printer.Canvas.TextOut(px, py, 'Variablename');
  py:=py+vpy;
  zeile:=zeile+1;
  h1:='Variabletype';
  h2:=Blankdazu(1, 164, h1);
  Printers.Printer.Canvas.TextOut(px, py, h2);
  py:=py+vpy;
  zeile:=zeile+1;
  h1:='Kurzbeschreibung';
  h2:=Blankdazu(1, 164, h1);
  Printers.Printer.Canvas.TextOut(px, py, h2);
  py:=py+vpy;
  zeile:=zeile+1;
  Printers.Printer.Canvas.TextOut(px, py, '====================================================================================================================================================================');
  py:=py+vpy;
  zeile:=zeile+1;
end;

procedure TForm1.Kopfproc;
  var h1: string;
  var h2: string;
  var h3: string;
  var h4: string;
begin
  if seite > 0 then
  begin
    Printers.Printer.NewPage;
  end;
  seite:=seite+1;
  py:=vpy;
  zeile:=0;
  h1:=progname;
  h2:=Blankdazu(2, 32, h1);
  h1:=einheitname;
  h3:=Blankdazu(2, 32, h1);
  h1:=IntToStr(seite);
  h4:=Blankdazu(1, 4, h1);
  Printers.Printer.Canvas.TextOut(px, py, 'Procedure/Funktion für Projekt: '+h2+' und Unit: '+h3+'                         Seite: '+h4+'    Datum: '+DateToStr(now));
  py:=py+vpy;
  zeile:=zeile+1;
  Printers.Printer.Canvas.TextOut(px, py, 'Procedure/Funktionsname');
  py:=py+vpy;
  zeile:=zeile+1;
  h1:='Kurzbeschreibung';
  h2:=Blankdazu(1, 164, h1);
  Printers.Printer.Canvas.TextOut(px, py, h2);
  py:=py+vpy;
  zeile:=zeile+1;
  h1:='Langtext';
  h2:=Blankdazu(1, 164, h1);
  Printers.Printer.Canvas.TextOut(px, py, h2);
  py:=py+vpy;
  zeile:=zeile+1;
  Printers.Printer.Canvas.TextOut(px, py, '====================================================================================================================================================================');
  py:=py+vpy;
  zeile:=zeile+1;
end;

procedure TForm1.LadenVariable;
  var h1: integer;
  var h2: integer;
begin
  Screen.Cursor:=crHourGlass;
  Form1.Cursor:=crHourGlass;
  Form1.Refresh;
  h1:=1;
  if varzaehl > 0 then
  begin
    for h2:=1 to varzaehl do
    begin
      h1:=h1 + 1;
      StringGrid1.RowCount:=h1;
      h1:=h1 - 1;
      StringGrid1.Cells[0, h1]:=varname[h2].name;
      StringGrid1.Cells[1, h1]:=varname[h2].art;
      StringGrid1.Cells[2, h1]:=varname[h2].kurzbeschreibung;
      h1:=h1 + 1;
    end;
  end;
  Screen.Cursor:=crDefault;
  Form1.Cursor:=crDefault;
  Form1.Refresh;
  if h1 = 1 then
  begin
    StringGrid1.RowCount:=2;
    StringGrid1.Cells[0, 1]:='';
    StringGrid1.Cells[1, 1]:='';
    StringGrid1.Cells[2, 1]:='';
  end;
end;

procedure TForm1.LadenProcedure;
  var h1: integer;
  var h2: integer;
begin
  Screen.Cursor:=crHourGlass;
  Form1.Cursor:=crHourGlass;
  Form1.Refresh;
  h1:=1;
  if prozzaehl > 0 then
  begin
    for h2:=1 to prozzaehl do
    begin
      h1:=h1 + 1;
      StringGrid1.RowCount:=h1;
      h1:=h1 - 1;
      StringGrid1.Cells[0, h1]:=prozname[h2].name;
      StringGrid1.Cells[1, h1]:=prozname[h2].kurzbeschreibung;
      h1:=h1 + 1;
    end;
  end;
  Screen.Cursor:=crDefault;
  Form1.Cursor:=crDefault;
  Form1.Refresh;
  if h1 = 1 then
  begin
    StringGrid1.RowCount:=2;
    StringGrid1.Cells[0, 1]:='';
    StringGrid1.Cells[1, 1]:='';
  end;
end;

procedure TForm1.AnzeigeLoe;
begin
  ComboBox1.Text:='';
  ComboBox1.Enabled:=False;
  ComboBox1.Color:=clSilver;
  ComboBox1.ItemIndex:=-1;
  ComboBox1.ItemHeight:=32;
  ComboBox1.Items.Clear;
  Edit1.Text:='';
  Edit1.Enabled:=False;
  Edit1.Color:=clSilver;
  Label6.Caption:='';
  Label9.Caption:='';
  Memo1.Lines.Clear;
  Memo1.ReadOnly:=True;
  StringGrid1.RowCount:=1;
  StringGrid1.ColCount:=0;
end;

function TForm1.Blankweg(Art: integer; var Btextstring: string): string;
  var laenge: integer;
  var stelle: integer;
  var vari12: integer;
  var zeichen: string;
  var ausgabe: string;
begin
  laenge:=Length(Btextstring);
  ausgabe:='';
  if laenge > 0 then
  begin
    ausgabe:=Btextstring;
    if ((Art = 1) or (Art = 3)) then
    begin
      vari12:=0;
      for stelle:=1 to laenge do
      begin
        zeichen:=Copy(Btextstring,stelle,1);
        if (vari12 = 0) then
        begin
          if (zeichen <> ' ') then
          begin
            vari12:=stelle;
          end;
        end;
      end;
      if vari12 > 0 then
      begin
        zeichen:=Btextstring;
        ausgabe:=Copy(zeichen,vari12,laenge-(vari12-1));
      end;
    end;
    laenge:=Length(ausgabe);
    if laenge > 0 then
    begin
      if ((Art = 2) or (Art = 3)) then
      begin
        vari12:=0;
        for stelle:=laenge downto 1 do
        begin
          zeichen:=Copy(ausgabe,stelle,1);
          if (vari12 = 0) then
          begin
            if (zeichen <> ' ') then
            begin
              vari12:=stelle;
            end;
          end;
        end;
        if (vari12 > 0) then
        begin
          zeichen:=ausgabe;
          ausgabe:=Copy(zeichen,1,vari12);
        end;
      end;
    end else begin
      ausgabe:='';
    end;
  end;
  Result:=ausgabe;
end;

function TForm1.Blankdazu(Pos, Lan: integer; var Htextstring: string): string;
  var laenge: integer;
  var stelle: integer;
  var ausgabe: string;
begin
  laenge:=Length(Htextstring);
  ausgabe:=Htextstring;
  if laenge < Lan then
  begin
    while laenge < Lan do
    begin
      if Pos = 1 then
      begin
        ausgabe:=' '+ausgabe;
      end else begin
        ausgabe:=ausgabe+' ';
      end;
      laenge:=Length(ausgabe);
    end;
  end else begin
    if laenge > Lan then
    begin
      if Pos = 1 then
      begin
        stelle:=laenge-Lan+1;
        ausgabe:=Copy(Htextstring,stelle,Lan);
      end else begin
        ausgabe:=Copy(Htextstring,1,Lan);
      end;
    end;
  end;
  Result:=ausgabe;
end;

procedure TForm1.FormCreate(Sender: TObject);
  var heute: string;
  var h1: integer;
  var h3: string;
  var Rec: LongRec;
  var hx1: integer;
  var hx2: integer;
  var hx3: integer;
  var hx4: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  Closestat:=0;
  mtasts:=1;
  ialpha:='';
  inummer:=0;
  inumkom:=0;
  ikomma:=0;
  iart:=1;
  izeich:=3;
  istell:=0;
  mlauf:=0;
  BUser:='                                                     ';
  try
    BUser:=GetEnvironmentVariable('USERNAME');
  except
    BUser:='unknown';
  end;
  heute:=FormatDateTime('DD.MM.YYYY',now);
  h1:=StrLen(PChar(heute));
  if (h1 = 10) then
  begin
    h3:=Copy(heute, 1, 2);
    Tag:=StrToInt(h3);
    h3:=Copy(heute, 4, 2);
    Monat:=StrToInt(h3);
    h3:=Copy(heute, 7, 4);
    Jahr:=StrToInt(h3);
  end;
  abbruch:=false;
  sta:=1;
  Rec:=LongRec(GetFileVersion(ParamStr(0)));
  hx1:=Rec.Bytes[0];
  hx2:=Rec.Bytes[1];
  hx3:=Rec.Bytes[2];
  hx4:=Rec.Bytes[3];
  vers:=IntToStr(hx3)+'.'+IntToStr(hx1);
  Form1.Caption:='  '+Application.Title+'            Version '+vers+'                   <'+BUser+'>';
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
end;

procedure TForm1.Memo1KeyDown(Sender: TObject; var Key: Word);
  var h1: integer;
  var h2: string;
begin
  if mlauf = 3 then
  begin
    if Key = 27 then
    begin
      prozname[tabnummer].langbeschreibunganz:=0;
      SetLength(prozname[tabnummer].langbeschreibung, 0);
      if Memo1.Lines.Count > 0 then
      begin
        prozname[tabnummer].langbeschreibunganz:=Memo1.Lines.Count;
        SetLength(prozname[tabnummer].langbeschreibung, Memo1.Lines.Count);
        for h1:=0 to Memo1.Lines.Count-1 do
        begin
          h2:=Memo1.Lines.Strings[h1];
          prozname[tabnummer].langbeschreibung[h1]:=h2;
        end;
      end;
      Memo1.ReadOnly:=True;
      Memo1.Color:=clSilver;
      gridklick:=True;
      mtasts:=1;
      mlauf:=1;
    end;
  end;
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
  var h1: string;
  var h3: string;
  var h4: integer;
  var h5: integer;
  var h6: integer;
  var h7: integer;
begin
  CanSelect:=True;
  if gridklick then
  begin
    egrid:=aCol;
    egrid:=aRow;
    Memo1.Lines.Clear;
    Edit1.Text:='';
    Label9.Caption:='';
    h3:=StringGrid1.Cells[0, egrid];
    h1:=Blankweg(3, h3);
    if h1 <> '' then
    begin
      if Datenanzeigeart = 1 then
      begin
        h7:=egrid;
        egrid:=0;
        if varzaehl >  0 then
        begin
          for h4:=1 to varzaehl do
          begin
            h3:=varname[h4].einheit;
            if h3 = einheitname then
            begin
              h3:=varname[h4].name;
              if h3 = h1 then
              begin
                Label9.Caption:=varname[h4].name;
                Edit1.Text:=varname[h4].kurzbeschreibung;
                egrid:=h7;
              end;
            end;
          end;
        end;
      end;
      if Datenanzeigeart = 2 then
      begin
        h7:=egrid;
        egrid:=0;
        if prozzaehl > 0 then
        begin
          for h4:=1 to prozzaehl do
          begin
            h3:=prozname[h4].einheit;
            if h3 = einheitname then
            begin
              h3:=prozname[h4].name;
              if h3 = h1 then
              begin
                Label9.Caption:=prozname[h4].name;
                Edit1.Text:=prozname[h4].kurzbeschreibung;
                egrid:=h7;
                h5:=prozname[h4].langbeschreibunganz;
                if h5 > 0 then
                begin
                  for h6:=0 to h5-1 do
                  begin
                    h3:=prozname[h4].langbeschreibung[h6];
                    Memo1.Lines.Add(h3);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end else begin
      egrid:=0;
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Form1.Cursor:=crDefault;
  Form1.Refresh;
  CloseAction:=caFree;
end;

procedure TForm1.FormActivate(Sender: TObject);
  var h1: integer;
  var h2: integer;
  var h3: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if sta = 1 then
  begin
    Form1.Caption:='  '+Application.Title+'            Version '+vers+'                   <'+BUser+'>';
    Closestat:=0;
    mtasts:=1;
    ialpha:='';
    inummer:=0;
    inumkom:=0;
    ikomma:=0;
    iart:=1;
    izeich:=3;
    istell:=0;
    mlauf:=0;
    sta:=2;
    gridklick:=False;
    AnzeigeLoe;
    FileListBox1.Visible:=False;
    Button1.Visible:=True;
    Button3.Visible:=False;
    Button4.Visible:=False;
    Button5.Visible:=False;
    Button6.Visible:=True;
    Button7.Visible:=False;
    Button3.Caption:='Ansicht globale Variable';
    progname:='';
    unitzaehlt:=0;
    unitzaehl:=0;
    varzaehl:=0;
    prozzaehl:=0;
    einheitname:='';
    Datenanzeigeart:=1;
    egrid:=0;
    vpx:=56;
    vpy:=68;
    h1:=Printers.Printer.Printers.Count;
    h2:=Printers.Printer.PrinterIndex;
    if h1 > 0 then
    begin
      for h3:=0 to h1-1 do
      begin
        if h3 = h2 then
        begin
          drucker:=Printers.Printer.Printers.Strings[h3];
          druckn:=h3;
        end;
      end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (Closestat = 0) then
  begin
    if (mtasts = 1) then
    begin
      gridklick:=False;
      mtasts:=0;
      mlauf:=0;
      close;
    end;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    mtasts:=0;
    gridklick:=False;
    Edit1.Text:='';
    Label9.Caption:='';
    Memo1.Lines.Clear;
    StringGrid1.RowCount:=1;
    StringGrid1.ColCount:=0;
    if Button3.Caption = 'Ansicht globale Variable' then
    begin
      Button3.Caption:='Ansicht Procedure/Funktion';
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=2;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=1800;
      StringGrid1.ColWidths[1]:=1500;
      StringGrid1.Cells[0, 0]:='Procedure/Funktion-Name';
      StringGrid1.Cells[1, 0]:='Procedure/Funktion-Kurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
      Datenanzeigeart:=2;
      LadenProcedure;
      Label2.Caption:='Anzahl Procedures: '+IntToStr(prozzaehl);
    end else begin
      Button3.Caption:='Ansicht globale Variable';
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=3;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=600;
      StringGrid1.ColWidths[1]:=600;
      StringGrid1.ColWidths[2]:=1500;
      StringGrid1.Cells[0, 0]:='Variablenname';
      StringGrid1.Cells[1, 0]:='Variablentype';
      StringGrid1.Cells[2, 0]:='Variablenkurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
      StringGrid1.Cells[2, 1]:='';
      Datenanzeigeart:=1;
      LadenVariable;
      Label2.Caption:='Anzahl Variable: '+IntToStr(varzaehl);
    end;
    mtasts:=1;
    gridklick:=True;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
  var h1: string;
  var h2: string;
  var h3: integer;
  var h4: integer;
  var h5: string;
  var h6: string;
  var h7: string;
  var h8: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    gridklick:=False;
    Label9.Caption:='';
    Memo1.Lines.Clear;
    Edit1.Text:='';
    if egrid > 0 then
    begin
      h1:=StringGrid1.Cells[0, egrid];
      h2:=Blankweg(3, h1);
      if h2 <> '' then
      begin
        mtasts:=0;
        mlauf:=2;
        Label9.Caption:=h2;;
        if Datenanzeigeart = 1 then
        begin
          h3:=0;
          h7:='';
          if varzaehl > 0 then
          begin
            for h4:=1 to varzaehl do
            begin
              h5:=varname[h4].einheit;
              if h5 = einheitname then
              begin
                h6:=varname[h4].name;
                if h6 = h2 then
                begin
                  h3:=h4;
                  h7:=varname[h4].kurzbeschreibung;
                end;
              end;
            end;
          end;
          tabnummer:=h3;
          Edit1.Enabled:=True;
          Edit1.Color:=clYellow;
          Edit1.Font.Color:=clBlue;
          Edit1.ReadOnly:=False;
          Edit1.Text:=h7;
          ialpha:=h7;
          inummer:=0;
          iart:=1;
          inumkom:=0;
          ikomma:=0;
          izeich:=3;
          istell:=0;
          ifunc:=5;
          ilanmax:=120;
          ilanmin:=1;
          iautocr:=1;
          Form1.ActiveControl:=Edit1;
          Edit1.AutoSelect:=True;
        end;
        if Datenanzeigeart = 2 then
        begin
          h3:=0;
          h7:='';
          h8:=0;
          if prozzaehl > 0 then
          begin
            for h4:=1 to prozzaehl do
            begin
              h5:=prozname[h4].einheit;
              if h5 = einheitname then
              begin
                h6:=prozname[h4].name;
                if h6 = h2 then
                begin
                  h3:=h4;
                  h7:=prozname[h4].kurzbeschreibung;
                  h8:=prozname[h4].langbeschreibunganz;
                end;
              end;
            end;
          end;
          tabnummer:=h3;
          if h8 > 0 then
          begin
            for h4:=0 to h8-1 do
            begin
              Memo1.Lines.Add(prozname[h3].langbeschreibung[h4]);
            end;
          end;
          Edit1.Enabled:=True;
          Edit1.Color:=$0080FFFF;
          Edit1.ReadOnly:=False;
          Edit1.Text:=h7;
          ialpha:=h7;
          inummer:=0;
          iart:=1;
          inumkom:=0;
          ikomma:=0;
          izeich:=3;
          istell:=0;
          ifunc:=5;
          ilanmax:=120;
          ilanmin:=1;
          iautocr:=1;
          Form1.ActiveControl:=Edit1;
          Edit1.AutoSelect:=True;
        end;
      end else begin
        Label2.Caption:='markierte Zeile im Stringgrid ist leer';
      end;
    end else begin
      Label2.Caption:='erst Datenzeile im Stringgrid markieren';
    end;
    egrid:=0;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
  var h1: Boolean;
  var h2: integer;
  var h3: string;
  var h4: string;
  var h5: integer;
  var h6: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    if ((varzaehl > 0) or (prozzaehl > 0)) then
    begin
      mtasts:=0;
      gridklick:=False;
      format:=poLandscape;
      Printers.Printer.Orientation:=format;
      h1:=PrinterSetupDialog1.Execute;
      if h1 then
      begin
        drucker:=Printers.Printer.Printers.Strings[Printer.PrinterIndex];
        druckn:=Printer.PrinterIndex;
        Screen.Cursor:=crHourGlass;
        Form1.Cursor:=crHourGlass;
        Form1.Refresh;
        Printers.Printer.PrinterIndex:=druckn;
        format:=poLandscape;
        Printers.Printer.Canvas.Brush.Style:=bsSolid;
        Printers.Printer.Canvas.Font.Charset:=0;
        Printers.Printer.Canvas.Font.Name:='Courier';
        Printers.Printer.Canvas.Font.Style:=[fsBold];
        Printers.Printer.Canvas.Font.Size:=8;
        Printers.Printer.Canvas.Font.Pitch:=fpFixed;
        Printers.Printer.Canvas.Font.Color:=clBlack;
        Printers.Printer.Copies:=1;
        Printers.Printer.Orientation:=format;
        px:=vpx+vpx;
        seite:=0;
        zeile:=99;
        Printers.Printer.BeginDoc;
            if varzaehl > 0 then
            begin
              for h2:=1 to varzaehl do
              begin
                if zeile > 64 then Kopfvar;
                h3:=varname[h2].name;
                Printers.Printer.Canvas.TextOut(px, py, h3);
                py:=py+vpy;
                zeile:=zeile+1;
                h3:=varname[h2].art;
                h4:=Blankdazu(1, 164, h3);
                Printers.Printer.Canvas.TextOut(px, py, h4);
                py:=py+vpy;
                zeile:=zeile+1;
                h3:=varname[h2].kurzbeschreibung;
                h4:=Blankdazu(1, 164, h3);
                Printers.Printer.Canvas.TextOut(px, py, h4);
                py:=py+vpy;
                zeile:=zeile+1;
                Printers.Printer.Canvas.TextOut(px, py, '--------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                py:=py+vpy;
                zeile:=zeile+1;
              end;
              Printers.Printer.Canvas.TextOut(px, py, 'Anzahl Variable: '+IntToStr(varzaehl));
              py:=py+vpy;
              zeile:=zeile+1;
            end;
            zeile:=99;
            if prozzaehl > 0 then
            begin
              for h2:=1 to prozzaehl do
              begin
                if zeile > 65 then Kopfproc;
                h3:=prozname[h2].name;
                Printers.Printer.Canvas.TextOut(px, py, h3);
                py:=py+vpy;
                zeile:=zeile+1;
                h3:=prozname[h2].kurzbeschreibung;
                h4:=Blankdazu(1, 164, h3);
                Printers.Printer.Canvas.TextOut(px, py, h4);
                py:=py+vpy;
                zeile:=zeile+1;
                h5:=prozname[h2].langbeschreibunganz;
                if h5 > 0 then
                begin
                  for h6:=0 to h5-1 do
                  begin
                    if zeile > 67 then Kopfproc;
                    h3:=prozname[h2].langbeschreibung[h6];
                    h4:=Blankdazu(1, 164, h3);
                    Printers.Printer.Canvas.TextOut(px, py, h4);
                    py:=py+vpy;
                    zeile:=zeile+1;
                  end;
                end;
                Printers.Printer.Canvas.TextOut(px, py, '--------------------------------------------------------------------------------------------------------------------------------------------------------------------');
                py:=py+vpy;
                zeile:=zeile+1;
              end;
              Printers.Printer.Canvas.TextOut(px, py, 'Anzahl Procedure/Funktion: '+IntToStr(prozzaehl));
              py:=py+vpy;
              zeile:=zeile+1;
            end;
        Printers.Printer.EndDoc;
        Screen.Cursor:=crDefault;
        Form1.Cursor:=crDefault;
        Form1.Refresh;
      end;
      gridklick:=True;
      mtasts:=1;
    end;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
  var h1: Boolean;
  var h2: integer;
  var h3: integer;
  var h4: integer;
  var h5: string;
  var h6: string;
  var h7: string;
  var h8: integer;
  var h9: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    mtasts:=0;
    mlauf:=0;
    egrid:=0;
    gridklick:=False;
    h9:=0;
    AnzeigeLoe;
    Button1.Visible:=True;
    Button3.Visible:=False;
    Button4.Visible:=False;
    Button5.Visible:=False;
    Button6.Visible:=True;
    Button7.Visible:=False;
    Button3.Caption:='Ansicht globale Variable';
    progname:='';
    unitzaehl:=0;
    varzaehl:=0;
    prozzaehl:=0;
    einheitname:='';
    Datenanzeigeart:=1;
    if Datenanzeigeart = 1 then
    begin
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=3;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=600;
      StringGrid1.ColWidths[1]:=600;
      StringGrid1.ColWidths[2]:=1500;
      StringGrid1.Cells[0, 0]:='Variablenname';
      StringGrid1.Cells[1, 0]:='Variablentype';
      StringGrid1.Cells[2, 0]:='Variablenkurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
      StringGrid1.Cells[2, 1]:='';
    end;
    if Datenanzeigeart = 2 then
    begin
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=2;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=1800;
      StringGrid1.ColWidths[1]:=1500;
      StringGrid1.Cells[0, 0]:='Procedure/Funktion-Name';
      StringGrid1.Cells[1, 0]:='Procedure/Funktion-Kurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
    end;
    OpenDialog1.DefaultExt:='diag';
    OpenDialog1.Filter:='Lazarus-Projektbeschreibung|*.diag';
    OpenDialog1.Title:='Lazarus-Projektbeschreibung';
    h1:=OpenDialog1.Execute;
    if h1 then
    begin
      h2:=Length(OpenDialog1.FileName);
      if h2 > 5 then
      begin
        h3:=0;
        for h4:=1 to h2 do
        begin
          h5:=Copy(OpenDialog1.FileName,h4,1);
          if h5 = '\' then h3:=h4;
        end;
        if h3 > 0 then
        begin
          if h3 < h2 then
          begin
            pfad:=Copy(OpenDialog1.FileName,1,h3);
            filename:=Copy(OpenDialog1.FileName,h3+1,h2-h3);
            if FileExists(OpenDialog1.FileName) then
            begin
              assignFile(fileadr, OpenDialog1.FileName);
              Reset(fileadr);
              h8:=0;
              While Not EOF(fileadr) do
              begin
                readLn(fileadr, h6);
                h5:=Blankweg(1, h6);
                h2:=Length(h5);
                if h2 > 0 then
                begin
                  h6:='';
                  h4:=0;
                  for h3:=1 to h2 do
                  begin
                    if h4 = 0 then
                    begin
                      h7:=Copy(h5,h3,1);
                      if h7 = ' ' then
                      begin
                        h4:=h3;
                      end else begin
                        h6:=h6+h7;
                      end;
                    end;
                  end;
                  h3:=Length(h6);
                  if h3 > 0 then
                  begin
                    if ((h8 = 3) and (h6 = 'Proglang:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        h9:=h9+1;
                        SetLength(prozname[prozzaehl].langbeschreibung, h9);
                        prozname[prozzaehl].langbeschreibung[h9-1]:=Blankweg(2, h7);
                        prozname[prozzaehl].langbeschreibunganz:=h9;
                      end;
                    end;
                    if ((h8 = 3) and (h6 = 'Progkurz:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        prozname[prozzaehl].kurzbeschreibung:=Blankweg(2, h7);
                      end;
                    end;
                    if ((h8 = 3) and (h6 = 'Progname:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        h9:=0;
                        if prozzaehl < 500 then
                        begin
                          prozzaehl:=prozzaehl+1;
                          prozname[prozzaehl].einheit:=einheitname;
                          prozname[prozzaehl].name:=Blankweg(2, h7);
                          prozname[prozzaehl].langbeschreibunganz:=h9;
                          SetLength(prozname[prozzaehl].langbeschreibung, 0);
                        end;
                      end;
                    end;
                    if ((h8 = 2) and (h6 = 'Progname:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        h8:=3;
                        h9:=0;
                        if prozzaehl < 500 then
                        begin
                          prozzaehl:=prozzaehl+1;
                          prozname[prozzaehl].einheit:=einheitname;
                          prozname[prozzaehl].name:=Blankweg(2, h7);
                          prozname[prozzaehl].langbeschreibunganz:=h9;
                          SetLength(prozname[prozzaehl].langbeschreibung, 0);
                        end;
                      end;
                    end;
                    if ((h8 = 2) and (h6 = 'Varname:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        if varzaehl < 500 then
                        begin
                          varzaehl:=varzaehl+1;
                          varname[varzaehl].einheit:=einheitname;
                          varname[varzaehl].name:=Blankweg(2, h7);
                        end;
                      end;
                    end;
                    if ((h8 = 2) and (h6 = 'Varart:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        varname[varzaehl].art:=Blankweg(2, h7);
                      end;
                    end;
                    if ((h8 = 2) and (h6 = 'Varkurz:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        varname[varzaehl].kurzbeschreibung:=Blankweg(2, h7);
                      end;
                    end;
                    if ((h8 = 1) and (h6 = 'Unit:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        einheitname:=Blankweg(2, h7);
                        h8:=2;
                        unitzaehl:=1;
                        unitnamen[unitzaehl]:=einheitname;
                        Label6.Caption:='Projekt: '+progname+'    Anzahl Units: '+IntToStr(unitzaehl);
                        ComboBox1.Items.Add(einheitname);
                        ComboBox1.Text:=einheitname;
                        ComboBox1.ItemIndex:=ComboBox1.Items.IndexOf(einheitname);
                      end;
                    end;
                    if ((h8 = 0) and (h6 = 'Projekt:')) then
                    begin
                      if h4 < h2 then
                      begin
                        h7:=Copy(h5,h4+1,h2-h4+1);
                        progname:=Blankweg(2, h7);
                        h8:=1;
                        Label6.Caption:='Projekt: '+progname;
                      end;
                    end;
                  end;
                end;
              end;
              CloseFile(fileadr);
              if unitzaehl > 0 then
              begin
                if Datenanzeigeart = 1 then
                begin
                  LadenVariable;
                  Label2.Caption:='Anzahl Variable: '+IntToStr(varzaehl);
                end;
                if Datenanzeigeart = 2 then
                begin
                  LadenProcedure;
                  Label2.Caption:='Anzahl Procedures: '+IntToStr(prozzaehl);
                end;
                Button1.Visible:=True;
                Button3.Visible:=True;
                Button4.Visible:=True;
                Button5.Visible:=True;
                Button6.Visible:=True;
                Button7.Visible:=True;
              end else begin
                Label2.Caption:='keine Units vorhanden, Abbruch';
              end;
            end else begin
              Label2.Caption:='File '+OpenDialog1.FileName+' nicht vorhanden, Abbruch';
            end;
          end else begin
            Label2.Caption:='Filename nicht zulässig, Abbruch';
          end;
        end else begin
          Label2.Caption:='Filename nicht zulässig, Abbruch';
        end;
      end else begin
        Label2.Caption:='Filename nicht zulässig, Abbruch';
      end;
    end;
    gridklick:=True;
    mtasts:=1;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
  var h1: Boolean;
  var h2: string;
  var h3: string;
  var h4: integer;
  var h5: integer;
  var h6: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    if ((varzaehl > 0) or (prozzaehl > 0)) then
    begin
      mtasts:=0;
      gridklick:=False;
      h1:=SelectDirectoryDialog1.Execute;
      if h1 then
      begin
        h3:=SelectDirectoryDialog1.FileName;
        h2:=h3+'\'+progname+'_'+einheitname+'.diag';
        if FileExists(h2) then
        begin
          JaNein:=messagedlg('File '+progname+'_'+einheitname+'.diag'+' schon vorhanden, überschreiben ?', mtConfirmation, [mbYes, mbNo], 0);
          if (JaNein = mrYes) then
          begin
            DeleteFile(h2);
            assignFile(fileadr, h2);
            Rewrite(fileadr);
            h3:='Projekt: '+progname;
            Writeln(fileadr, h3);
            h3:='Unit: '+einheitname;
            Writeln(fileadr, h3);
            if varzaehl > 0 then
            begin
              for h4:=1 to varzaehl do
              begin
                h3:='Varname: '+varname[h4].name;
                Writeln(fileadr, h3);
                h3:='Varart: '+varname[h4].art;
                Writeln(fileadr, h3);
                h3:='Varkurz: '+varname[h4].kurzbeschreibung;
                Writeln(fileadr, h3);
              end;
            end;
            if prozzaehl > 0 then
            begin
              for h4:=1 to prozzaehl do
              begin
                h3:='Progname: '+prozname[h4].name;
                Writeln(fileadr, h3);
                h3:='Progkurz: '+prozname[h4].kurzbeschreibung;
                Writeln(fileadr, h3);
                h5:=prozname[h4].langbeschreibunganz;
                if h5 > 0 then
                begin
                  for h6:=0 to h5-1 do
                  begin
                    h3:='Proglang: '+prozname[h4].langbeschreibung[h6];
                    Writeln(fileadr, h3);
                  end;
                end;
              end;
            end;
            CloseFile(fileadr);
          end;
        end else begin
          assignFile(fileadr, h2);
          Rewrite(fileadr);
          h3:='Projekt: '+progname;
          Writeln(fileadr, h3);
          h3:='Unit: '+einheitname;
          Writeln(fileadr, h3);
          if varzaehl > 0 then
          begin
            for h4:=1 to varzaehl do
            begin
              h3:='Varname: '+varname[h4].name;
              Writeln(fileadr, h3);
              h3:='Varart: '+varname[h4].art;
              Writeln(fileadr, h3);
              h3:='Varkurz: '+varname[h4].kurzbeschreibung;
              Writeln(fileadr, h3);
            end;
          end;
          if prozzaehl > 0 then
          begin
            for h4:=1 to prozzaehl do
            begin
              h3:='Progname: '+prozname[h4].name;
              Writeln(fileadr, h3);
              h3:='Progkurz: '+prozname[h4].kurzbeschreibung;
              Writeln(fileadr, h3);
              h5:=prozname[h4].langbeschreibunganz;
              if h5 > 0 then
              begin
                for h6:=0 to h5-1 do
                begin
                  h3:='Proglang: '+prozname[h4].langbeschreibung[h6];
                  Writeln(fileadr, h3);
                end;
              end;
            end;
          end;
          CloseFile(fileadr);
        end;
      end;
      gridklick:=True;
      mtasts:=1;
    end;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
  var h1: string;
  var h2: integer;
  var h3: integer;
  var h4: integer;
  var h5: string;
  var h6: string;
  var h7: string;
  var h8: integer;
  var h9: integer;
  var ha: string;
  var hb: string;
  var hc: integer;
  var hd: string;
  var he: integer;
  var hf: integer;
  var hg: integer;
  var hh: string;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  if mlauf = 1 then
  begin
    Label2.Caption:='';
    egrid:=0;
    gridklick:=False;
    ialpha:=ComboBox1.Text;
    h1:=Blankweg(3, ialpha);
    if h1 <> '' then
    begin
      einheitname:=h1;
      Edit1.Text:='';
      Label9.Caption:='';
      Memo1.Lines.Clear;
      StringGrid1.RowCount:=1;
      StringGrid1.ColCount:=0;
      Button1.Visible:=True;
      Button3.Visible:=False;
      Button4.Visible:=False;
      Button5.Visible:=False;
      Button6.Visible:=True;
      Button7.Visible:=False;
      varzaehl:=0;
      prozzaehl:=0;
      if Datenanzeigeart = 1 then
      begin
        StringGrid1.RowCount:=2;
        StringGrid1.ColCount:=3;
        StringGrid1.FixedRows:=1;
        StringGrid1.ColWidths[0]:=600;
        StringGrid1.ColWidths[1]:=600;
        StringGrid1.ColWidths[2]:=1500;
        StringGrid1.Cells[0, 0]:='Variablenname';
        StringGrid1.Cells[1, 0]:='Variablentype';
        StringGrid1.Cells[2, 0]:='Variablenkurzbeschreibung';
        StringGrid1.Cells[0, 1]:='';
        StringGrid1.Cells[1, 1]:='';
        StringGrid1.Cells[2, 1]:='';
      end;
      if Datenanzeigeart = 2 then
      begin
        StringGrid1.RowCount:=2;
        StringGrid1.ColCount:=2;
        StringGrid1.FixedRows:=1;
        StringGrid1.ColWidths[0]:=1800;
        StringGrid1.ColWidths[1]:=1500;
        StringGrid1.Cells[0, 0]:='Procedure/Funktion-Name';
        StringGrid1.Cells[1, 0]:='Procedure/Funktion-Kurzbeschreibung';
        StringGrid1.Cells[0, 1]:='';
        StringGrid1.Cells[1, 1]:='';
      end;
      filename:=pfad+einheitname+'.pas';
      if FileExists(filename) then
      begin
        assignFile(fileadr, filename);
        Reset(fileadr);
        h8:=0;
        hc:=0;
        he:=0;
        While Not EOF(fileadr) do
        begin
          readLn(fileadr, h6);
          h5:=Blankweg(1, h6);
          h2:=Length(h5);
          if h2 > 0 then
          begin
            h6:='';
            h4:=0;
            for h3:=1 to h2 do
            begin
              if h4 = 0 then
              begin
                h7:=Copy(h5,h3,1);
                if h7 = ' ' then
                begin
                  h4:=h3;
                end else begin
                  h6:=h6+h7;
                end;
              end;
            end;
            h3:=Length(h6);
            if h3 > 0 then
            begin
              if ((h8 < 4) and (LowerCase(h6) = 'var')) then
              begin
                if ((h8 = 0) or (h8 = 1)) then h8:=h8+2;
                hc:=1;
                he:=0;
              end;
              if ((h8 < 4) and (LowerCase(h6) = 'implementation')) then
              begin
                h8:=4;
                hc:=0;
                he:=0;
              end;
              if ((h8 < 4) and (h6 = '{$R')) then
              begin
                h8:=4;
                hc:=0;
                he:=0;
              end;
              if ((h8 < 4) and (LowerCase(h6) = 'procedure')) then
              begin
                if ((h8 = 0) or (h8 = 2)) then h8:=h8+1;
                hc:=0;
                hh:='';
                hf:=Length(h5);
                if hf > h4+1 then
                begin
                  h6:='';
                  hg:=0;
                  for h3:=h4+1 to hf do
                  begin
                    if hg = 0 then
                    begin
                      h7:=Copy(h5,h3,1);
                      if h7 = '/' then
                      begin
                        hg:=h3;
                      end else begin
                        h6:=h6+h7;
                      end;
                    end;
                  end;
                  h3:=Length(h6);
                  if h3 > 0 then
                  begin
                    if hg > 0 then
                    begin
                      h7:=Copy(h5,hg+1,1);
                      if h7 = '/' then
                      begin
                        if hf > hg+1 then
                        begin
                          h7:=Copy(h5,hg+2,hf-hg-1);
                          hh:=Blankweg(3, h7);
                        end;
                      end;
                      h7:=Copy(h5,1,hg-1);
                      h5:=h7;
                    end;
                  end;
                end;
                h7:=Blankweg(2, h5);
                h4:=Length(h7);
                ialpha:=Copy(h7,h4,1);
                if ialpha = ';' then
                begin
                  ialpha:=h7;
                  h7:=Copy(ialpha,1,h4-1);
                end;
                h4:=Length(h7);
                if h4 > 0 then
                begin
                  h6:=Copy(h7,h4,1);
                  if h6 = ';' then
                  begin
                    h6:=h7;
                    h7:=Copy(h6,1,h4-1);
                  end;
                end;
                if prozzaehl < 500 then
                begin
                  he:=1;
                  prozzaehl:=prozzaehl+1;
                  prozname[prozzaehl].einheit:=einheitname;
                  prozname[prozzaehl].kurzbeschreibung:='';
                  h3:=Length(hh);
                  if h3 > 0 then
                  begin
                    prozname[prozzaehl].kurzbeschreibung:=hh;
                  end;
                  prozname[prozzaehl].langbeschreibunganz:=0;
                  SetLength(prozname[prozzaehl].langbeschreibung, 0);
                  prozname[prozzaehl].name:=h7;
                end else begin
                  Label2.Caption:='Anzahl Proceduren/Funktionen größer 500, Abbruch';
                  h8:=9;
                end;
              end;
              if ((h8 < 4) and (LowerCase(h6) = 'function')) then
              begin
                if ((h8 = 0) or (h8 = 2)) then h8:=h8+1;
                hc:=0;
                hh:='';
                hf:=Length(h5);
                if hf > h4+1 then
                begin
                  h6:='';
                  hg:=0;
                  for h3:=h4+1 to hf do
                  begin
                    if hg = 0 then
                    begin
                      h7:=Copy(h5,h3,1);
                      if h7 = '/' then
                      begin
                        hg:=h3;
                      end else begin
                        h6:=h6+h7;
                      end;
                    end;
                  end;
                  h3:=Length(h6);
                  if h3 > 0 then
                  begin
                    if hg > 0 then
                    begin
                      h7:=Copy(h5,hg+1,1);
                      if h7 = '/' then
                      begin
                        if hf > hg+1 then
                        begin
                          h7:=Copy(h5,hg+2,hf-hg-1);
                          hh:=Blankweg(3, h7);
                        end;
                      end;
                      h7:=Copy(h5,1,hg-1);
                      h5:=h7;
                    end;
                  end;
                end;
                h7:=Blankweg(2, h5);
                h4:=Length(h7);
                ialpha:=Copy(h7,h4,1);
                if ialpha = ';' then
                begin
                  ialpha:=h7;
                  h7:=Copy(ialpha,1,h4-1);
                end;
                h4:=Length(h7);
                if h4 > 0 then
                begin
                  h6:=Copy(h7,h4,1);
                  if h6 = ';' then
                  begin
                    h6:=h7;
                    h7:=Copy(h6,1,h4-1);
                  end;
                end;
                if prozzaehl < 500 then
                begin
                  he:=1;
                  prozzaehl:=prozzaehl+1;
                  prozname[prozzaehl].einheit:=einheitname;
                  prozname[prozzaehl].kurzbeschreibung:='';
                  h3:=Length(hh);
                  if h3 > 0 then
                  begin
                    prozname[prozzaehl].kurzbeschreibung:=hh;
                  end;
                  prozname[prozzaehl].langbeschreibunganz:=0;
                  SetLength(prozname[prozzaehl].langbeschreibung, 0);
                  prozname[prozzaehl].name:=h7;
                end else begin
                  Label2.Caption:='Anzahl Proceduren/Funktionen größer 500, Abbruch';
                  h8:=9;
                end;
              end;
              if hc = 0 then
              begin
                if ((h8 = 1) or (h8 = 3)) then
                begin
                  if he = 2 then
                  begin
                    h6:=Copy(h5,1,4);
                    if LowerCase(h6) = 'end;' then
                    begin
                      he:=0;
                    end else begin
                      h7:=Blankweg(3, h5);
                      h4:=Length(h7);
                      if h4 > 0 then
                      begin
                        h6:=Copy(h7,h4,1);
                        if h6 = ';' then
                        begin
                          h6:=h7;
                          h7:=Copy(h6,1,h4-1);
                        end;
                        h6:=Copy(h7,1,2);
                        if h6 <> '//' then
                        begin
                          h5:=prozname[prozzaehl].name;
                          prozname[prozzaehl].name:=h5+'; '+h7;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
              if hc = 0 then
              begin
                if ((h8 = 1) or (h8 = 3)) then
                begin
                  if he = 1 then
                  begin
                    he:=2;
                  end;
                end;
              end;
              if hc = 1 then
              begin
                if ((h8 = 2) or (h8 = 3)) then
                begin
                  h6:='';
                  h9:=1;
                  ha:='';
                  hb:='';
                  hh:='';
                  for h3:=1 to h2 do
                  begin
                    h7:=Copy(h5,h3,1);
                    hd:=' ';
                    if h9 > 1 then hd:=';';
                    if h7 = hd then
                    begin
                      h4:=Length(h6);
                      if h4 > 0 then
                      begin
                        if h6 <> 'var' then
                        begin
                          if h9 = 1 then ha:=h6;
                          if h9 = 2 then hb:=h6;
                          h9:=h9+1;
                        end;
                      end;
                      h6:='';
                    end else begin
                      h6:=h6+h7;
                    end;
                  end;
                  h6:=hb;
                  hb:=Blankweg(3, h6);
                  h4:=Length(h6);
                  if h4 > 0 then
                  begin
                    if h6 <> 'var' then
                    begin
                      if h9 = 1 then ha:=h6;
                      if h9 = 2 then hb:=h6;
                      h9:=h9+1;
                    end;
                  end;
                  if h9 > 1 then
                  begin
                    h4:=Length(ha);
                    if h4 > 0 then
                    begin
                      h6:=Copy(ha,h4,1);
                      if h6 = ':' then
                      begin
                        h6:=ha;
                        ha:=Copy(h6,1,h4-1);
                      end;
                    end;
                    h4:=Length(hb);
                    if h4 > 0 then
                    begin
                      h6:=Copy(hb,h4,1);
                      if h6 = ';' then
                      begin
                        h6:=hb;
                        hb:=Copy(h6,1,h4-1);
                      end;
                    end;
                    if ha <> '//' then
                    begin
                      hf:=Length(h5);
                      if hf > 0 then
                      begin
                        he:=0;
                        h6:='';
                        for h3:=1 to hf do
                        begin
                          if he = 0 then
                          begin
                            h7:=Copy(h5,h3,1);
                            if h7 = ';' then
                            begin
                              he:=h3;
                            end else begin
                              h6:=h6+h7;
                            end;
                          end;
                        end;
                        h3:=Length(h6);
                        if h3 > 0 then
                        begin
                          if he > 0 then
                          begin
                            if hf > he+1 then
                            begin
                              h4:=he+1;
                              he:=0;
                              h6:='';
                              for h3:=h4 to hf do
                              begin
                                if he = 0 then
                                begin
                                  h7:=Copy(h5,h3,1);
                                  if h7 = '/' then
                                  begin
                                    he:=h3;
                                  end else begin
                                    h6:=h6+h7;
                                  end;
                                end;
                              end;
                              h3:=Length(h6);
                              if h3 > 0 then
                              begin
                                if he > 0 then
                                begin
                                  if hf > he+1 then
                                  begin
                                    h7:=Copy(h5,he+1,1);
                                    if h7 = '/' then
                                    begin
                                      if hf > he+2 then
                                      begin
                                        hh:=Copy(h5,he+2,hf-he-1);
                                      end;
                                    end;
                                  end;
                                end;
                              end;
                            end;
                          end;
                        end;
                      end;
                      if varzaehl < 500 then
                      begin
                        varzaehl:=varzaehl+1;
                        varname[varzaehl].einheit:=einheitname;
                        varname[varzaehl].kurzbeschreibung:='';
                        h3:=Length(hh);
                        if h3 > 0 then
                        begin
                          h7:=hh;
                          hh:=Blankweg(3, h7);
                          varname[varzaehl].kurzbeschreibung:=hh;
                        end;
                        varname[varzaehl].name:=ha;
                        varname[varzaehl].art:=hb;
                      end else begin
                        Label2.Caption:='Anzahl Variablen größer 500, Abbruch';
                        h8:=9;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        CloseFile(fileadr);
      end else begin
        Label2.Caption:='File '+filename+' nicht vorhanden, Abbruch';
        h8:=9;
      end;
      if ((prozzaehl > 0) and (varzaehl > 0)) then
      begin
        if Datenanzeigeart = 1 then
        begin
          LadenVariable;
          Label2.Caption:='Anzahl Variable: '+IntToStr(varzaehl);
        end;
        if Datenanzeigeart = 2 then
        begin
          LadenProcedure;
          Label2.Caption:='Anzahl Procedures: '+IntToStr(prozzaehl);
        end;
        Button1.Visible:=True;
        Button3.Visible:=True;
        Button4.Visible:=True;
        Button5.Visible:=True;
        Button6.Visible:=True;
        Button7.Visible:=True;
      end else begin
        if ((mtasts = 0) and (h8 <> 9)) then
        begin
          Label2.Caption:='keine Variablen='+IntToStr(varzaehl)+' und/oder Procedure/Function='+IntToStr(prozzaehl)+' vorhanden, Abbruch';
        end;
      end;
      mtasts:=1;
      gridklick:=True;
    end else begin
      Label2.Caption:='Unit muss ausgewählt werden';
      Form1.ActiveControl:=ComboBox1;
    end;
  end;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);
  var h1: integer;
  var h2: integer;
  var h3: integer;
begin
  if mlauf = 2 then
  begin
    h1:=Ord(Key);
    if h1 = 27 then
    begin
      JaNein:=messagedlg('Element löschen ?', mtConfirmation, [mbYes, mbNo], 0);
      if (JaNein = mrYes) then
      begin
        if Datenanzeigeart = 1 then
        begin
          if tabnummer < varzaehl then
          begin
            for h1:=tabnummer to varzaehl-1 do
            begin
              varname[h1].einheit:=varname[h1+1].einheit;
              varname[h1].name:=varname[h1+1].name;
              varname[h1].art:=varname[h1+1].art;
              varname[h1].kurzbeschreibung:=varname[h1+1].kurzbeschreibung;
            end;
          end;
          varzaehl:=varzaehl-1;
          LadenVariable;
        end else begin
          if tabnummer < varzaehl then
          begin
            for h1:=tabnummer to varzaehl-1 do
            begin
              prozname[h1].einheit:=prozname[h1+1].einheit;
              prozname[h1].name:=prozname[h1+1].name;
              prozname[h1].kurzbeschreibung:=prozname[h1+1].kurzbeschreibung;
              prozname[h1].langbeschreibunganz:=prozname[h1+1].langbeschreibunganz;
              SetLength(prozname[h1].langbeschreibung, 0);
              h2:=prozname[h1].langbeschreibunganz;
              if h2 > 0 then
              begin
                SetLength(prozname[h1].langbeschreibung, h2);
                for h3:=0 to h2-1 do
                begin
                  prozname[h1].langbeschreibung[h3]:=prozname[h1+1].langbeschreibung[h3];
                end;
              end;
            end;
          end;
          prozzaehl:=prozzaehl-1;
          LadenProcedure;
        end;
        Edit1.ReadOnly:=True;
        Edit1.Color:=clSilver;
        Edit1.AutoSelect:=False;
        Edit1.Text:='';
        Memo1.Lines.Clear;
        Label9.Caption:='';
        egrid:=0;
        gridklick:=True;
        mtasts:=1;
        mlauf:=1;
      end;
    end else begin
      itaste:=Key;
      FeldEingabe(Form1.Edit1);
      Key:=itaste;
    end;
  end;
end;

procedure TForm1.Edit1KeyUp(Sender: TObject; var Key: Word);
  var h1: string;
begin
  if mlauf = 2 then
  begin
    if ((istell = ilanmax) and (ord(itaste) > 0) and (iautocr = 1)) then
    begin
      Key:=ord(chr(13));
    end;
    if ord(Key) = 13 then
    begin
      istell:=0;
      Label2.Caption:='';
      Edit1.ReadOnly:=True;
      Edit1.Color:=clSilver;
      Edit1.AutoSelect:=False;
      h1:=Blankweg(3, ialpha);
      if Datenanzeigeart = 2 then
      begin
        prozname[tabnummer].kurzbeschreibung:=h1;
        mlauf:=3;
        LadenProcedure;
        Memo1.Color:=$0080FFFF;
        Memo1.ReadOnly:=False;
        Form1.ActiveControl:=Memo1;
      end else begin
        varname[tabnummer].kurzbeschreibung:=h1;
        LadenVariable;
        gridklick:=True;
        mtasts:=1;
        mlauf:=1;
      end;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
  var h1: Boolean;
  var h2: integer;
  var h3: integer;
  var h4: integer;
  var h5: string;
  var h6: string;
  var h7: string;
  var h8: integer;
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  Label2.Caption:='';
  if (mtasts = 1) then
  begin
    mtasts:=0;
    mlauf:=0;
    egrid:=0;
    gridklick:=False;
    AnzeigeLoe;
    Button1.Visible:=True;
    Button3.Visible:=False;
    Button4.Visible:=False;
    Button5.Visible:=False;
    Button6.Visible:=True;
    Button7.Visible:=False;
    Button3.Caption:='Ansicht globale Variable';
    progname:='';
    unitzaehlt:=0;
    unitzaehl:=0;
    varzaehl:=0;
    prozzaehl:=0;
    einheitname:='';
    Datenanzeigeart:=1;
    if Datenanzeigeart = 1 then
    begin
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=3;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=600;
      StringGrid1.ColWidths[1]:=600;
      StringGrid1.ColWidths[2]:=1500;
      StringGrid1.Cells[0, 0]:='Variablenname';
      StringGrid1.Cells[1, 0]:='Variablentype';
      StringGrid1.Cells[2, 0]:='Variablenkurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
      StringGrid1.Cells[2, 1]:='';
    end;
    if Datenanzeigeart = 2 then
    begin
      StringGrid1.RowCount:=2;
      StringGrid1.ColCount:=2;
      StringGrid1.FixedRows:=1;
      StringGrid1.ColWidths[0]:=1800;
      StringGrid1.ColWidths[1]:=1500;
      StringGrid1.Cells[0, 0]:='Procedure/Funktion-Name';
      StringGrid1.Cells[1, 0]:='Procedure/Funktion-Kurzbeschreibung';
      StringGrid1.Cells[0, 1]:='';
      StringGrid1.Cells[1, 1]:='';
    end;
    OpenDialog1.DefaultExt:='lpr';
    OpenDialog1.Filter:='Lazarus-Projektfile|*.lpr';
    OpenDialog1.Title:='Lazarus-Projekt';
    h1:=OpenDialog1.Execute;
    if h1 then
    begin
      h2:=Length(OpenDialog1.FileName);
      if h2 > 4 then
      begin
        h3:=0;
        for h4:=1 to h2 do
        begin
          h5:=Copy(OpenDialog1.FileName,h4,1);
          if h5 = '\' then h3:=h4;
        end;
        if h3 > 0 then
        begin
          if h3 < h2 then
          begin
            pfad:=Copy(OpenDialog1.FileName,1,h3);
            filename:=Copy(OpenDialog1.FileName,h3+1,h2-h3);
            if FileExists(OpenDialog1.FileName) then
            begin
              assignFile(fileadr, OpenDialog1.FileName);
              Reset(fileadr);
              h8:=0;
              While Not EOF(fileadr) do
              begin
                readLn(fileadr, h6);
                h5:=Blankweg(1, h6);
                h2:=Length(h5);
                if h2 > 0 then
                begin
                  h6:='';
                  h4:=0;
                  for h3:=1 to h2 do
                  begin
                    if h4 = 0 then
                    begin
                      h7:=Copy(h5,h3,1);
                      if h7 = ' ' then
                      begin
                        h4:=h3;
                      end else begin
                        h6:=h6+h7;
                      end;
                    end;
                  end;
                  h3:=Length(h6);
                  if h3 > 0 then
                  begin
                    if ((h8 = 0) and (h6 = 'program')) then
                    begin
                      if h4 < h2 then
                      begin
                        progname:=Copy(h5,h4+1,h2-h4-1);
                        h8:=1;
                        Label6.Caption:='Projekt: '+progname;
                      end;
                    end;
                    if h8 = 2 then
                    begin
                      h6:=Copy(h5,1,1);
                      if h6 = '{' then h8:=3;
                      if h8 = 2 then
                      begin
                        h6:='';
                        for h3:=1 to h2 do
                        begin
                          h7:=Copy(h5,h3,1);
                          if h7 = ',' then
                          begin
                            h4:=Length(h6);
                            if h4 > 0 then
                            begin
                              if unitzaehlt < 50 then
                              begin
                                unitzaehlt:=unitzaehlt+1;
                                unitnamet[unitzaehlt, 1]:=h6;
                                unitnamet[unitzaehlt, 2]:='N';
                              end else begin
                                Label2.Caption:='Anzahl Units größer 50, Abbruch';
                                mtasts:=1;
                              end;
                            end;
                            h6:='';
                          end else begin
                            h6:=h6+h7;
                          end;
                        end;
                        h3:=Length(h6);
                        if h3 > 0 then
                        begin
                          if unitzaehlt < 50 then
                          begin
                            unitzaehlt:=unitzaehlt+1;
                            unitnamet[unitzaehlt, 1]:=h6;
                            unitnamet[unitzaehlt, 2]:='N';
                          end else begin
                            Label2.Caption:='Anzahl Units größer 50, Abbruch';
                            mtasts:=1;
                          end;
                        end;
                      end;
                    end;
                    if ((h8 = 1) and (h6 = 'Interfaces,')) then
                    begin
                      h8:=2;
                    end;
                  end;
                end;
              end;
              CloseFile(fileadr);
              if unitzaehlt > 0 then
              begin
                FileListBox1.Directory:=pfad;
                if FileListBox1.Items.Count > 0 then
                begin
                  for h3:=1 to unitzaehlt do
                  begin
                    h7:=LowerCase(unitnamet[h3, 1])+'.pas';
                    h6:=Blankweg(3, h7);
                    h8:=0;
                    for h4:=0 to FileListBox1.Items.Count-1 do
                    begin
                      h7:=LowerCase(FileListBox1.Items.Strings[h4]);
                      if h7 = h6 then h8:=1;
                    end;
                    if h8 = 1 then unitnamet[h3, 2]:='Y';
                  end;
                  for h3:=1 to unitzaehlt do
                  begin
                    h6:=unitnamet[h3, 1];
                    h7:=unitnamet[h3, 2];
                    if h7 = 'Y' then
                    begin
                      if unitzaehl < 50 then
                      begin
                        unitzaehl:=unitzaehl+1;
                        unitnamen[unitzaehl]:=h6;
                      end;
                    end;
                  end;
                  mtasts:=1;
                  if unitzaehl > 0 then
                  begin
                    Label6.Caption:='Projekt: '+progname+'    Anzahl Units: '+IntToStr(unitzaehl);
                    for h3:=1 to unitzaehl do
                    begin
                      h6:=unitnamen[h3];
                      ComboBox1.Items.Add(h6);
                    end;
                    ComboBox1.Enabled:=True;
                    ComboBox1.Color:=$0080FFFF;
                    mlauf:=1;
                    mtasts:=0;
                  end;
                end;
              end else begin
                Label2.Caption:='keine Units vorhanden, Abbruch';
                mtasts:=1;
              end;
            end else begin
              Label2.Caption:='File '+OpenDialog1.FileName+' nicht vorhanden, Abbruch';
              mtasts:=1;
            end;
          end else begin
            Label2.Caption:='Filename nicht zulässig, Abbruch';
            mtasts:=1;
          end;
        end else begin
          Label2.Caption:='Filename nicht zulässig, Abbruch';
          mtasts:=1;
        end;
      end else begin
        Label2.Caption:='Filename nicht zulässig, Abbruch';
        mtasts:=1;
      end;
    end else begin
      mtasts:=1;
    end;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Label1.Caption:=UTF8Encode(#169)+'LINSOFT               P R O G D I A G                   Datum: '+FormatDateTime('DD.MM.YYYY',now);
  if (abbruch) then
  begin
    CanClose:=true;
  end else begin
    Form1.Cursor:=crDefault;
    Form1.Refresh;
    CanClose:=false;
    if (Closestat = 0) then
    begin
      Closestat:=1;
      JaNein:=messagedlg('Programm-Ende ?', mtConfirmation, [mbYes, mbNo], 0);
      Closestat:=0;
      if (JaNein = mrYes) then
      begin
        CanClose:=true;
      end else begin
        mtasts:=1;
      end;
    end;
  end;
end;

function TForm1.Nummer(Komma: Boolean; var Ntextstring: string): string;
  var laenge: integer;
  var stelle: integer;
  var m: integer;
  var zeichen: string;
  var h1: string;
  var h2: string;
  var tt: string;
begin
  laenge:=Length(Ntextstring);
  tt:='';
  if laenge > 0 then
  begin
    Ntextstring:=Blankweg(3, Ntextstring);
    laenge:=Length(Ntextstring);
    if laenge > 0 then
    begin
      tt:=ialpha;
      for stelle:=1 to laenge do
      begin
        zeichen:=Copy(Ntextstring,stelle,1);
        m:=0;
        if zeichen = '0' then
        begin
          m:=1;
        end;
        if zeichen = '1' then
        begin
          m:=1;
        end;
        if zeichen = '2' then
        begin
          m:=1;
        end;
        if zeichen = '3' then
        begin
          m:=1;
        end;
        if zeichen = '4' then
        begin
          m:=1;
        end;
        if zeichen = '5' then
        begin
          m:=1;
        end;
        if zeichen = '6' then
        begin
          m:=1;
        end;
        if zeichen = '7' then
        begin
          m:=1;
        end;
        if zeichen = '8' then
        begin
          m:=1;
        end;
        if zeichen = '9' then
        begin
          m:=1;
        end;
        if ((komma) and (zeichen = '.')) then
        begin
          m:=1;
          h1:='';
          h2:='';
          if stelle > 1 then h1:=Copy(Ntextstring,1,stelle-1);
          if ((stelle > 1) and (stelle < laenge)) then h2:=Copy(Ntextstring,stelle+1,laenge-stelle);
          tt:=h1+','+h2;
        end;
        if ((komma) and (zeichen = ',')) then
        begin
          m:=1;
        end;
        if m = 0 then
        begin
          tt:='';
        end;
      end;
    end;
  end;
  Result:=tt;
end;

end.

