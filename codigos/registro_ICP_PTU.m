% registro_ICP_PTU
% Autor: Alejandro López-Rey Iglesias
% Entradas: Nube vertical, nube inclinada, ángulo
% Salida: Nube inclinada registrada
% Realiza el registro de una nube inclinada con la nube vertical
% Devuelve la nube orientada de la toma inclinada
function nube_inclinada = registro_ICP_PTU(nube_fija,nube_movil,ang)
    %% TRANSFORMACIÓN NUBE MÓVIL
    ang = deg2rad(ang);
    Matriz_rotZ = [cos(ang) -sin(ang) 0; sin(ang) cos(ang) 0; 0 0 1];
    Matriz_transform_odo=affine3d([Matriz_rotZ [0;0;0];0 0 0 1]);
    nube_orientada_odo=pctransform(nube_movil,Matriz_transform_odo);

    %% REDUCCIÓN PARA REALIZAR ICP
    gridSize = 0.05;
    fixed = pcdownsample(nube_fija, 'gridAverage', gridSize); % Nube muestreada
    moving = pcdownsample(nube_orientada_odo, 'gridAverage', gridSize); % Nube muestreada

    %% Funcion pcnormals. Calcula normales de nubes de puntos
    % Calculamos las normales de los puntos para que funcione mejor el ICP
    % cuando usamos 'pointToPlane'

    normals_fixed=pcnormals(fixed,30);
    normals_moving=pcnormals(moving,30);
    fixed.Normal=normals_fixed;
    moving.Normal=normals_moving;
    %% ICP
    rmse=500;
    i=0.9;
    cont_min=0;
    contador=0;
    %tic
    % Itera 4 veces o hasta que hasta root mean squared error (rmse) sea
    % >0.1
    while rmse>0.1 || i==0.5
        i=i-0.1;
        contador=contador+1;
        % Se utiliza pcregistericp en vez de pcregrigid
        [tform,~,rmse] = pcregistericp(moving, fixed, 'Metric','pointToPlane','MaxIterations',20,'Verbose',false,'InlierRatio',i);
        trasnform(contador).tform=tform;

        trasnform(contador).rmse=rmse;
    end
    %toc

    Matriz_transform_ICP=tform;

    % Transformacion de la nube movil sin reducir. Es pc

    nube_inclinada = pctransform(nube_orientada_odo,Matriz_transform_ICP);
   
end