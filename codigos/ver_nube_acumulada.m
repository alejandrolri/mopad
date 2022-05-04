% ver_nube_acumulada.m
% Autor: Alejandro López-Rey Iglesias
% Entrada: Carpeta de una sesión
% Permite ver todas las nubes
function ver_nube_acumulada
minima_T = [];
disp('Elegir el directorio de la sesión')
Directorio = uigetdir();
files = dir(Directorio);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolderNames = {subFolders(3:end).name};
f = figure;
hold on

clc
disp('Procesando...')
for j = 1 : length(subFolderNames)
    Directorio_principal = fullfile(Directorio,subFolderNames{j});
    if length(dir(Directorio_principal))==6

        files_posicion = dir([Directorio_principal,'\vertical']);
        dirFlags_posicion = [files_posicion.isdir];
        subFolders_posicion = files_posicion(dirFlags_posicion);
        subFolderNames_posicion = {subFolders_posicion(3:end).name};
        for i=1:length(subFolderNames_posicion)
            direccion_vertical = [Directorio_principal,'\vertical\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_registrada_ICP.mat'];
            load(direccion_vertical)
            nube_vertical = ptCloudOut;
            direccion_inclinado1 = [Directorio_principal,'\inclinado1\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_registrada_ICP.mat'];
            load(direccion_inclinado1)
            nube_inclinado1 = ptCloudOut;
            direccion_inclinado2 = [Directorio_principal,'\inclinado2\',subFolderNames_posicion{i},'\Directorio_nuevo\Nube_registrada_ICP.mat'];
            load(direccion_inclinado2)
            nube_inclinado2 = ptCloudOut;
            clear ptCloudOut
            
            if isempty(minima_T)
                                    Temperatura=nube_vertical.Intensity;
                                figure
                                histogram(Temperatura,50);
            
            
                                [x1, y]=ginput(1);
                                minima_T=x1;
                                text(x1, y, num2str(x1,3))
                                [x2, y]=ginput(1);
                                maxima_T=x2;
                                text(x2, y, num2str(x2,3))
                                pause(1)
                                close
            end

            pcshow(nube_vertical.Location,nube_vertical.Intensity)
            pcshow(nube_inclinado1.Location,nube_inclinado1.Intensity)
            pcshow(nube_inclinado2.Location,nube_inclinado2.Intensity)
            cameratoolbar
            set(gcf,'color','w');
            set(gca,'color','w');
            axis equal
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            view(0,45)
            title('Nube termica')
            colormap('jet'); % puede cambiarse a 'parula'
            caxis([minima_T maxima_T]) % Limites de color
            colorbar;
        end
    end
end
clc
guardar = input('Guardar (s/n): ','s');
if guardar=='s'
    savefig('nube_acumulada.fig')
end
clc
close all
end