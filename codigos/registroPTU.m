% registroPTU.m
% Autor: Alejandro López-Rey Iglesias
% Entrada: Carpeta de sesión con todas las posiciones
% Salida: Nubes inclinadas registradas
% Realiza el registro de las nubes tomadas en una posición con el pan-tilt:
% vertical, inclinada1 e inclinada2.
% Orienta las tomas inclinadas en función de la vertical

function registroPTU
%% CARGA LAS NUBES
disp('Elegir el directorio de la sesión')
Directorio = uigetdir();
files = dir(Directorio);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolderNames = {subFolders(3:end).name};

for j = 1 : length(subFolderNames)
    Directorio_principal = fullfile(Directorio,subFolderNames{j});
    if length(dir(Directorio_principal))==6

        files_posicion = dir([Directorio_principal,'\vertical']);
        dirFlags_posicion = [files_posicion.isdir];
        subFolders_posicion = files_posicion(dirFlags_posicion);
        subFolderNames_posicion = {subFolders_posicion(3:end).name};
        for i=1:length(subFolderNames_posicion)

            direccion_vertical = [Directorio_principal,'\vertical\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_termica.mat'];
            load(direccion_vertical)
            nube_vertical = ptCloudOut;
            direccion_inclinado1 = [Directorio_principal,'\inclinado1\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_termica.mat'];
            load(direccion_inclinado1)
            nube_inclinado1 = ptCloudOut;
            direccion_inclinado2 = [Directorio_principal,'\inclinado2\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_termica.mat'];
            load(direccion_inclinado2)
            nube_inclinado2 = ptCloudOut;
            clear ptCloudOut

            %% REALIZA EL REGISTRO DE CADA NUBE
            nube_inclinado1_registrada =  registro_ICP_PTU(nube_vertical,nube_inclinado1,90);
            nube_inclinado2_registrada =  registro_ICP_PTU(nube_vertical,nube_inclinado2,-90);

            %% VISUALIZAR
            %                     Temperatura=nube_vertical.Intensity;
            %                     figure
            %                     histogram(Temperatura,50);
            %
            %
            %                     [x1, y]=ginput(1);
            %                     minima_T=x1;
            %                     text(x1, y, num2str(x1,3))
            %                     [x2, y]=ginput(1);
            %                     maxima_T=x2;
            %                     text(x2, y, num2str(x2,3))
            %                     pause(1)
            %                     close
            %
            %                     figure;
            %                     pcshow(nube_vertical.Location,nube_vertical.Intensity)
            %                     hold on
            %                     pcshow(nube_inclinado2_registrada.Location,nube_inclinado2_registrada.Intensity)
            %                     pcshow(nube_inclinado1_registrada.Location,nube_inclinado1_registrada.Intensity)
            %                     cameratoolbar
            %                     set(gcf,'color','w');
            %                     set(gca,'color','w');
            %                     axis equal
            %                     xlabel('X')
            %                     ylabel('Y')
            %                     zlabel('Z')
            %                     view(0,45)
            %                     title('Nube termica')
            %                     colormap('jet'); % puede cambiarse a 'parula'
            %                     caxis([minima_T maxima_T]) % Limites de color
            %                     colorbar;

            %% GUARDAR
            cd([Directorio_principal,'\inclinado1\',subFolderNames_posicion{i},'\Directorio_nuevo'])
            ptCloudOut = nube_inclinado1_registrada;
            save('Nube_inclinada_registrada','ptCloudOut')

            cd([Directorio_principal,'\inclinado2\',subFolderNames_posicion{i},'\Directorio_nuevo'])
            ptCloudOut = nube_inclinado2_registrada;
            save('Nube_inclinada_registrada','ptCloudOut')

        end
    end
end
clc
end