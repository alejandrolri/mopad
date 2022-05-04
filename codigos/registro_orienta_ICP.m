% registra_orienta_ICP
% Autor: Alejandro López-Rey Iglesias
function registro_orienta_ICP
seguir = 's';
while seguir=='s'
    close all
    %% Cargar nubes
    disp('Seleccionar la nube fija (toma vertical): ')
    [nombre,Directorio] = uigetfile('*.mat*');
    nube_fija=load(fullfile(Directorio,nombre)); % ptCloud_guardar
    nube_fija=struct2cell(nube_fija);
    nube_fija=nube_fija{1};

    clc
    disp('Seleccionar la nube móvil (toma vertical): ')
    [nombre,Directorio] = uigetfile('*.mat*');
    nube_movil=load(fullfile(Directorio,nombre)); % ptCloud_guardar
    nube_movil=struct2cell(nube_movil);
    nube_movil=nube_movil{1};

    %% Se reduce el tamaño para que sea mas eficiente el ICP
    gridSize = 0.05;
    %% Funcion pcdownsample. Muestrea nube de puntos

    fixed = pcdownsample(nube_fija, 'gridAverage', gridSize); % Nube muestreada

    moving = pcdownsample(nube_movil, 'gridAverage', gridSize); % Nube muestreada


    %% Funcion pcnormals. Calcula normales de nubes de puntos
    % Calculamos las normales de los puntos para que funcione mejor el ICP
    % cuando usamos 'pointToPlane'

    normals_fixed=pcnormals(fixed,30);
    normals_moving=pcnormals(moving,30);
    fixed.Normal=normals_fixed;
    moving.Normal=normals_moving;

    %% Funcion pcregrigid: ICP.
    % tform = pcregrigid(moving, fixed, 'Metric','pointToPlane','MaxIterations',50,'InlierRatio',0.75);
    rmse=500;
    i=0.9;
    cont_min=0;
    contador=0;

    % Itera 4 veces o hasta que hasta root mean squared error (rmse) sea
    % >0.1
    while rmse>0.1 || i==0.5
        i=i-0.1;
        contador=contador+1;
        [tform,moving_Reg,rmse] = pcregrigid(moving, fixed, 'Metric','pointToPlane','MaxIterations',20,'Verbose',false,'InlierRatio',i);
        trasnform(contador).tform=tform;

        trasnform(contador).rmse=rmse;
    end


    Matriz_transform_ICP=tform;

    % Transformacion de la nube movil sin reducir. Es pc

    nube_orientada_ICP = pctransform(nube_movil,Matriz_transform_ICP);

    %% Visualización de nube_fija y nube_orientada_ICP ;
    figure
    porcentaje = 2*10^6/nube_fija.Count;
    pcshow(pcdownsample(nube_fija,'random',porcentaje))
    hold on
    porcentaje = 2*10^6/nube_orientada_ICP.Count;
    pcshow(pcdownsample(nube_orientada_ICP,'random',porcentaje))
    cameratoolbar

    %% Guardar nube_orientada_ICP
    clc
    guardar = input('¿Guardar? (s/n) ','s');
    if guardar=='s'
        %         ptCloudOut = nube_orientada_ICP;
        %         nombre_guardar = [Directorio,'Nube_registrada_ICP'];
        %         save(nombre_guardar,'ptCloudOut')

        %ICP para el resto de tomas
        indice = strfind(Directorio,'vertical');
        if  isempty(indice)
            indice = strfind(Directorio,'toma');
        end
        Directorio_posicion = Directorio(1:indice-1);
        files_posicion = dir(Directorio_posicion);
        dirFlags_posicion = [files_posicion.isdir];
        subFolders_posicion = files_posicion(dirFlags_posicion);
        subFolderNames_posicion = {subFolders_posicion(3:end).name};

        inclinacion = strcmp(subFolderNames_posicion,'vertical');

        if any(inclinacion(:))      %Comprueba si hay tomas inclinadas
            for k=1:length(subFolderNames_posicion)
                Directorio_toma = fullfile(Directorio_posicion,subFolderNames_posicion{k});
                files_toma = dir(Directorio_toma);
                dirFlags_toma = [files_toma.isdir];
                subFolders_toma = files_toma(dirFlags_toma);
                subFolderNames_toma = {subFolders_toma(3:end).name};
                for j=1:length(subFolderNames_toma)
                    Directorio_nube = fullfile(Directorio_toma,subFolderNames_toma{j});
                    nube=load([Directorio_nube,'\Directorio_nuevo\Nube_orientada_odo.mat']);
                    nube=struct2cell(nube);
                    nube=nube{1};

                    ptCloudOut = pctransform(nube,Matriz_transform_ICP);
                    nombre_guardar = [Directorio_nube,'\Directorio_nuevo\Nube_registrada_ICP.mat'];
                    save(nombre_guardar,'ptCloudOut')
                end
            end
        else
            %             subFolderNames_toma = subFolderNames_posicion;
            %             Directorio_toma = Directorio_posicion;

            for j=1:length(subFolderNames_posicion)
                Directorio_nube = fullfile(Directorio_posicion,subFolderNames_posicion{j});
                nube=load([Directorio_nube,'\Directorio_nuevo\Nube_orientada_odo.mat']);
                nube=struct2cell(nube);
                nube=nube{1};

                ptCloudOut = pctransform(nube,Matriz_transform_ICP);
                nombre_guardar = [Directorio,'Nube_registrada_ICP'];
                save(nombre_guardar,'ptCloudOut')
            end
        end
    end
    clc
    seguir=input('Continuar(s/n): ','s');

end
clc
end