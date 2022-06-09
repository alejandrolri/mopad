classdef app_mopad_ver3 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        LeftPanel          matlab.ui.container.Panel
        RUTAButton         matlab.ui.control.Button
        RECUPERARButton    matlab.ui.control.Button
        PANTILTButton      matlab.ui.control.Button
        BATERAButton       matlab.ui.control.Button
        HOMEButton         matlab.ui.control.Button
        MOSTRARPOSButton   matlab.ui.control.StateButton
        EditField          matlab.ui.control.NumericEditField
        NAVButton          matlab.ui.control.Button
        LOCALIZACINButton  matlab.ui.control.StateButton
        GOALSButton        matlab.ui.control.Button
        TELEOPButton       matlab.ui.control.Button
        Lamp               matlab.ui.control.Lamp
        Label              matlab.ui.control.Label
        DESCONECTARButton  matlab.ui.control.Button
        INICIARButton      matlab.ui.control.Button
        RightPanel         matlab.ui.container.Panel
        UIAxes             matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        mapa;
        n;                      %Número de localizaciones
        file; path;             %Ruta y archivo del mapa
        origin; resolution;     %Valores del mapa
        odomSub; pos; v; tftree;%Variables para conocer la posición
        home=[];                %Punto al que volver
        home_x; home_y;         %Coordenadas HOME en imagen
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: INICIARButton
        function INICIARButtonPushed(app, event)
            addpath C:\Users\mopad\pruebas;
            addpath C:\Users\mopad\pruebas\matlabSSH;

            %Iniciar ROS en mopad y MatLab
            system('ssh -t mopad@10.42.0.1 sudo chmod 666 /dev/ttyUSB0 &')
            ssh2_simple_command('10.42.0.1','mopad','mopad','roscore >/dev/null 2>1 &');
            pause(5)
            rosinit('10.42.0.1');
            %DRIVERS
            ssh2_simple_command('10.42.0.1','mopad','mopad','roslaunch mopad_bringup all.launch >/dev/null 2>1 &');
            %Cargar mapa
            [app.file, app.path]=uigetfile('*.pgm');
            app.mapa=imread(fullfile(app.path,app.file));
            yaml = ReadYaml(fullfile(app.path,strcat(app.file(1:end-3),'yaml')));
            app.origin = yaml.origin;
            disp(app.origin)
            app.resolution = yaml.resolution;
            app.INICIARButton.Enable="off";
            imshow(app.mapa,'Parent',app.UIAxes);
            hold(app.UIAxes,"on");
            app.DESCONECTARButton.Enable="on";
            app.BATERAButton.Enable="on";
            app.PANTILTButton.Enable="on";
            app.GOALSButton.Enable="on";
            app.TELEOPButton.Enable="on";
            app.LOCALIZACINButton.Enable="on";
            app.RECUPERARButton.Enable="on";
            app.Lamp.Color = [0.39,0.83,0.07];

            
        end

        % Button pushed function: DESCONECTARButton
        function DESCONECTARButtonPushed(app, event)
            app.MOSTRARPOSButton.Value=false;
            %Termina todos los procesos de ROS
            rosshutdown;
            ssh2_simple_command('10.42.0.1','mopad','mopad','pkill -2 roslaunch');
            ssh2_simple_command('10.42.0.1','mopad','mopad','pkill -2 ros');
            app.Lamp.Color = [1.00,0.00,0.00];
            app.INICIARButton.Enable="on";
            app.DESCONECTARButton.Enable="off";
        end

        % Button pushed function: TELEOPButton
        function TELEOPButtonPushed(app, event)
            system('ssh -t mopad@10.42.0.1 roslaunch mopad_teleop keyboard_teleop.launch &')
        end

        % Value changed function: LOCALIZACINButton
        function LOCALIZACINButtonValueChanged(app, event)
            if app.LOCALIZACINButton.Value
                comando = strcat('roslaunch mopad_bringup rtabmap.launch localization:=true database_path:=/home/mopad/Escritorio/Sesiones/',app.file(1:end-4),'.db >/dev/null 2>1 &');
                %disp(comando)
                ssh2_simple_command('10.42.0.1','mopad','mopad',comando);
                app.NAVButton.Enable='on';
                %% Recibir odometría y transformaciones
                app.odomSub = rossubscriber("/odom");
                app.pos = rosmessage(app.odomSub);
                app.v = rosmessage("geometry_msgs/PoseStamped");
                app.v.Header.Stamp= rostime('now');
                app.v.Header.FrameId='/odom';
                app.tftree = rostf;

                fig = uifigure; fig.Position = [500 500 400 90];
                d = uiprogressdlg(fig,'Title','Iniciando','Indeterminate','on');

                while ~canTransform(app.tftree,'odom','map')
                    drawnow
                end
                close(d);close(fig);
                app.MOSTRARPOSButton.Enable='on';
            end
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            app.n = app.EditField.Value;
        end

        % Button pushed function: GOALSButton
        function GOALSButtonPushed(app, event)
        if app.n~=0
            %Reinicia la imagen del mapa
            hold(app.UIAxes,"off");
            imshow(app.mapa,'Parent',app.UIAxes)
            hold(app.UIAxes,"on");

            figure; imshow(app.mapa)
            hold on
            
            fileID = fopen('C:\Users\mopad\pruebas\ruta.txt','w');

            %Incluye las coordenadas de HOME
            if ~isempty(app.home)
                plot(app.UIAxes,app.home_x,app.home_y,'rd','LineWidth',2,'MarkerSize',6,'MarkerFaceColor','r');
                fprintf(fileID,'%4f  \t%4f  \t%4f  \t%s  \t%i  \t%s  \t%f  \t%s  \t%s  \t%i  \n',app.home,'home',0,'home',0.95,'home','home',0);
            end


            %Seleccionar posiciones y  orientaciones
            for i=1:app.n
                puntos = ginput(2);
                arrow(puntos(1,:),puntos(2,:));
                plot(app.UIAxes,puntos(1,1),puntos(1,2),'rx','LineWidth',2,'MarkerSize',5)
                plot(puntos(1,1),puntos(1,2),'rx','LineWidth',2,'MarkerSize',5)
                
                modo = questdlg('Seleccione modo', 'Modo','NubedePuntos','Nube+Térmico','NubedePuntos');
                
                color = questdlg('Seleccione modo:','RGB','RGB','Reflectancia','RGB');

                tomas = inputdlg('Introduzca el número de tomas:','Tomas',[1 40],"1");
                tomas = tomas{1};
                
                if modo=="Nube+Térmico"
                    emisividad = inputdlg('Introduzca emisividad:','Emisividad',[1 40],"1");
                    emisividad = emisividad{1};
                else
                    emisividad = '0';
                end

                densidad = questdlg('Seleccione densidad de puntos','Densidad','low','medium','high','low');

                ptu = questdlg('¿Quiere usar el pan-tilt?','PTU','Sí','No','Sí');

                vector = puntos(2,:)-puntos(1,:);
                long = norm(vector)/(norm(size(app.mapa))*app.resolution);
                vector = vector/long;
                x = puntos(1,1)*app.resolution+app.origin(1);
                y = (size(app.mapa,1)-puntos(1,2))*app.resolution+app.origin(2);
                goal = [x y -atan2(vector(2),vector(1))]; 
                fprintf(fileID,'%4f  \t%4f  \t%4f  \t%s  \t%s  \t%s  \t%s  \t%s  \t%s  \t%i  \n',goal,modo,tomas,densidad,emisividad,color,ptu,i);
            end
            pause(0.5)
            close all;
            fclose(fileID);
            if isfolder('C:\Users\mopad\Desktop\BLK\Nubes')
                copyfile C:\Users\mopad\pruebas\ruta.txt C:\Users\mopad\Desktop\BLK\Nubes
            else
                mkdir C:\Users\mopad\Desktop\BLK\Nubes
                copyfile C:\Users\mopad\pruebas\ruta.txt C:\Users\mopad\Desktop\BLK\Nubes
            end

            system('pscp -pw mopad C:\Users\mopad\pruebas\ruta.txt mopad@10.42.0.1://home/mopad/catkin_ws/src/mopad_navigation/paths/');
        end
        
        end

        % Button pushed function: NAVButton
        function NAVButtonPushed(app, event)
            ssh2_simple_command('10.42.0.1','mopad','mopad','rosnode kill /mopad_teleop_keyboard');
            fig = msgbox('Asegúrese de haber encendido el BLK', 'Aviso','warn');
            uiwait(fig)
            %Inicia los nodos de navegación/escaneado
            %ssh2_simple_command('10.42.0.1','mopad','mopad','roslaunch mopad_navigation move_base.launch >/dev/null 2>1 &');
            system('ssh -t mopad@10.42.0.1 roslaunch mopad_navigation move_base.launch&')
            pause(3)
            %Para poder ver la salida del terminal
            system('ssh -t mopad@10.42.0.1 roslaunch mopad_navigation navigation.launch&')
        end

        % Value changed function: MOSTRARPOSButton
        function MOSTRARPOSButtonValueChanged(app, event)
            app.HOMEButton.Enable='on';
            
            %Recibe y muestra la posición del robot
            while app.MOSTRARPOSButton.Value==true && canTransform(app.tftree,'odom','map')
                app.pos = receive(app.odomSub);
                app.v.Pose= app.pos.Pose.Pose;
                pos_map= transform(app.tftree,'/map',app.v);

                x = round((pos_map.Pose.Position.X- app.origin(1))/app.resolution);
                y = round(-(pos_map.Pose.Position.Y-app.origin(2))/app.resolution+size(app.mapa,1));

                h= plot(app.UIAxes,x,y,'bo','LineWidth',2,'MarkerSize',6,'MarkerFaceColor','b');
                drawnow;  
                delete(h);
    
            end
        end

        % Button pushed function: HOMEButton
        function HOMEButtonPushed(app, event)
            %Establece un HOME para retorno del robot
                app.pos = receive(app.odomSub);
                app.v.Pose= app.pos.Pose.Pose;
                pos_map= transform(app.tftree,'/map',app.v);

                app.home_x = round((pos_map.Pose.Position.X- app.origin(1))/app.resolution);
                app.home_y = round(-(pos_map.Pose.Position.Y-app.origin(2))/app.resolution+821);

                app.home = [pos_map.Pose.Position.X,pos_map.Pose.Position.Y,0];

                plot(app.UIAxes,app.home_x,app.home_y,'rd','LineWidth',2,'MarkerSize',6,'MarkerFaceColor','r');
        end

        % Button pushed function: BATERAButton
        function BATERAButtonPushed(app, event)
            %Muestra los valores de batería del ordenador y del kobuki
            sub=rossubscriber("/mobile_base/sensors/core");
            info = receive(sub);
            battery = cast(info.Battery,'double');
            porcentaje= battery/164;
            laptop = ssh2_simple_command('10.42.0.1','mopad','mopad','cat /sys/class/power_supply/BAT1/capacity');
            msgbox({sprintf('KOBUKI: %i%%',round(porcentaje*100));sprintf('ORDENADOR: %s%%',laptop{:})});
        end

        % Button pushed function: PANTILTButton
        function PANTILTButtonPushed(app, event)
            %ssh2_simple_command('10.42.0.1','mopad','mopad','sudo chmod 666 /dev/ttyUSB0');
            %system('ssh -t mopad@10.42.0.1 sudo chmod 666 /dev/ttyUSB0 &')
            fig = msgbox('Asegúrese de haber encendido el pan-tilt', 'Aviso','warn');
            uiwait(fig)
            ssh2_simple_command('10.42.0.1','mopad','mopad','roslaunch asr_flir_ptu_driver ptu_left.launch >/dev/null 2>1 &');
        end

        % Button pushed function: RECUPERARButton
        function RECUPERARButtonPushed(app, event)
            id_fallo = fopen('C:\Users\mopad\Desktop\BLK\Nubes\fallo.txt');
            fallo = fscanf(id_fallo,'%d');
            fclose(id_fallo);
            
            %ruta = readcell('C:\Users\mopad\pruebas\ruta.txt');
            ruta = readcell('C:\Users\mopad\Desktop\BLK\Nubes\ruta.txt');
            if ruta{1,4}=="home"
                ruta(2:fallo,:)=[];
            else
                ruta(1:fallo-1,:)=[];
            end

            writecell(ruta,'C:\Users\mopad\pruebas\ruta.txt','Delimiter','tab');
            system('pscp -pw mopad C:\Users\mopad\pruebas\ruta.txt mopad@10.42.0.1://home/mopad/catkin_ws/src/mopad_navigation/paths/');
            
        end

        % Button pushed function: RUTAButton
        function RUTAButtonPushed(app, event)
             [file, path]=uigetfile('*.txt');
             comando = ['pscp -pw mopad ', fullfile(path,file), ' mopad@10.42.0.1://home/mopad/catkin_ws/src/mopad_navigation/paths/'];
             system(comando);
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {565, 565};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {387, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 847 565];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {387, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create INICIARButton
            app.INICIARButton = uibutton(app.LeftPanel, 'push');
            app.INICIARButton.ButtonPushedFcn = createCallbackFcn(app, @INICIARButtonPushed, true);
            app.INICIARButton.Position = [42 464 99 43];
            app.INICIARButton.Text = 'INICIAR';

            % Create DESCONECTARButton
            app.DESCONECTARButton = uibutton(app.LeftPanel, 'push');
            app.DESCONECTARButton.ButtonPushedFcn = createCallbackFcn(app, @DESCONECTARButtonPushed, true);
            app.DESCONECTARButton.Enable = 'off';
            app.DESCONECTARButton.Position = [232 460 118 43];
            app.DESCONECTARButton.Text = 'DESCONECTAR';

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [142 481 25 22];
            app.Label.Text = '';

            % Create Lamp
            app.Lamp = uilamp(app.LeftPanel);
            app.Lamp.Position = [167 466 36 36];
            app.Lamp.Color = [1 0 0];

            % Create TELEOPButton
            app.TELEOPButton = uibutton(app.LeftPanel, 'push');
            app.TELEOPButton.ButtonPushedFcn = createCallbackFcn(app, @TELEOPButtonPushed, true);
            app.TELEOPButton.Enable = 'off';
            app.TELEOPButton.Position = [251 397 99 46];
            app.TELEOPButton.Text = 'TELEOP';

            % Create GOALSButton
            app.GOALSButton = uibutton(app.LeftPanel, 'push');
            app.GOALSButton.ButtonPushedFcn = createCallbackFcn(app, @GOALSButtonPushed, true);
            app.GOALSButton.Enable = 'off';
            app.GOALSButton.Position = [43 344 98 35];
            app.GOALSButton.Text = 'GOALS';

            % Create LOCALIZACINButton
            app.LOCALIZACINButton = uibutton(app.LeftPanel, 'state');
            app.LOCALIZACINButton.ValueChangedFcn = createCallbackFcn(app, @LOCALIZACINButtonValueChanged, true);
            app.LOCALIZACINButton.Enable = 'off';
            app.LOCALIZACINButton.Text = 'LOCALIZACIÓN';
            app.LOCALIZACINButton.Position = [41 401 104 46];

            % Create NAVButton
            app.NAVButton = uibutton(app.LeftPanel, 'push');
            app.NAVButton.ButtonPushedFcn = createCallbackFcn(app, @NAVButtonPushed, true);
            app.NAVButton.Enable = 'off';
            app.NAVButton.Position = [251 344 100 35];
            app.NAVButton.Text = 'NAV';

            % Create EditField
            app.EditField = uieditfield(app.LeftPanel, 'numeric');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [87 320 54 22];

            % Create MOSTRARPOSButton
            app.MOSTRARPOSButton = uibutton(app.LeftPanel, 'state');
            app.MOSTRARPOSButton.ValueChangedFcn = createCallbackFcn(app, @MOSTRARPOSButtonValueChanged, true);
            app.MOSTRARPOSButton.Enable = 'off';
            app.MOSTRARPOSButton.Text = 'MOSTRAR POS';
            app.MOSTRARPOSButton.Position = [41 258 104 51];

            % Create HOMEButton
            app.HOMEButton = uibutton(app.LeftPanel, 'push');
            app.HOMEButton.ButtonPushedFcn = createCallbackFcn(app, @HOMEButtonPushed, true);
            app.HOMEButton.Enable = 'off';
            app.HOMEButton.Position = [251 258 100 51];
            app.HOMEButton.Text = 'HOME';

            % Create BATERAButton
            app.BATERAButton = uibutton(app.LeftPanel, 'push');
            app.BATERAButton.ButtonPushedFcn = createCallbackFcn(app, @BATERAButtonPushed, true);
            app.BATERAButton.Enable = 'off';
            app.BATERAButton.Position = [251 198 100 40];
            app.BATERAButton.Text = 'BATERÍA';

            % Create PANTILTButton
            app.PANTILTButton = uibutton(app.LeftPanel, 'push');
            app.PANTILTButton.ButtonPushedFcn = createCallbackFcn(app, @PANTILTButtonPushed, true);
            app.PANTILTButton.Enable = 'off';
            app.PANTILTButton.Position = [41 198 100 40];
            app.PANTILTButton.Text = 'PAN-TILT';

            % Create RECUPERARButton
            app.RECUPERARButton = uibutton(app.LeftPanel, 'push');
            app.RECUPERARButton.ButtonPushedFcn = createCallbackFcn(app, @RECUPERARButtonPushed, true);
            app.RECUPERARButton.Enable = 'off';
            app.RECUPERARButton.Position = [42 146 99 37];
            app.RECUPERARButton.Text = 'RECUPERAR';

            % Create RUTAButton
            app.RUTAButton = uibutton(app.LeftPanel, 'push');
            app.RUTAButton.ButtonPushedFcn = createCallbackFcn(app, @RUTAButtonPushed, true);
            app.RUTAButton.Position = [252 145 100 38];
            app.RUTAButton.Text = 'RUTA';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.TitlePosition = 'centertop';
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTickLabel = '';
            app.UIAxes.Position = [1 117 441 428];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_mopad_ver3

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end