%registro_mopad2
% Autor: Alejandro López-Rey Iglesias
% Basado en MAIN_Nube_omnidireccional_botones_ver2 de Antonio Adán
% Interfaz de botones para registro de nubes 
% REGISTRO NUBES ADQUIRIDAS USANDO MOPAD 2
function MAIN_registro_mopad
clc
%clear
%close all
warning off
set(0,'defaultFigureVisible','on')

disp('===============================================')
disp('============== registro_mopad.m ===============')
disp('===============================================')



disp('Elegir el directorio GENERAL del PROYECTO donde se ven todas las sesiones ');
Directorio_main_datos=uigetdir;
cd(Directorio_main_datos)

% Posiciones de la ventana en la pantalla
pos_hor=400; pos_ver=250; ancho_fig=750; alto_fig=500;

%% === Parte izquierda =====
% Posiciones y dimensiones de los rotulos dentro de la figura

% Posicion titulo
pos_x_titulo=20;
pos_y_titulo=alto_fig-40;
altura_titulo=15;
Color_fondo_titulo=[1 1 0];

% Posiciones de inicio x e y de los botones
pos_x_boton=pos_x_titulo;
pos_y_boton=pos_y_titulo-40:-40:20; % a cada 40 pixeles
anchura_boton=30;
altura_boton=20;
Color_fondo_boton=[1 0.4 0];

% Posiciones de inicio x e y de los textos
pos_x=pos_x_boton+anchura_boton+10;
pos_y=pos_y_boton;
anchura=300; % Es la anchura de los textos
altura=altura_boton;
Color_fondo_texto=[0.85 0.85 0.85];

ii=0; % Es el contador de posicion vertical en la parte izquierda


ultimo=size(pos_y,2);
sigue='s';
opcion=[];


while sigue=='s'

    ii=0;
    close all
    h=figure;

    h.Position=[pos_hor pos_ver ancho_fig alto_fig]; % Posicion de la ventana

    %%  ================= Parte izquierda =========================

    %% Los Botones de creacion de NUBES OMNIDIRECCIONALES
    %% 01
    % Titulo. Posicion i0. Estilo solo texto
    ci01 = uicontrol;
    ci01.Style= 'text';
    titulo=' FUNCIONES DE REGISTRO ';
    ci01.String = titulo;
    ci01.BackgroundColor=Color_fondo_titulo;
    ci01.FontWeight= 'bold';
    ci01.HorizontalAlignment = 'left';
    anchura_titulo=length(titulo)*7;
    ci01.Position=[pos_x_titulo pos_y_titulo anchura_titulo altura_titulo]; % Posicion del boton

    %% 1
    ii=ii+1;
    % Posicion 1. Boton
    ci1 = uicontrol;
    ci1.String = '1)';
    ci1.BackgroundColor=Color_fondo_boton;
    ci1.FontWeight= 'bold';
    ci1.Position=[pos_x_boton pos_y_boton(ii) anchura_boton altura_boton]; % Posicion del boton
    ci1.Callback = @pushbuttonGet_boton_i1; % Se queda residente

    % Texto
    ci1t = uicontrol;
    ci1t.Style= 'text';
    ci1t.BackgroundColor=Color_fondo_texto;
    ci1t.String = 'Orientación de nubes inclinadas';
    ci1t.HorizontalAlignment = 'left';
    ci1t.Position=[pos_x pos_y(ii) anchura altura]; % Posicion del boton

    %% 2
    ii=ii+1;
    % Posicion 2. Boton
    ci2 = uicontrol;
    ci2.String = '2)';
    ci2.BackgroundColor=Color_fondo_boton;
    ci2.FontWeight= 'bold';
    ci2.Position=[pos_x_boton pos_y_boton(ii) anchura_boton altura_boton]; % Posicion del boton
    ci2.Callback = @pushbuttonGet_boton_i2; % Se queda residente

    % Texto
    ci2t = uicontrol;
    ci2t.Style= 'text';
    ci2t.BackgroundColor=Color_fondo_texto;
    ci2t.String = 'Registro mediante odometría';
    ci2t.HorizontalAlignment = 'left';
    ci2t.Position=[pos_x pos_y(ii) anchura altura]; % Posicion del boton

    %% 3
    ii=ii+1;
    % Posicion 3. Boton
    ci3 = uicontrol;
    ci3.String = '3)';
    ci3.BackgroundColor=Color_fondo_boton;
    ci3.FontWeight= 'bold';
    ci3.Position=[pos_x_boton pos_y_boton(ii) anchura_boton altura_boton]; % Posicion del boton
    ci3.Callback = @pushbuttonGet_boton_i3; % Se queda residente

    % Texto
    ci3t = uicontrol;
    ci3t.Style= 'text';
    ci3t.BackgroundColor=Color_fondo_texto;
    ci3t.String = 'Registro ICP';
    ci3t.HorizontalAlignment = 'left';
    ci3t.Position=[pos_x pos_y(ii) anchura altura]; % Posicion del boton


    %% 4
    ii=ii+1;
    % Posicion 4. Boton
    ci4 = uicontrol;
    ci4.String = '4)';
    ci4.BackgroundColor=Color_fondo_boton;
    ci4.FontWeight= 'bold';
    ci4.Position=[pos_x_boton pos_y_boton(ii) anchura_boton altura_boton]; % Posicion del boton
    ci4.Callback = @pushbuttonGet_boton_i4; % Se queda residente

    % Texto
    ci4t = uicontrol;
    ci4t.Style= 'text';
    ci4t.BackgroundColor=Color_fondo_texto;
    ci4t.String = 'Mostrar posiones y orientaciones en el mapa';
    ci4t.HorizontalAlignment = 'left';
    ci4t.Position=[pos_x pos_y(ii) anchura altura]; % Posicion del boton

    %% =================================================================
    % Acabar visualización
    c100 = uicontrol;
    c100.String = 'FIN';
    c100.Position=[pos_x pos_y(ultimo) 40 20];
    c100.Callback = @pushbuttonGet_fin; % Se queda residente


    %% Bucle de parada hasta que se pulsa el boton continua
    para=1;
    while (para==1)
        pause(0.01)
    end

    switch opcion
        case 1;     clc;
            disp('==================1====================')
            disp(' ')
            disp('1) Registro de nubes inclinadas respecto a una nube vertical')
            registroPTU
            cd(Directorio_main_datos)
            disp('Fin de proceso 1')
            disp('=======================================')
            disp(' ')

        case 2;     clc
            disp('==================2====================')
            disp(' ')
            disp('2) Registro de nubes de puntos mediante odometría')
            registro_odometria
            cd(Directorio_main_datos)
            disp('Fin de proceso 2')
            disp('=======================================')
            disp(' ')

        case 3;     clc
            disp('==================3====================')
            disp(' ')
            disp('3) Registro de nubes orientadas por odometría mediante ICP')
            registro_orienta_ICP
            cd(Directorio_main_datos)
            disp('Fin de proceso 3')
            disp('=======================================')
            disp(' ')
        case 4;     clc
            disp('==================4====================')
            disp(' ')
            disp('4) Mostrar posiones y orientaciones en el mapa')
            Muestra_puntos_mapa
            cd(Directorio_main_datos)
            disp('Fin de proceso 4')
            disp('=======================================')
            disp(' ')

        case 100;    clc
            disp('=======FIN DEL PROGRAMA =======')

    end % switch

end % del while sigue

close all

%% ==== Definicion de funciones parte izquierda =======

% Boton 1
    function pushbuttonGet_boton_i1(~,~)
        opcion=1;
        para=0;
    end

% Boton 2
    function pushbuttonGet_boton_i2(~,~)
        opcion=2;
        para=0;
    end

% Boton 3
    function pushbuttonGet_boton_i3(~,~)
        opcion=3;
        para=0;
    end

% Boton 4
    function pushbuttonGet_boton_i4(~,~)
        opcion=4;
        para=0;
    end

%%
%% FIN. Salir del bucle
    function pushbuttonGet_fin(~,~)
        opcion=100;
        para=0;
        sigue='n';
    end

end