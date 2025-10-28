unit umenu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ubandeja, ulistasimple, uenviar, ucontactos, uagregar, upapelera, uprogramar, uprogramados,
  uactualizar, ureportes, uborradores, ufavoritos, umensajecomunidad, uprivados, ulogcontrol, FileUtil;

type

  { TFormMenu }

  TFormMenu = class(TForm)
    ButtonPrivados: TButton;
    ButtonPublicarMensaje: TButton;
    ButtonFavoritos: TButton;
    ButtonBandeja: TButton;
    ButtonBorradores: TButton;
    ButtonEnviar: TButton;
    ButtonPapelera: TButton;
    ButtonProgramar: TButton;
    ButtonProgramados: TButton;
    ButtonAgregar: TButton;
    ButtonContactos: TButton;
    ButtonActualizar: TButton;
    ButtonReportes: TButton;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  procedure ButtonBandejaClick(Sender: TObject);
  procedure ButtonBorradoresClick(Sender: TObject);
  procedure ButtonEnviarClick(Sender: TObject);
  procedure ButtonContactosClick(Sender: TObject);
  procedure ButtonAgregarClick(Sender: TObject);
  procedure ButtonFavoritosClick(Sender: TObject);
  procedure ButtonPapeleraClick(Sender: TObject);
  procedure ButtonPrivadosClick(Sender: TObject);
  procedure ButtonProgramarClick(Sender: TObject);
  procedure ButtonProgramadosClick(Sender: TObject);
  procedure ButtonActualizarClick(Sender: TObject);
  procedure ButtonPublicarMensajeClick(Sender: TObject);
  procedure ButtonReportesClick(Sender: TObject);
  private

  public
  UsuarioActual: PUsuario;
  sesionActual: PLogSession;
  end;

var
  FormMenu: TFormMenu;

implementation
uses ulogin, ublockchain;

{$R *.lfm}

procedure TFormMenu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CerrarSesionLog(sesionActual);
end;

procedure TFormMenu.ButtonBandejaClick(Sender: TObject);
begin

  if UsuarioActual = nil then
  begin
    ShowMessage('Error fatal: No se pudo identificar al usuario actual.');
    Exit;
  end;

  FormBandeja := TFormBandeja.Create(Self);
  try
    FormBandeja.CargarBandeja(UsuarioActual);
    FormBandeja.ShowModal;
  finally
    FormBandeja.Free;
  end;
end;

procedure TFormMenu.ButtonBorradoresClick(Sender: TObject);
var
  FormularioBorradores: TFormBorradores;
begin
  FormularioBorradores := TFormBorradores.Create(Application);
  try
    FormularioBorradores.AbrirBorradores(UsuarioActual);
    FormularioBorradores.ShowModal;
  finally
    FormularioBorradores.Free;
  end;
end;

procedure TFormMenu.ButtonEnviarClick(Sender: TObject);
begin
  FormEnviar := TFormEnviar.Create(Self);
  try
    FormEnviar.PrepararEnvio(UsuarioActual);
    FormEnviar.ShowModal;
  finally
    FormEnviar.Free;
  end;
end;

procedure TFormMenu.ButtonContactosClick(Sender: TObject);
var
  FormularioContactos: TFormContactos;
begin
  FormularioContactos := TFormContactos.Create(Self);
  try
    FormularioContactos.AbrirContactos(UsuarioActual);
    FormularioContactos.ShowModal;
  finally
    FormularioContactos.Free;
  end;
end;

procedure TFormMenu.ButtonAgregarClick(Sender: TObject);
var
  FormularioAgregar: TFormAgregar;
begin
  FormularioAgregar := TFormAgregar.Create(Application);
  try
    FormularioAgregar.SetUsuarioActual(Self.UsuarioActual);

    FormularioAgregar.ShowModal;
  finally
    FormularioAgregar.Free;
  end;
end;

procedure TFormMenu.ButtonFavoritosClick(Sender: TObject);
var
  FormularioFavoritos: TFormFavoritos;
begin
  FormularioFavoritos := TFormFavoritos.Create(Application);
  try
    FormularioFavoritos.AbrirFavoritos(UsuarioActual);
    FormularioFavoritos.ShowModal;
  finally
    FormularioFavoritos.Free;
  end;
end;

procedure TFormMenu.ButtonPapeleraClick(Sender: TObject);
var
  FormularioPapelera: TFormPapelera;
begin
  FormularioPapelera := TFormPapelera.Create(Application);
  try
    FormularioPapelera.AbrirPapelera(UsuarioActual);
    FormularioPapelera.ShowModal;

  finally
    FormularioPapelera.Free;
  end;
end;


procedure TFormMenu.ButtonPrivadosClick(Sender: TObject);
var
  Formulario: TFormPrivados;
begin
  Formulario := TFormPrivados.Create(Application);
  try
    Formulario.Abrir(UsuarioActual);
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFormMenu.ButtonProgramarClick(Sender: TObject);
var
  FormularioProgramar: TFormProgramar;
begin
  FormularioProgramar := TFormProgramar.Create(Application);

  try
    FormularioProgramar.PrepararProgramacion(UsuarioActual);
    FormularioProgramar.ShowModal;
  finally
    FormularioProgramar.Free;
  end;
end;

procedure TFormMenu.ButtonProgramadosClick(Sender: TObject);
var
  FormularioProgramados: TFormProgramados;
begin
  FormularioProgramados := TFormProgramados.Create(Application);

  try
    FormularioProgramados.AbrirProgramados(UsuarioActual);
    FormularioProgramados.ShowModal;
  finally
    FormularioProgramados.Free;
  end;
end;

procedure TFormMenu.ButtonActualizarClick(Sender: TObject);
var
  FormularioActualizar : TFormActualizar;
begin
  FormularioActualizar := TFormActualizar.Create(Application);
  try
  FormularioActualizar.AbrirPerfil(UsuarioActual);
  FormularioActualizar.ShowModal;
  finally
  FormularioActualizar.Free;
  end;
end;

procedure TFormMenu.ButtonPublicarMensajeClick(Sender: TObject);
var
  Formulario: TFormMensajeComunidad;
begin
  Formulario := TFormMensajeComunidad.Create(Application);
  try
    Formulario.Abrir(UsuarioActual);
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFormMenu.ButtonReportesClick(Sender: TObject);
var
  rutaReportes: String;
begin
  if UsuarioActual = nil then
  begin
    ShowMessage('Error: No se ha identificado al usuario actual.');
    Exit;
  end;

  rutaReportes := UsuarioActual^.usuario + '-Reportes';

  ShowMessage('Generando todos los reportes en la carpeta "' + rutaReportes + '". Esto puede tardar un momento...');

  try
    ReporteCorreos(UsuarioActual, rutaReportes);
    ReporteContactos(UsuarioActual, rutaReportes);
    ReporteBorradores(UsuarioActual, rutaReportes);
    ReporteFavoritos(UsuarioActual, rutaReportes);
    ReportePapelera(UsuarioActual, rutaReportes);
    ReporteProgramados(UsuarioActual, rutaReportes);
    GenerarReporteBlockchain(rutaReportes);

    ShowMessage('¡Reportes generados exitosamente!');
  except
    on E: Exception do
      ShowMessage('Ocurrió un error al generar los reportes: ' + E.Message);
  end;
end;

initialization
  InitBlockchain;

end.

