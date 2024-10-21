unit Eingabe;

interface

uses
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

var
  itaste:   char;     // Tastencode
  ifunc:    integer;  // Funktion
                      // 1 = nummerisch ohne Komma ohne Vorzeichen
                      // 2 = nummerich ohne Komma mit Vorzeichen
                      // 3 = nummerisch mit Komma ohne Vorzeichen
                      // 4 = nummerisch mit Komma mit Vorzeichen
                      // 5 = Alphanummerisch
                      // 6 = Datum
                      // 7 = Telefonnummer
                      // 8 = Uhrzeit
   ilanmax: integer;  // Eingabelaenge maximal
   ilanmin: integer;  // Eingabelaenge minimal
   ikomma:  integer;  // Anzahl Nachkommastellen
   iart:    integer;  // Eingabeart
                      // 1 = vorher/nachher anzeigen
                      // 2 = nachher anzeigen
                      // 3 = Stern anzeigen
                      // 4 = nicht anzeigen
                      // 5 = Überschreiben (nur bei ifunc=5)
                      // 6 = Einfügen (nur bei ifunc=5)
   izeich:  integer;  // Zeichenart
                      // 1 = nur Kleinbuchstaben
                      // 2 = nur Grossbuchstaben
                      // 3 = Gross- und Kleinbuchstaben
   iautocr: integer;  // Automatischer Feldsprung
                      // 0 = nein
                      // 1 = ja
   istell:  integer;  // Eingabestelle (vorher immer 0)
   imkom:   integer;  // Merker ob Komma eingegeben worden
   iminus:  integer;  // Merker Plus/Minus 0/1
   ialpha:  string;   // Eingabefeld Alphanummerisch
   inummer: integer;  // Eingabefeld nummerisch mit Vorzeichen
   inumkom: double;   // Eingabefeld nummerisch mit Vorueichen und Komma
   ivz: integer;
   ivk: integer;
   iko: integer;
   ink: integer;
   ivkl: integer;
   procedure FeldEingabe(einfeld: TEdit);

implementation

procedure FeldEingabe(einfeld: TEdit);
 var numm:    integer;
 var htaste:  char;
 var hstell:  integer;
 var hleer:   string;
 var hstern:  string;
 var xstern:  string;
 var hilf1:   integer;
 var hilf2:   integer;
 var hilf3:   integer;
 var hilf4:   integer;
 var hilf5:   string;
 var hilf6:   string;
 var hilf7:   double;
 var hilf8:   integer;
 var hilf9:   integer;

begin
  if ((iart = 5) and (ifunc = 5)) then
  begin
    hilf1:=einfeld.SelStart+1;
    if (izeich = 1) then
    begin
      hilf5:=itaste;
      hilf6:=LowerCase(hilf5);
      itaste:=hilf6[1];
    end;
    if (izeich = 2) then
    begin
      hilf5:=itaste;
      hilf6:=UpperCase(hilf5);
      itaste:=hilf6[1];
    end;
    if hilf1 > ilanmax then
    begin
      einfeld.Text:=ialpha;
      itaste:=char(0);
    end else begin
      hilf5:='';
      hilf6:='';
      if itaste <> chr(13) then
      begin
        if hilf1 > 1 then
        begin
          hilf5:=Copy(einfeld.Text,1,hilf1-1);
        end;
        if hilf1 < ilanmax then
        begin
          hilf2:=ilanmax-hilf1;
          hilf6:=Copy(einfeld.Text,hilf1+1,hilf2);
        end;
        if itaste = char(8) then
        begin
         ialpha:=hilf5+hilf6;
         hilf1:=hilf1 - 1;
        end else begin
         ialpha:=hilf5+char(itaste)+hilf6;
        end;
        itaste:=char(0);
      end else begin
        ialpha:=einfeld.Text;
      end;
      einfeld.Text:=ialpha;
    end;
    einfeld.SelStart:=hilf1;
    einfeld.Update;
  end else begin
    if ((iart = 6) and (ifunc = 5)) then
    begin
      hilf1:=einfeld.SelStart+1;
      if (izeich = 1) then
      begin
        hilf5:=itaste;
        hilf6:=LowerCase(hilf5);
        itaste:=hilf6[1];
      end;
      if (izeich = 2) then
      begin
        hilf5:=itaste;
        hilf6:=UpperCase(hilf5);
        itaste:=hilf6[1];
      end;
      if hilf1 > ilanmax then
      begin
        einfeld.Text:=ialpha;
        itaste:=char(0);
      end else begin
        hilf5:='';
        hilf6:='';
        if itaste <> chr(13) then
        begin
          if hilf1 > 1 then
          begin
            hilf5:=Copy(einfeld.Text,1,hilf1-1);
          end;
          if hilf1 < ilanmax then
          begin
            hilf2:=ilanmax-hilf1;
            hilf6:=Copy(einfeld.Text,hilf1,hilf2);
          end;
          ialpha:=hilf5+char(itaste)+hilf6;
          itaste:=char(0);
        end;
        einfeld.Text:=ialpha;
      end;
      einfeld.SelStart:=hilf1;
      einfeld.Update;
    end else begin
      if iart > 4 then
      begin
        iart:=1;
      end;
      numm:=ord(itaste);
      hstell:=ilanmax;
      hleer:='';
      hstern:='';
      for hilf1:=1 to ilanmax do
      begin
        hleer:=hleer+' ';
        hstern:=hstern+'*';
      end;
      if (istell = 0) then
      begin
        imkom:=0;
        iminus:=0;
        ivz:=0;
        ivk:=0;
        iko:=0;
        ink:=0;
        ivkl:=0;
        if (ifunc = 2) then
        begin
          ivkl:=ilanmax - 1;
        end;
        if (ifunc = 3) then
        begin
          ivkl:=ilanmax - ikomma - 1;
        end;
        if (ifunc = 4) then
        begin
          ivkl:=ilanmax - ikomma - 2;
        end;
        if (ifunc = 7) then
        begin
          ivkl:=ilanmax - 1;
        end;
        if (iart > 1) then
        begin
          inummer:=0;
          inumkom:=0;
          ialpha:=hleer;
          einfeld.Text:=hleer;
        end else begin
          if (ifunc = 1) then
          begin
            hilf5:='%';
            hilf6:=Format('%d', [ilanmax]);
            hilf5:=hilf5+hilf6+'d';
            ialpha:=Format(hilf5, [inummer]);
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 2) then
          begin
            hilf5:='%-';
            hilf6:=Format('%d', [hstell]);
            hilf5:=hilf5+hilf6+'d';
            ialpha:=Format(hilf5, [inummer]);
            einfeld.Text:=ialpha;
            hilf5:=Copy(ialpha, 1, 1);
            if (hilf5 = '-') then
            begin
              iminus:=1;
            end;
          end;
          if (ifunc = 3) then
          begin
            hilf5:='%';
            hilf4:=ilanmax - ikomma - 1;
            hilf6:=Format('%d', [hilf4]);
            hilf5:=hilf5+hilf6+'.';
            hilf6:=Format('%d', [ikomma]);
            hilf5:=hilf5+hilf6+'f';
            ialpha:=Format(hilf5, [inumkom]);
            einfeld.Text:=ialpha;
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
          if (ifunc = 4) then
          begin
            hilf5:='%-';
            hilf4:=ilanmax - ikomma - 2;
            hilf6:=Format('%d', [hilf4]);
            hilf5:=hilf5+hilf6+'.';
            hilf6:=Format('%d', [ikomma]);
            hilf5:=hilf5+hilf6+'f';
            ialpha:=Format(hilf5, [inumkom]);
            einfeld.Text:=ialpha;
            hilf5:=Copy(ialpha, 1, 1);
            if (hilf5 = '-') then
            begin
              iminus:=1;
            end;
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
          if (ifunc = 5) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 6) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 7) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 8) then
          begin
            einfeld.Text:=ialpha;
          end;
        end;
      einfeld.update;
      end;
      if (istell >= hstell) then
      begin
        itaste:=chr(0);
        numm:=0;
        if (iautocr = 1) then
        begin
          itaste:=chr(13);
          numm:=13;
        end;
      end;
// Tastenwerte 8=Backspace 13=Enter 43=+ 44=, 45=- 46=. 48-57=0-9
      if ((numm = 13) and (istell < ilanmin)) then
      begin
        itaste:=chr(0);
        numm:=0;
        if (istell = 0) then
        begin
          itaste:=chr(13);
          if (ifunc = 1) then
          begin
            hilf5:='%';
            hilf6:=Format('%d', [ilanmax]);
            hilf5:=hilf5+hilf6+'d';
            ialpha:=Format(hilf5, [inummer]);
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 2) then
          begin
            hilf5:='%-';
            hilf6:=Format('%d', [hstell]);
            hilf5:=hilf5+hilf6+'d';
            ialpha:=Format(hilf5, [inummer]);
            einfeld.Text:=ialpha;
            hilf5:=Copy(ialpha, 1, 1);
            if (hilf5 = '-') then
            begin
              iminus:=1;
            end;
          end;
          if (ifunc = 3) then
          begin
            hilf5:='%';
            hilf4:=ilanmax - ikomma - 1;
            hilf6:=Format('%d', [hilf4]);
            hilf5:=hilf5+hilf6+'.';
            hilf6:=Format('%d', [ikomma]);
            hilf5:=hilf5+hilf6+'f';
            ialpha:=Format(hilf5, [inumkom]);
            einfeld.Text:=ialpha;
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
          if (ifunc = 4) then
          begin
            hilf5:='%-';
            hilf4:=ilanmax - ikomma - 2;
            hilf6:=Format('%d', [hilf4]);
            hilf5:=hilf5+hilf6+'.';
            hilf6:=Format('%d', [ikomma]);
            hilf5:=hilf5+hilf6+'f';
            ialpha:=Format(hilf5, [inumkom]);
            einfeld.Text:=ialpha;
            hilf5:=Copy(ialpha, 1, 1);
            if (hilf5 = '-') then
            begin
              iminus:=1;
            end;
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
          if (ifunc = 5) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 6) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 7) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (ifunc = 8) then
          begin
            einfeld.Text:=ialpha;
          end;
          if (iart = 3) then
          begin
            xstern:='';
            if istell > 0 then
            begin
              for hilf9:=1 to istell do
              begin
                xstern:=xstern+'*';
              end;
            end;
            einfeld.Text:=xstern;
          end;
          if (iart = 4) then
          begin
            einfeld.Text:=hleer;
          end;
          einfeld.update;
        end;
      end;
      htaste:=itaste;
      if ((ifunc = 1) or (ifunc = 2) or (ifunc = 3) or (ifunc = 4)) then
      begin
        if ((numm <> 8) and (numm <> 13)) then
        begin
          itaste:=chr(0);
        end;
      end;
      if (ifunc = 6) then
      begin
        if ((numm <> 8) and (numm <> 13)) then
        begin
          itaste:=chr(0);
        end;
      end;
      if (ifunc = 7) then
      begin
        if ((numm <> 8) and (numm <> 13)) then
        begin
          itaste:=chr(0);
        end;
      end;
      if (ifunc = 8) then
      begin
        if ((numm <> 8) and (numm <> 13)) then
        begin
          itaste:=chr(0);
        end;
      end;
      if ((numm = 8) and (istell > 0)) then
      begin
        if (istell = imkom) then
        begin
          imkom:=0;
          iko:=0;
        end;
        istell:=istell - 1;
        if (istell = 0) then
        begin
          iminus:=0;
          ivz:=0;
          ivk:=0;
          iko:=0;
          ink:=0;
          ivkl:=0;
          if (ifunc = 2) then
          begin
            ivkl:=ilanmax - 1;
          end;
          if (ifunc = 3) then
          begin
            ivkl:=ilanmax - ikomma - 1;
          end;
          if (ifunc = 4) then
          begin
            ivkl:=ilanmax - ikomma - 2;
          end;
          if (ifunc = 7) then
          begin
            ivkl:=ilanmax - 1;
          end;
        end;
        if ((ifunc = 1) or (ifunc = 2)) then
        begin
          if (inummer < 0) then
          begin
            inummer:=inummer * -1;
          end;
          hilf7:=inummer;
          hilf7:=hilf7 / 10;
          inummer:=Trunc(hilf7);
          if ((ifunc = 2) and (iminus = 1) and (inummer > 0) and (istell > 0)) then
          begin
            inummer:=inummer * -1;
          end;
        end;
        if ((ifunc = 5) or (ifunc = 6) or (ifunc = 7) or (ifunc = 8)) then
        begin
          hilf5:=ialpha;
          ialpha:='';
          if (istell > 0) then
          begin
            ialpha:=Copy(hilf5, 1, istell);
          end;
          hilf3:=ilanmax - istell;
          for hilf1:=1 to hilf3 do
          begin
            ialpha:=ialpha+' ';
          end;
        end;
      end;
      if ((numm = 8) and (istell = 0)) then
      begin
        itaste:=chr(0);
        numm:=0;
        ivz:=0;
        ivk:=0;
        iko:=0;
        ink:=0;
        ivkl:=0;
        if (ifunc = 2) then
        begin
          ivkl:=ilanmax - 1;
        end;
        if (ifunc = 3) then
        begin
          ivkl:=ilanmax - ikomma - 1;
        end;
        if (ifunc = 4) then
        begin
          ivkl:=ilanmax - ikomma - 2;
        end;
        if (ifunc = 7) then
        begin
          ivkl:=ilanmax - 1;
        end;
      end;
      if ((istell = 0) and (numm <> 13) and (numm <> 0)) then
      begin
        imkom:=0;
        iminus:=0;
        inummer:=0;
        inumkom:=0;
        ialpha:=hleer;
        einfeld.Text:=ialpha;
        if (ifunc = 2) then
        begin
          hilf5:='%-';
          hilf6:=Format('%d', [hstell]);
          hilf5:=hilf5+hilf6+'d';
          ialpha:=Format(hilf5, [inummer]);
          hilf5:=Copy(ialpha, 1, 1);
          if (hilf5 = '-') then
          begin
            iminus:=1;
          end;
        end;
        if (ifunc = 3) then
        begin
          hilf5:='%';
          hilf4:=ilanmax - ikomma - 1;
          hilf6:=Format('%d', [hilf4]);
          hilf5:=hilf5+hilf6+'.';
          hilf6:=Format('%d', [ikomma]);
          hilf5:=hilf5+hilf6+'f';
          ialpha:=Format(hilf5, [inumkom]);
          if (iko = 1) then
          begin
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
        end;
        if (ifunc = 4) then
        begin
          hilf5:='%-';
          hilf4:=ilanmax - ikomma - 2;
          hilf6:=Format('%d', [hilf4]);
          hilf5:=hilf5+hilf6+'.';
          hilf6:=Format('%d', [ikomma]);
          hilf5:=hilf5+hilf6+'f';
          ialpha:=Format(hilf5, [inumkom]);
          hilf5:=Copy(ialpha, 1, 1);
          if (hilf5 = '-') then
          begin
            iminus:=1;
          end;
          if (iko = 1) then
          begin
            for hilf4:=1 to ilanmax do
            begin
              hilf5:=Copy(ialpha, hilf4, 1);
              if (hilf5 = ',') then
              begin
                imkom:=hilf4;
              end;
            end;
          end;
        end;
        if (iart = 3) then
        begin
          xstern:='';
          if istell > 0 then
          begin
            for hilf9:=1 to istell do
            begin
              xstern:=xstern+'*';
            end;
          end;
          einfeld.Text:=xstern;
        end;
        if (iart = 4) then
        begin
          einfeld.Text:=hleer;
        end;
        einfeld.update;
      end;
      if ((ifunc = 5) and (ord(itaste) > 0) and (numm <> 8) and (numm <> 13)) then
      begin
        if (izeich = 1) then
        begin
          hilf5:=itaste;
          hilf6:=LowerCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (izeich = 2) then
        begin
          hilf5:=itaste;
          hilf6:=UpperCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (iart = 3) then
        begin
          itaste:='*';
        end;
        if (iart = 4) then
        begin
          itaste:=' ';
        end;
      end;
      if ((ifunc = 6) and (ord(itaste) > 0) and (numm <> 8) and (numm <> 13)) then
      begin
        if (izeich = 1) then
        begin
          hilf5:=itaste;
          hilf6:=LowerCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (izeich = 2) then
        begin
          hilf5:=itaste;
          hilf6:=UpperCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (iart = 3) then
        begin
          itaste:='*';
        end;
        if (iart = 4) then
        begin
          itaste:=' ';
        end;
      end;
      if ((ifunc = 7) and (ord(itaste) > 0) and (numm <> 8) and (numm <> 13)) then
      begin
        if (izeich = 1) then
        begin
          hilf5:=itaste;
          hilf6:=LowerCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (izeich = 2) then
        begin
          hilf5:=itaste;
          hilf6:=UpperCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (iart = 3) then
        begin
          itaste:='*';
        end;
        if (iart = 4) then
        begin
          itaste:=' ';
        end;
      end;
      if ((ifunc = 8) and (ord(itaste) > 0) and (numm <> 8) and (numm <> 13)) then
      begin
        if (izeich = 1) then
        begin
          hilf5:=itaste;
          hilf6:=LowerCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (izeich = 2) then
        begin
          hilf5:=itaste;
          hilf6:=UpperCase(hilf5);
          itaste:=hilf6[1];
          numm:=ord(itaste);
        end;
        if (iart = 3) then
        begin
          itaste:='*';
        end;
        if (iart = 4) then
        begin
          itaste:=' ';
        end;
      end;
      if ((numm > 47) and (numm < 58)) then
      begin
        if ((ifunc = 1) or (ifunc = 5)) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
        if (ifunc = 6) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
        if (ifunc = 7) then
        begin
          if (ivk < ivkl) then
          begin
            itaste:=htaste;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
        if (ifunc = 8) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
        if ((ifunc = 2) or (ifunc = 3) or (ifunc = 4)) then
        begin
          if (ivk < ivkl) then
          begin
            itaste:=htaste;
            ivk:=ivk + 1;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
        if ((ifunc = 2) or (ifunc = 3) or (ifunc = 4)) then
        begin
          if (iko = 1) then
          begin
            if (ink < ikomma) then
            begin
              itaste:=htaste;
              ivk:=ivk + 1;
              if (iart = 3) then
              begin
                itaste:='*';
              end;
              if (iart = 4) then
              begin
                itaste:=' ';
              end;
            end;
          end;
        end;
      end;
      if (ifunc = 6) then
      begin
        if (numm = 46) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
      end;
      if (ifunc = 7) then
      begin
        if istell = 0 then
        begin
          if (numm = 43) then
          begin
            itaste:=htaste;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
        if (numm = 45) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
      end;
      if (ifunc = 8) then
      begin
        if (numm = 58) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
      end;
      if (ifunc = 5) then
      begin
        if ((numm = 43) or (numm = 45)) then
        begin
          if (istell = 0) then
          begin
            itaste:=htaste;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
      end;
      if ((ifunc = 2) or (ifunc = 4)) then
      begin
        if ((numm = 43) or (numm = 45)) then
        begin
          if (istell = 0) then
          begin
            itaste:=htaste;
            iminus:=1;
            ivz:=1;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
      end;
      if (ifunc = 5) then
      begin
        if (numm = 44) then
        begin
          itaste:=htaste;
          if (iart = 3) then
          begin
            itaste:='*';
          end;
          if (iart = 4) then
          begin
            itaste:=' ';
          end;
        end;
      end;
      if ((ifunc = 3) or (ifunc = 4)) then
      begin
        if (iko = 0) then
        begin
          if (numm = 44) then
          begin
            itaste:=htaste;
            imkom:=istell + 1;
            iko:=1;
            if (iart = 3) then
            begin
              itaste:='*';
            end;
            if (iart = 4) then
            begin
              itaste:=' ';
            end;
          end;
        end;
      end;
      if ((ord(itaste) > 0) and (ord(itaste) <> 8) and (ord(itaste) <> 13) and (numm > 0)) then
      begin
        istell:=istell + 1;
        if ((ifunc = 1) or (ifunc = 2)) then
        begin
          if ((numm <> 43) and (numm <> 45)) then
          begin
            if (inummer < 0) then
            begin
              inummer:=inummer * -1;
            end;
            hilf1:=numm - 48;
            inummer:=inummer * 10;
            inummer:=inummer + hilf1;
            if ((ifunc = 2) and (iminus = 1) and (inummer > 0)) then
            begin
              inummer:=inummer * -1;
            end;
          end;
        end;
        if ((ifunc = 3) or (ifunc = 4)) then
        begin
          if ((numm <> 43) and (numm <> 44) and (numm <> 45)) then
          begin
            if (inumkom < 0) then
            begin
              inumkom:=inumkom * -1;
            end;
            hilf1:=numm - 48;
            hilf2:=Trunc(inumkom);
            hilf4:=0;
            if (imkom > 0) then
            begin
              hilf4:=istell - imkom;
            end;
            if (hilf4 > 0) then
            begin
              hilf7:=hilf1;
              for hilf8:=1 to hilf4 do
              begin
                hilf7:=hilf7 / 10;
              end;
              inumkom:=inumkom + hilf7;
            end else begin
              hilf2:=hilf2 * 10;
              hilf2:=hilf2 + hilf1;
              inumkom:=hilf2;
            end;
            if ((ifunc = 4) and (iminus = 1) and (inumkom > 0)) then
            begin
              inumkom:=inumkom * -1;
            end;
          end;
        end;
        if (ifunc = 5) then
        begin
          Insert(chr(numm),ialpha,istell);
          hilf3:=ilanmax + 1;
          Delete(ialpha, hilf3, 1);
        end;
        if (ifunc = 6) then
        begin
          Insert(chr(numm),ialpha,istell);
          hilf3:=ilanmax + 1;
          Delete(ialpha, hilf3, 1);
        end;
        if (ifunc = 7) then
        begin
          Insert(chr(numm),ialpha,istell);
          hilf3:=ilanmax + 1;
          Delete(ialpha, hilf3, 1);
        end;
        if (ifunc = 8) then
        begin
          Insert(chr(numm),ialpha,istell);
          hilf3:=ilanmax + 1;
          Delete(ialpha, hilf3, 1);
        end;
      end;
      if ((itaste = ' ') and (iart = 4)) then
      begin
        itaste:=chr(0);
      end;
    end;
  end;
end;

end.

