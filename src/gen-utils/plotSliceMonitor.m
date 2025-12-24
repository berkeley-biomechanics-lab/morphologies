function fig = plotSliceMonitor(object, planes, fig)
% Visualizing slicing properties of 'object' which refers to a vertebra or 
% disc '.mesh' field.

    % Getting object properties:
    subjName = object.subjName;
    levelName = object.levelName;
    TR = object.alignedProperties.TR; % getting aligned TR field

    % Getting planes properties:
    Px = planes.Px; Py = planes.Py; Pz = planes.Pz;

    set(0, 'CurrentFigure', fig); clf;
    sgtitle("Subject " + subjName + " Visualization");

    % -------------------------------------------------
    % Plot object (aligned) mesh in sup-inf plane
    % -------------------------------------------------
    ax1 = subplot(4,9,[1 21]); ax1.SortMethod = 'childorder';
    hold on; view(3);
    title("Sup-inf (Z) slicing dimension for level " + levelName ,"Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')
    
    trisurf(TR,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none','FaceAlpha',0.15);

    patch('Faces', Px.faces, 'Vertices', Px.vertices, ...
      'FaceColor', 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    lighting gouraud
    camlight headlight
    material dull

    % -------------------------------------------------
    % Plot object (aligned) mesh in ant-post plane
    % -------------------------------------------------
    ax1 = subplot(4,9,[4 24]); ax1.SortMethod = 'childorder';
    hold on; view(3);
    title("Ant-post (Y) slicing dimension for level " + levelName ,"Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')
    
    trisurf(TR,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none','FaceAlpha',0.15);

    patch('Faces', Py.faces, 'Vertices', Py.vertices, ...
      'FaceColor', 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    lighting gouraud
    camlight headlight
    material dull

    % -------------------------------------------------
    % Plot object (aligned) mesh in left-right plane
    % -------------------------------------------------
    ax1 = subplot(4,9,[7 27]); ax1.SortMethod = 'childorder';
    hold on; view(3);
    title("Left-right (X) slicing dimension for level " + levelName ,"Interpreter","none");
    xlabel('X'); ylabel('Y'); zlabel('Z')
    
    trisurf(TR,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none','FaceAlpha',0.15);

    patch('Faces', Pz.faces, 'Vertices', Pz.vertices, ...
      'FaceColor', 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    lighting gouraud
    camlight headlight
    material dull

    drawnow;
end

