unit Main;
// Copyright Manfred Dings 2024
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Menus, inifiles;

const sHelpFile = 'Hilfe.pdf';

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnBerechnen: TButton;
    Button2: TButton;
    CBAllerheiligen: TCheckBox;
    CBReformationstag: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CBReform: TCheckBox;
    CBBusstag: TCheckBox;
    CBFronleichnam: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    DTVeranstaltungsbeginn: TDateTimePicker;
    DTVeranstaltungsende: TDateTimePicker;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    GBSemesterzeiten: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Datei: TMenuItem;
    Beenden: TMenuItem;
    Hilfe: TMenuItem;
    Kurzanleitung: TMenuItem;
    procedure BeendenClick(Sender: TObject);
    procedure BtnBerechnenClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CBAllerheiligenClick(Sender: TObject);
    procedure CBBusstagClick(Sender: TObject);
    procedure CBFronleichnamClick(Sender: TObject);
    procedure CBReformationstagClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure DateTimePicker3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KurzanleitungClick(Sender: TObject);
  private
    { private declarations }
    inifile:Tinifile;
    inipath:string;
    useReformationstag, useBusstag, useAllerheiligen, useFronleichnam: boolean;
    const ininame = 'Veranstaltungsdaten.ini';
    procedure Eintrag_addieren(var s:String;var Date:TDate);
    function FerienOK(sender:TObject):boolean;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

uses dateutils, kalender, shellApi;

function TMainForm.FerienOK(sender:TObject):boolean;
begin
  //Ferien werden nur berücksichtigt, wenn ein gültiger Zeitraum angegeben wurde
  if sender=checkbox1 then
  begin
    result := Datetimepicker2.date >= Datetimepicker1.date
  end
  else
  begin
    result := DateTimePicker4.date >= DateTimePicker3.date
  end;
end;

procedure TMainForm.Eintrag_addieren(var s:String;var Date:TDate);
begin
  s:=s+FormatDateTime('dd.mm.yyyy',Date)+#9;
end;

procedure TMainForm.BtnBerechnenClick(Sender: TObject);
var s:String = '';
    akuerzel:String = '';
    ok:boolean;
    aDate:TDate;
begin
  Memo1.Lines.Clear;
  aDate := DTVeranstaltungsbeginn.Date;
  s := '';
  while ((aDate>=DTVeranstaltungsbeginn.Date)
      and (aDate<=DTVeranstaltungsende.date)) do
  begin
    akuerzel := '';
    ok := true;
    //Prüfen, ob in Ferien
    if FerienOK(checkbox1) then
    if checkbox1.Checked then
    begin
      ok := not ((aDate >= DateTimePicker1.Date) and (ADate <= DateTimePicker2.Date))
    end;
  //Prüfen, ob in Ferien 2
    if checkbox2.Checked then
    if FerienOK(checkbox2) then
    begin
      ok := ok and (not ((aDate>=DateTimePicker3.Date) and (ADate <= DateTimePicker4.Date)))
    end;

  //Prüfen, ob Feiertag
    if ok then ok := not isFeiertag(adate, akuerzel);
  // fakultative Feiertag, je nach Bundesland
    if akuerzel = kuerzelFronleichnam then ok := not useFronleichnam;
    if akuerzel = kuerzelAllerheiligen then ok := not useAllerheiligen;
    if akuerzel = kuerzelRefomrationstag then ok := not useReformationstag;
    if akuerzel = kuerzelBusstag then ok := not useBusstag;
  //Wenn bis hier ok:
    if ok then
    begin
      //Prüfen, ob Wochentag 1
      ok := dayOfTheWeek(adate) = combobox1.ItemIndex;
      if ok then
      begin
        Eintrag_addieren(s,aDate);
        //Wenn Wochentag 2 = Wochentag 1 dann nochmal:
        if combobox1.ItemIndex = combobox2.ItemIndex then
          Eintrag_addieren(s,aDate);
      end
      else
      begin
        //Prüfen, ob Wochentag 2
        ok := dayOfTheWeek(adate)=combobox2.ItemIndex;
        if ok then  Eintrag_addieren(s,aDate);
      end;
    end;
  aDate := aDate+1;
  end;
  Memo1.Lines.Add(s);
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
  Memo1.SelLength:=0;
end;

procedure TMainForm.BeendenClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CBAllerheiligenClick(Sender: TObject);
begin
  useAllerheiligen := CBAllerheiligen.checked;
  BtnBerechnenClick(sender);
end;

procedure TMainForm.CBBusstagClick(Sender: TObject);
begin
  useBusstag := CBBusstag.checked;
  BtnBerechnenClick(sender);
end;

procedure TMainForm.CBFronleichnamClick(Sender: TObject);
begin
  useFronleichnam := CBFronleichnam.checked;
  BtnBerechnenClick(sender);
end;

procedure TMainForm.CBReformationstagClick(Sender: TObject);
begin
  useReformationstag := CBReformationstag.checked;
  BtnBerechnenClick(sender);
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
    if sender=checkbox1 then
  begin
    Groupbox1.Enabled := checkbox1.checked;
    if Groupbox1.enabled then Groupbox1.Font.Color := clwindowtext
    else
    begin
    Groupbox1.Font.Color := clgraytext;
    end;
    datetimepicker1.visible := checkbox1.checked;
    datetimepicker2.visible := checkbox1.checked;
  end
  else
  begin
    GroupBox2.Enabled := checkbox2.checked;
    if GroupBox2.enabled then GroupBox2.Font.Color := clwindowtext
    else
    begin
      GroupBox2.Font.Color := clgraytext;
    end;
    DateTimePicker3.visible := checkbox2.checked;
    DateTimePicker4.visible := checkbox2.checked;
  end;
  BtnBerechnenClick(sender);
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
var vis:boolean;
begin
  vis := (combobox2.ItemIndex < combobox1.Itemindex);
  if (combobox1.ItemIndex = 0) or (combobox2.ItemIndex = 0) then vis := false;
  label9.Visible := vis;
  BtnBerechnenClick(nil)
end;

procedure TMainForm.DateTimePicker1Change(Sender: TObject);
begin
  Label10.Visible:=not FerienOK(checkbox1);
  BtnBerechnenClick(nil)
end;

procedure TMainForm.DateTimePicker3Change(Sender: TObject);
begin
  Label7.Visible := not FerienOK(checkbox2);
  //***********************************************************
  //Wenn das einkommentiert ist, wird bei jeder Aktualisierung
  //der Felder neu berechnet und damit auch die Zwischenablage
  //überschrieben
  BtnBerechnenClick(nil)
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
    inipath := GetAppConfigDir(false)+ininame;
    inifile := tInifile.create(inipath);
    DTVeranstaltungsbeginn.DateTime := inifile.ReadDate('Daten','Veranstaltungsbeginn',now);
    DTVeranstaltungsende.DateTime := inifile.ReadDate('Daten','Veranstaltungsende',now);
    Datetimepicker1.DateTime := inifile.ReadDate('Daten','Ferienbeginn',now);
    Datetimepicker2.DateTime := inifile.ReadDate('Daten','Ferienende',now);
    DateTimePicker3.DateTime := inifile.ReadDate('Daten','FreiAnfang',now);
    DateTimePicker4.DateTime:= inifile.ReadDate('Daten','FreiEnde',now);
    checkbox1.checked := inifile.ReadBool('Daten','Ferien',false);
    CBAllerheiligen.checked := inifile.ReadBool('Daten','UseAllerheiligen',true);
    useAllerheiligen := CBAllerheiligen.checked;
    CBReformationstag.checked := inifile.ReadBool('Daten','UseReformationstag',false);
    useReformationstag := CBReformationstag.checked;
    CBBusstag.checked := inifile.ReadBool('Daten','UseBusstag',false);
    useBusstag := CBBusstag.checked;
    CBFronleichnam.checked := inifile.ReadBool('Daten','UseFronleichnam',true);
    useFronleichnam := CBFronleichnam.checked;
    GBSemesterzeiten.Enabled := checkbox1.Enabled;
    checkbox2.checked := inifile.ReadBool('Daten','Ferien2',false);
    GroupBox1.Enabled := checkbox2.Enabled;
    CheckBox1Click(checkbox1);
    CheckBox1Click(checkbox2);
    Combobox1.ItemIndex := inifile.ReadInteger('Daten','Wochentag1',0);
    Combobox2.ItemIndex := inifile.ReadInteger('Daten','Wochentag2',0);
    DateTimePicker1Change(nil);
    DateTimePicker3Change(nil);
    combobox1change(nil);
    btnBerechnenclick(nil);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  inifile.WriteDate('Daten','Veranstaltungsbeginn',DTVeranstaltungsbeginn.DateTime);
  inifile.WriteDate('Daten','Veranstaltungsende',DTVeranstaltungsende.DateTime);

  inifile.WriteDate('Daten','Ferienbeginn',Datetimepicker1.DateTime);
  inifile.WriteDate('Daten','Ferienende',Datetimepicker2.DateTime);
  inifile.WriteDate('Daten','FreiAnfang',DateTimePicker3.DateTime);
  inifile.WriteDate('Daten','FreiEnde',DateTimePicker4.DateTime);
  inifile.WriteBool('Daten','Ferien',checkbox1.checked);
  inifile.WriteBool('Daten','Ferien2',checkbox2.checked);
  inifile.WriteInteger('Daten','Wochentag1',Combobox1.ItemIndex);
  inifile.WriteInteger('Daten','Wochentag2',Combobox2.ItemIndex);

  inifile.WriteBool('Daten','UseAllerheiligen',useAllerheiligen);
  inifile.WriteBool('Daten','UseReformationstag',useReformationstag);
  inifile.WriteBool('Daten','UseBusstag',useBusstag);
  inifile.WriteBool('Daten','UseFronleichnam',useFronleichnam);
  inifile.writeString('Daten','Path',inipath);
  inifile.Free
end;

procedure TMainForm.KurzanleitungClick(Sender: TObject);
begin
    if fileexists(sHelpFile) then
  begin
    if ShellExecute(0, 'open',
             pchar(sHelpFile), nil, nil,
             1)<=32 then
    begin
      MessageDlg('Fehler','Kann Hilfe-Datei nicht starten.', mtError, [mbOK],0);
    end;
  end;
end;

end.

