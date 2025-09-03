program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uprincipal, ulistasimple, ulogin, ucrearusuario, ulistadoble, umenu,
  ubandeja, urootmenu, uenviar, ucontactos, uagregar, upila, upapelera
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFormCrear, FormCrear);
  Application.CreateForm(TFormMenu, FormMenu);
  Application.CreateForm(TFormBandeja, FormBandeja);
  Application.CreateForm(TFormRoot, FormRoot);
  Application.CreateForm(TFormEnviar, FormEnviar);
  Application.CreateForm(TFormContactos, FormContactos);
  Application.CreateForm(TFormAgregar, FormAgregar);
  Application.CreateForm(TFormPapelera, FormPapelera);
  Application.Run;
end.

