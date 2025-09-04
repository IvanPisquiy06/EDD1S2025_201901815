unit uprogramar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils,
  ulistasimple, ulistadoble, ucola;

type

  { TFormProgramar }

  TFormProgramar = class(TForm)
    ButtonProgramar: TButton;
    EditDestinatario: TEdit;
    EditAsunto: TEdit;
    EditFecha: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MemoMensaje: TMemo;
    procedure ButtonProgramarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
  public
    procedure PrepararProgramacion(u: PUsuario);
  end;

var
  FormProgramar: TFormProgramar;

implementation

{$R *.lfm}

procedure TFormProgramar.PrepararProgramacion(u: PUsuario);
begin
  usuarioActual := u;
end;

procedure TFormProgramar.ButtonProgramarClick(Sender: TObject);
var
  destinatario: PUsuario;
  nuevoCorreo: PCorreo;
  fechaHora: TDateTime;
begin
  if usuarioActual = nil then Exit;

  destinatario := BuscarUsuarioEmail(listaUsuarios, EditDestinatario.Text);
  if destinatario = nil then
  begin
    ShowMessage('Error: Destinatario no disponible');
    Exit;
  end;

  try
    fechaHora := StrToDate(EditFecha.Text);

    New(nuevoCorreo);
    nuevoCorreo^.id := Random(10000);
    nuevoCorreo^.remitente := usuarioActual^.email;
    nuevoCorreo^.estado := 'NL';
    nuevoCorreo^.asunto := EditAsunto.Text;
    nuevoCorreo^.mensaje := MemoMensaje.Text;
    nuevoCorreo^.fecha := DateToStr(fechaHora);
    nuevoCorreo^.programado := True;
    nuevoCorreo^.siguiente := nil;
    nuevoCorreo^.anterior := nil;

    Encolar(usuarioActual^.colaProgramadosFrente,
          usuarioActual^.colaProgramadosFin,
          nuevoCorreo, fechaHora);

    ShowMessage('Correo programado para ' + DateTimeToStr(fechaHora));
    Close;
  except
  on E: Exception do
  begin
    ShowMessage('Formato de fecha invalido');
    Exit;
  end;

  end;
end;

end.

