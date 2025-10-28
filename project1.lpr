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
  ubandeja, urootmenu, uenviar, ucontactos, uagregar, upila, upapelera, ucola,
  uprogramar, uprogramados, uactualizar, ureportes, uarbolavl, uborradores,
  uarbolbst, uarbolb, ufavoritos, ucomunidades, ucrearcomunidad, 
umensajecomunidad, uvermensajes, uhuffman, uhashing, umerkle, uprivados, 
ublockchain, uLZW, ulogcontrol, ulogvisual
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
  Application.CreateForm(TFormProgramar, FormProgramar);
  Application.CreateForm(TFormProgramados, FormProgramados);
  Application.CreateForm(TFormActualizar, FormActualizar);
  Application.CreateForm(TFormBorradores, FormBorradores);
  Application.CreateForm(TFormFavoritos, FormFavoritos);
  Application.CreateForm(TFormCrearComunidad, FormCrearComunidad);
  Application.CreateForm(TFormMensajeComunidad, FormMensajeComunidad);
  Application.CreateForm(TFormVerMensajes, FormVerMensajes);
  Application.CreateForm(TFormPrivados, FormPrivados);
  Application.CreateForm(TFormLogVisual, FormLogVisual);
  Application.Run;
end.

