% registro_odometria.m
% Autor: Alejandro López-Rey Iglesias
% Entradas: Mapa 2D y carpeta de sesión

function registro_odometria
disp('Elija fichero de mapa')
[nombre_archivo,Directorio_datos] = uigetfile('*.pgm*');
mapa=imread(fullfile(Directorio_datos,nombre_archivo));
yaml = ReadYaml(fullfile(Directorio_datos,strcat(nombre_archivo(1:end-3),'yaml')));
origin = yaml.origin;
resolution = yaml.resolution;
%%
clc
disp('Elija la carpeta de una sesión')
Directorio = uigetdir;
files = dir(Directorio);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolderNames = {subFolders(3:end).name};

ang_guardado=0;

for i = 1 : length(subFolderNames)

    archivo_txt = [fullfile(Directorio,subFolderNames{i}), '\posicion.txt'];
    fileID = fopen(archivo_txt);
    posicion = fscanf(fileID,'%f');
    fclose(fileID);

    Directorio_posicion = fullfile(Directorio,subFolderNames{i});
    files_posicion = dir(Directorio_posicion);
    dirFlags_posicion = [files_posicion.isdir];
    subFolders_posicion = files_posicion(dirFlags_posicion);
    subFolderNames_posicion = {subFolders_posicion(3:end).name};


    inclinacion = strcmp(subFolderNames_posicion,'vertical');
    if any(inclinacion(:))      %Comprueba si hay tomas inclinadas
        Directorio_toma = fullfile(Directorio_posicion,subFolderNames_posicion{3}); %3 es vertical
        files_toma = dir(Directorio_toma);
        dirFlags_toma = [files_toma.isdir];
        subFolders_toma = files_toma(dirFlags_toma);
        subFolderNames_toma = {subFolders_toma(3:end).name};

    else
        subFolderNames_toma = subFolderNames_posicion;
        Directorio_toma = Directorio_posicion;
    end

    Directorio_nube = [Directorio_toma,'\toma1'];
    nube=load([Directorio_nube,'\Directorio_nuevo\Nube_termica.mat']);
    nube=struct2cell(nube);
    nube=nube{1};

    posicion_nube(1) = posicion(1) - origin(1);

    posicion_nube(2) = posicion(2)-origin(2)-size(mapa,1)*resolution;

    T = [posicion_nube(1:2) 0];
    ang = -posicion(3) + ang_guardado;
    ang_inc = 42;   %42 por inicializar

    while ang_inc~=0
        close all
        Matriz_rotZ = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1]; % Rotacion en z
        Matriz_transform_odo = affine3d([Matriz_rotZ [0;0;0]; T 1]);
        nube_odo = pctransform(nube,Matriz_transform_odo);

        imsurf(mapa,[],[],[],0.025);
        hold on
        pcshow(pcdownsample(nube_odo,'random',0.2))
        cameratoolbar

        ang_inc = input('ÁNGULO(°): ');
        ang = ang + deg2rad(ang_inc);
        ang_guardado = ang_guardado + deg2rad(ang_inc);
    end

    close all

    ptCloudOut = nube_odo;
    nombre = [Directorio_nube,'\Directorio_nuevo\Nube_orientada_odo'];
    save(nombre,'ptCloudOut')

    for m = 2:length(subFolderNames_toma)
        Directorio_nube = fullfile(Directorio_toma,subFolderNames_toma{m});
        nube=load([Directorio_nube,'\Directorio_nuevo\Nube_termica.mat']);
        nube=struct2cell(nube);
        nube=nube{1};
        ptCloudOut = pctransform(nube,Matriz_transform_odo);
        nombre = [Directorio_nube,'\Directorio_nuevo\Nube_orientada_odo'];
        save(nombre,'ptCloudOut')
    end
    if any(inclinacion(:))
        %Cargar nubes inclinadas
        for k=1:2
            Directorio_toma = fullfile(Directorio_posicion,subFolderNames_posicion{k});
            files_toma = dir(Directorio_toma);
            dirFlags_toma = [files_toma.isdir];
            subFolders_toma = files_toma(dirFlags_toma);
            subFolderNames_toma = {subFolders_toma(3:end).name};
            for j = 1:length(subFolderNames_toma)
                Directorio_nube = fullfile(Directorio_toma,subFolderNames_toma{j});
                nube=load([Directorio_nube,'\Directorio_nuevo\Nube_inclinada_registrada.mat']);
                nube=struct2cell(nube);
                nube=nube{1};

                ptCloudOut = pctransform(nube,Matriz_transform_odo);
                nombre = [Directorio_nube,'\Directorio_nuevo\Nube_orientada_odo'];
                save(nombre,'ptCloudOut')
            end
        end

    end
    clc
end
end

