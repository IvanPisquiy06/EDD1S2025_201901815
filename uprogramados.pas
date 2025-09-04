unit uprogramados;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils, ulistasimple, ucola, ulistadoble;

type

  { TFormProgramados }

  TFormProgramados = class(TForm)
    ButtonEnviar: TButton;
    Label1: TLabel;
    ListBoxProgramados: TListBox;
    procedure ButtonEnviarClick(Sender: TObject);
  private
    usuarioActual: PUsuario;
    procedure CargarCola;
  public
    procedure AbrirProgramados(u: PUsuario);
  end;

var
  FormProgramados: TFormProgramados;

implementation

{$R *.lfm}

procedure TFormProgramados.CargarCola;
var
  aux: PElementoCola;
begin
  ListBoxProgramados.Clear;
  aux := usuarioActual^.colaProgramadosFrente;
  while aux <> nil do
  begin
    ListBoxProgramados.Items.Add(aux^.correo^.asunto + ' -> ' + DateTimeToStr(aux^.fechaHora));
    aux := aux^.siguiente;
  end;
end;

procedure TFormProgramados.AbrirProgramados(u: PUsuario);
begin
  usuarioActual := u;
  CargarCola;
end;

procedure TFormProgramados.ButtonEnviarClick(Sender: TObject);
var
  aux: PElementoCola;
  ahora: TDateTime;
  correo: PCorreo;
  destinatario: PUsuario;
begin
  ahora := Now;

  aux := usuarioActual^.colaProgramadosFrente;
  while (usuarioActual^.colaProgramadosFrente <> nil) and (usuarioActual^.colaProgramadosFrente^.fechaHora <= ahora) do
  begin
    correo := Desencolar(usuarioActual^.colaProgramadosFrente, usuarioActual^.colaProgramadosFin);

    if correo <> nil then
    begin
      destinatario := BuscarUsuarioEmail(listaUsuarios, correo^.destinatario);
      if destinatario <> nil then
         InsertarCorreo(destinatario^.bandejaEntrada, correo^.id, correo^.remitente, correo^.destinatario,
                        correo^.estado, correo^.asunto, DateTimeToStr(ahora),
                        correo^.mensaje, False);
    end;
    aux := usuarioActual^.colaProgramadosFrente;
  end;

  ShowMessage('Correos programados enviados');
  CargarCola;
end;

end.

