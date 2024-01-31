unit kalender;{enth‰lt Routinen zu Osterdatum und Feiertagen}
// Copyright Manfred Dings 2024
interface

uses sysutils;

const kuerzelFronleichnam = 'Fron';
const kuerzelRefomrationstag = 'Refo';
const kuerzelAllerheiligen = 'Alh';
const kuerzelBusstag = 'Buﬂt';

{gibt zu Datum den Namen eines ARBEEITSFREIEN Feiertages oder
Leer, wenn kein Feiertag}
Function Feiertagsname(tag,monat,jahr:integer;var Kuerzel:string):string;

// True, wenn Feiertag; zus‰tzlich wird Kuerzel ¸bergeben
Function IsFeiertag(adate:TDate; var Kuerzel:String):boolean;

implementation

uses DateUtils;

// Julianisches Datum
// Algorithmus nach Jean Meeus
// Copyright (c) 1991-1992 by Jeffrey Sax
// modifiziert Manfred Dings
function JulDatum(const tag, monat, jahr: integer):double;
var
  A, B, m, y : integer;
  D : double;
begin
  D := tag;
  if (monat > 2) then
  begin
    y := jahr;
    m := monat;
  end
  else
  begin
    y := jahr - 1;
    m := monat + 12;
  end;
  A := y div 100;
  if (jahr < 1582) or ((jahr = 1582) and ((monat < 10)
    or ((monat = 10) and (tag <= 4)))) then
  B := 0
  else
  B := 2 - A + A div 4;
  result := int(365.25 * (Y + 4716)) + int(30.6001 * (M + 1)) + D + B - 1524.5;
end;

function Wochentag(Tageszahl:double):byte;{gibt f¸r Sonntag = 1, Montag = 2 ... Samstag = 7}
var x:byte;
begin
  x := trunc((Tageszahl - 4)) mod 7;
  if x = 0 then result := 7 else result := x;
end;{Wochentag}

// Berechnung Osterdatum nach Gauss
procedure Osterdatum(var tag, monat, jahr:integer);
var x, a, b, c, d, e, f, g, h, i, K, L, M, y, month, P, day:integer;
begin
  x := jahr;
  if jahr >= 1583 then
  begin
    a := x Mod 19;
    b := x div 100;
    c := x Mod 100;
    d := b div 4;
    e := b Mod 4;
    f := (b + 8) div 25;
    g := (b - f + 1) div 3;
    h := (19 * a + b - d - g + 15) Mod 30;
    K := c Mod 4;
    i := c div 4;
    L := (32 + 2 * e + 2 * i - h - K) Mod 7;
    M := (a + 11 * h + 22 * L) div 451;
    y := h + L - 7 * M + 114;
    month := y div 31;
    P := y Mod 31;
    day := P + 1;
    monat := month;
    tag := day;
    jahr := x
  end
  else
  begin
    a := x Mod 4;
    b := x Mod 7;
    c := x Mod 19;
    d := (19*c+15) Mod 30;
    e := (2*a+4*b-d+34) Mod 7;
    y := d+e+114;
    f := y div 31;
    g := y Mod 31;
    monat := f;
    tag := g + 1;
    jahr := x
  end;
end;{Osterdatum}

{Berechnet, ob es in Jahr einen Schalttag gibt}
Function Schalttag(Jahr:integer):byte;
begin
    result := 0;
    if (Jahr Mod 400) = 0 then result := 1
    else
    if (Jahr Mod 100) = 0 then result := 0
    else
    if (Jahr Mod 4) = 0 then result := 1;
end; {Funktion Schalttag}

{gibt zu Datum den Namen eines ARBEEITSFREIEN Feiertages oder leer,
wenn kein Feiertag, dazu eine Abk¸rzung}
Function Feiertagsname(tag,monat,jahr:integer; var Kuerzel:String):string;
    var day, month, year:integer;
        JDatum, JDOstern, JDAdvent1, JDHeiligabend:double;
begin
    JDatum:=JulDatum(tag,monat,jahr);
    Feiertagsname := '';
    // In Tag, Monat, Jahr steht anschlieﬂend das Osterdatum
    // Fragliches Datum alsoin day, month, year sichern
    day := Tag;
    month := Monat;
    year := Jahr;
    Osterdatum(tag,monat,jahr);
    JDOstern := JulDatum(tag,monat,Jahr);
    JDHeiligabend := JulDatum(24,12,year);
    JDAdvent1 := JDHeiligabend - Wochentag(JDHeiligabend) - 21;
    {feste Feiertage}
    if (month = 1) and (day = 1) then
    begin
      Feiertagsname := 'Neujahr'; kuerzel := 'Neuj'
    end
    else
    if (month = 5) and (day = 1) then
    begin Feiertagsname := 'Tag der Arbeit'; kuerzel := 'TdAr' end else
    if (month =  8)  and (day = 15) then begin Feiertagsname := 'Mari‰ Himmelfahrt' ;kuerzel := 'MaHi' end else
    if (month =  6)  and (day = 17) and (year>1953)and (year<1990) then begin Feiertagsname := 'Tag der deutschen Einheit' ;kuerzel:='TdEi'end else
    if (month = 10) and (day = 3) and (year>1989) then begin feiertagsname := 'Tag der deutschen Einheit'; kuerzel:='TdEi'end else
    if (month = 11) and (day = 1) then begin Feiertagsname := 'Allerheiligen' ;kuerzel:= kuerzelAllerheiligen; end else
    if (month = 12) and (day = 25) then begin Feiertagsname := '1. Weihnachtstag' ;kuerzel := '1.We' end else
    if (month = 12) and (day = 26) then begin Feiertagsname := '2. Weihnachtstag' ;kuerzel := '2.We' end else
    if (month = 12) and (day = 31) then begin Feiertagsname := 'Silvester' ;kuerzel :='Silv' end else
    if (month = 10) and (day = 31) then begin Feiertagsname := 'Reformationstag' ;kuerzel := kuerzelRefomrationstag end else
    {Bewegliche Feiertage nach Osterdatum}
    if (JDatum = (JDOstern-48)) then begin Feiertagsname := 'Rosenmontag'; kuerzel := 'RosM' end else
//    if (JDatum = (JDOstern-46)) then begin Feiertagsname:='Aschermittwoch'; kuerzel := 'Asch'end else
    if (JDatum = (JDOstern     )) then begin Feiertagsname := 'Ostern'; kuerzel := 'OsSo' end else
    if (JDatum = (JDOstern +  1)) then begin Feiertagsname := 'Ostermontag';kuerzel := 'OsMo' end else
    if (JDatum = (JDOstern -  2))  then begin Feiertagsname := 'Karfreitag'; kuerzel := 'Karf' end else
    if (JDatum = (JDOstern + 39)) then begin Feiertagsname := 'Himmelfahrt';kuerzel := 'Himf' end else
    if (JDatum = (JDOstern + 49)) then begin Feiertagsname := 'Pfingstsonntag'; kuerzel := 'PfSo'end else
    if (JDatum = (JDOstern + 50)) then begin Feiertagsname := 'Pfingstmontag'; kuerzel := 'PfMo' end else
    if (JDatum = (JDOstern + 60)) then begin Feiertagsname := 'Fronleichnam'; kuerzel := kuerzelFronleichnam end else
    if JDatum=(JDAdvent1+1)        then begin Feiertagsname := '1. Advent'; kuerzel := '1.Ad' end else
{Bewegliche Feiertage nach 1. Advent}
//Buﬂtag vor/nach 1995 ggf. aus/einkommentieren
 if ((JDatum = (JDAdvent1 - 10)){ and (year < 1995)}) then begin Feiertagsname := 'Buﬂtag'; kuerzel := kuerzelBusstag end
end;{Funktion Feiertagsname}

Function IsFeiertag(adate:TDate; var Kuerzel:String):boolean;
begin
  result := Feiertagsname(dayOf(adate),monthOf(adate),yearOf(adate),Kuerzel) <> ''
end;


end.
