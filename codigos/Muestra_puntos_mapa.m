% Muestra_puntos_mapa.m
% Autor: Alejandro López-Rey Iglesias
% Entradas: Mapa 2D y carpeta de sesión
% Salida: Figura indicando las posiciones y orientaciones
% Muestra las posiciones y orientaciones que ha usado el Mopad 2 

function Muestra_puntos_mapa

disp('Elija fichero de mapa')
[nombre_archivo,Directorio_datos] = uigetfile('*.pgm*');
mapa=imread(fullfile(Directorio_datos,nombre_archivo));
yaml = ReadYaml(fullfile(Directorio_datos,strcat(nombre_archivo(1:end-3),'yaml')));
origin = yaml.origin;
resolution = yaml.resolution;

clc
disp('Elija la carpeta donde se encuentran todas las tomas')
Directorio = uigetdir;
files = dir(Directorio);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
subFolderNames = {subFolders(3:end).name};
ruta = zeros(length(subFolderNames),3);
for i = 1 : length(subFolderNames)
    ruta(i,1:3) = load([fullfile(Directorio,subFolderNames{i}),'\posicion.txt']);
end


x = ruta(:,1);
y = ruta(:,2);
orientacion = ruta(:,3);


x = round((x- origin(1))/resolution);
y = round(-(y-origin(2))/resolution+size(mapa,1));

L=50;
x2=x+(L*cos(orientacion));
y2=y+(L*sin(orientacion));

figure
f = imshow(mapa);

%title('Indica la orientación de la cámara RGB')
hold on
plot(x,y,'*','MarkerSize',10)
for i=1:length(x)
    plot([x(i) x2(i)],[y(i) y2(i)],'r','LineWidth',2)
    text(x(i)+10,y(i)+10,subFolderNames{i}(9:end))
end

cd(Directorio)
savefig('posiciones.fig')
clc
disp('Cierra la figura para continuar')
waitfor(f)
clc
end