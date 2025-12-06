%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Processing vertebral segmentation measurement data and computing bulk
% statistics across control/kyphotic + regions of interest experimental groups.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

set(0,'DefaultFigureWindowStyle','docked')
set(groot, 'defaultAxesFontName', 'Times New Roman', ...
            'defaultTextFontName', 'Times New Roman', ...
            'defaultAxesFontSize', 12);
warning('off','all')

%% Importing segmentation measurement data
% Unless otherwise stated, dimensions are in mm

% path of the segmentation measurement data:
folderPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\vertebrae\measurements";

% loading all measurement data:
direcPath = dir(fullfile(folderPath, '*.mat'));
for i = 1:length(direcPath)
    baseFileName = direcPath(i).name;
    fullFileName = fullfile(folderPath, baseFileName);

    load(fullFileName) % loading .mat file
end

% keeping everything except measurement data:
clearvars -except hAPs yAPs hlats xlats areas Zs subjects levels ...
                    vols surfareas apratios lrratios areaInfs areaSups ...
                    vertebralWedges wAPs wlats zAPs zlats

%% Partitioning data into experimental groups
% Cell data arrays are in general 3D, where the first indexing dimension,
% data{ii}, refers to the porcine subject according to the following convention:
%   ii = {1 --> 643c,
%           2 --> 658k,
%           3 --> 665k,
%           4 --> 723c,
%           5 --> 735c,
%           6 --> 764c,
%           7 --> 765k,
%           8 --> 766k,
%           9 --> 778c}
% The second indexing dimension, data{ii}{jj}, refers to the vertebra level
% jj of subject ii, where jj = [1, 2, ..., # of lvls in ii]. The third
% indexing dimension is used for measurements of n > 1 dimensions (like
% area and height, which area measured at various locations).

% spinal positions (regions of interest) partition:
all_level_names = {'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', ...
                    'T8', 'T9', 'T10', 'T11', 'T12', 'T13', 'T14', ...
                    'T15', 'L1', 'L2', 'L3', 'L4', 'L5', 'L6'};
ROIa_levels = {'T1', 'T2', 'T3', 'T4', 'T5', ...
                'T6', 'T7', 'T8', 'T9', 'T10', ...
                'T11', 'T12', 'T13', 'T14', 'T15'};
ROIb_levels = {'L1', 'L2', 'L3', 'L4', 'L5', 'L6'};
DisplayNameIa = 'thoracic';
DisplayNameIb = 'lumbar';
DisplayNameIIca = 'con, tho';
DisplayNameIIka = 'kyp, tho';
DisplayNameIIcb = 'con, lum';
DisplayNameIIkb = 'kyp, lum';

% control VS kyphotic partitioning processing:
iscontrol = cell(size(levels));
for ii = 1:length(levels)
    nlevels = length(areas{ii});
    iscontrol{ii} = cell(1, nlevels);
    for jj = 1:nlevels
        if contains(subjects{ii}, 'c')
            iscontrol{ii}{jj} = 1;
        elseif contains(subjects{ii}, 'k')
            iscontrol{ii}{jj} = 0;
        end
    end
end

% ROIs partitioning processing:
isROIa = cell(size(levels));
for ii = 1:length(levels)
    nlevels = length(areas{ii});
    isROIa{ii} = cell(1, nlevels);
    for jj = 1:nlevels
        if any(strcmp(ROIa_levels, levels{ii}{jj}))
            isROIa{ii}{jj} = 1;
        elseif any(strcmp(ROIb_levels, levels{ii}{jj}))
            isROIa{ii}{jj} = 0;
        end
    end
end

% porcine subjects overview:
ic = [1, 4, 5, 6, 9]; % indices of control porcine spines
ik = [2, 3, 7, 8]; % indices of kyphotic porcine spines
nsubjects = length(levels); % number of porcine subjects
ncontrols = length(ic); % number of control porcine subjects
nkyphotics = length(ik); % number of kyphotic porcine subjects

% porcine vertebral levels overview:
nca = 0; % # of control, ROIa segmentations
nka = 0; % # of kyphotic, ROIb segmentations
ncb = 0; % # of control, ROIa segmentations
nkb = 0; % # of kyphotic, ROIb segmentations
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            nca = nca + 1;
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            nka = nka + 1;
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            ncb = ncb + 1;
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            nkb = nkb + 1;
        end
    end
end
nvertebral_levels = nca + nka + ncb + nkb;
ncontrol_vertebral_levels = nca + ncb;
nkyphotic_vertebral_levels = nka + nkb;
nROIa_levels = nca + nka;
nROIb_levels = ncb + nkb;

% sampling frequencies of spatial variables:
nslices = length(areas{1}{1}); % # of slices in each area partition
nheights = length(hAPs{1}{1}); % # of height measurements in each height partition

% displaying results:
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('Porcine subjects overview:')
disp('# of subjects: ' + string(nsubjects))
disp('# of control subjects: ' + string(ncontrols))
disp('# of kyphotic subjects: ' + string(nkyphotics))
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('Porcine vertebral levels overview:')
disp('# of vertebral levels: ' + string(nvertebral_levels))
disp('# of control levels: ' + string(ncontrol_vertebral_levels))
disp('# of kyphotic levels: ' + string(nkyphotic_vertebral_levels))
disp('# of ROIa levels: ' + string(nROIa_levels) + ' (control: ' + string(nca) + ', kyphotic: ' + string(nka) + ')')
disp('# of ROIb levels: ' + string(nROIb_levels) + ' (control: ' + string(ncb) + ', kyphotic: ' + string(nkb) + ')')
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

%% Partitioning data into experimental groups wrt each vertebra level

% vertebral level proccessing
values = 1:length(all_level_names);
valuesa = 1:length(ROIa_levels);
valuesb = 1:length(ROIb_levels);
dict = containers.Map(all_level_names, values);
dicta = containers.Map(ROIa_levels, valuesa);
dictb = containers.Map(ROIb_levels, valuesb);

% bulk levels data properties:
nlevels_total = zeros(1, length(all_level_names)); % number of segmentations associated w/ each level
nlevels_control = zeros(1, length(all_level_names)); % number of control segmentations associated w/ each level
nlevels_kyphotic = zeros(1, length(all_level_names)); % number of kyphotic segmentations associated w/ each level
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        I = dict(levels{ii}{jj});
        nlevels_total(I) = nlevels_total(I) + 1;
        if iscontrol{ii}{jj}
            nlevels_control(I) = nlevels_control(I) + 1;
        else
            nlevels_kyphotic(I) = nlevels_kyphotic(I) + 1;
        end
    end
end

%% Plotting area segmentation measurements

% plotting area data:
figure
sgtitle('Bulk Area Measurements')

% raw data plotting
subplot(1,5,1)
title('Raw data')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        plot(areas{ii}{jj}, Zs{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(1,5,2)
title('Control VS kyphotic')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(areas{ii}{jj}, Zs{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(areas{ii}{jj}, Zs{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
        end
    end
end
legend([pcon pkyp])

% ROIa vs ROIb plotting
subplot(1,5,3)
title('ROIa VS ROIb')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if isROIa{ii}{jj}
            % plotting ROIa vertebrae:
            pa = plot(areas{ii}{jj}, Zs{ii}{jj}, 'g', 'DisplayName', DisplayNameIa);
        else
            % plotting ROIb vertebrae:
            pb = plot(areas{ii}{jj}, Zs{ii}{jj}, 'm', 'DisplayName', DisplayNameIb);
        end
    end
end
legend([pa pb])

% kyphotic/control + regions of interest plotting
subplot(1,5,4)
title('Diseased VS section')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting control, ROIa vertebrae:
            pca = plot(areas{ii}{jj}, Zs{ii}{jj}, 'b', 'DisplayName', DisplayNameIIca);
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting kyphotic, ROIa vertebrae:
            pka = plot(areas{ii}{jj}, Zs{ii}{jj}, 'g', 'DisplayName', DisplayNameIIka);
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting control, ROIb vertebrae:
            pcb = plot(areas{ii}{jj}, Zs{ii}{jj}, 'm', 'DisplayName', DisplayNameIIcb);
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting kyphtotic, ROIb vertebrae:
            pkb = plot(areas{ii}{jj}, Zs{ii}{jj}, 'r', 'DisplayName', DisplayNameIIkb);
        end
    end
end
legend([pca pka pcb pkb])

% vertebral level plotting
subplot(1,5,5)
title('T1 - L6')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, levels{ii}{jj}));
        plot(areas{ii}{jj}, Zs{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'vertebral level';

%% Plotting AP height segmentation measurements

% plotting AP height data:
figure
sgtitle('Bulk AP Height Measurements')

% raw data plotting
subplot(1,5,1)
title('Raw data')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting height vs AP position for subject ii @ level jj:
        plot(hAPs{ii}{jj}, yAPs{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(1,5,2)
title('Control VS kyphotic')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
        end
    end
end
legend([pcon pkyp])

% ROIa vs ROIb plotting
subplot(1,5,3)
title('ROIa VS ROIb')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if isROIa{ii}{jj}
            % plotting ROIa vertebrae:
            pa = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'g', 'DisplayName', DisplayNameIa);
        else
            % plotting ROIb vertebrae:
            pb = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'm', 'DisplayName', DisplayNameIb);
        end
    end
end
legend([pa pb])

% kyphotic/control + regions of interest plotting
subplot(1,5,4)
title('Diseased VS section')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting control, ROIa vertebrae:
            pca = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'b', 'DisplayName', DisplayNameIIca);
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting kyphotic, ROIa vertebrae:
            pka = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'g', 'DisplayName', DisplayNameIIka);
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting control, ROIb vertebrae:
            pcb = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'm', 'DisplayName', DisplayNameIIcb);
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting kyphtotic, ROIb vertebrae:
            pkb = plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'r', 'DisplayName', DisplayNameIIkb);
        end
    end
end
legend([pca pka pcb pkb])

% vertebral level plotting
subplot(1,5,5)
title('T1 - L6')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, levels{ii}{jj}));
        plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'vertebral level';

%% Plotting lateral height segmentation measurements

% plotting lateral height data:
figure
sgtitle('Bulk Lateral Height Measurements')

% raw data plotting
subplot(2,1,1)
title('Raw data')
xlabel('position along lateral [mm]')
ylabel('lateral height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting lateral position vs height for subject ii @ level jj:
        plot(xlats{ii}{jj}, hlats{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(2,1,2)
title('Control VS kyphotic')
xlabel('position along lateral [mm]')
ylabel('lateral height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(xlats{ii}{jj}, hlats{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(xlats{ii}{jj}, hlats{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
        end
    end
end
legend([pcon pkyp])

%% Plotting AP width segmentation measurements

% plotting AP width (VS inf-sup axis) data:
figure
sgtitle('Bulk AP Width Measurements')

% raw data plotting
subplot(1,5,1)
title('Raw data')
xlabel('AP width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        plot(wAPs{ii}{jj}, zAPs{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(1,5,2)
title('Control VS kyphotic')
xlabel('AP width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
        end
    end
end
legend([pcon pkyp])

% ROIa vs ROIb plotting
subplot(1,5,3)
title('ROIa VS ROIb')
xlabel('AP width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if isROIa{ii}{jj}
            % plotting ROIa vertebrae:
            pa = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'g', 'DisplayName', DisplayNameIa);
        else
            % plotting ROIb vertebrae:
            pb = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'm', 'DisplayName', DisplayNameIb);
        end
    end
end
legend([pa pb])

% kyphotic/control + regions of interest plotting
subplot(1,5,4)
title('Diseased VS section')
xlabel('AP width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting control, ROIa vertebrae:
            pca = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'b', 'DisplayName', DisplayNameIIca);
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting kyphotic, ROIa vertebrae:
            pka = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'g', 'DisplayName', DisplayNameIIka);
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting control, ROIb vertebrae:
            pcb = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'm', 'DisplayName', DisplayNameIIcb);
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting kyphtotic, ROIb vertebrae:
            pkb = plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'r', 'DisplayName', DisplayNameIIkb);
        end
    end
end
legend([pca pka pcb pkb])

% vertebral level plotting
subplot(1,5,5)
title('T1 - L6')
xlabel('AP width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, levels{ii}{jj}));
        plot(wAPs{ii}{jj}, zAPs{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'vertebral level';

%% Plotting lateral width segmentation measurements

% plotting lateral width (VS inf-sup axis) data:
figure
sgtitle('Bulk Lateral Width Measurements')

% raw data plotting
subplot(1,5,1)
title('Raw data')
xlabel('Lateral width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        plot(wlats{ii}{jj}, zlats{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(1,5,2)
title('Control VS kyphotic')
xlabel('Lateral width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
        end
    end
end
legend([pcon pkyp])

% ROIa vs ROIb plotting
subplot(1,5,3)
title('ROIa VS ROIb')
xlabel('Lateral width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if isROIa{ii}{jj}
            % plotting ROIa vertebrae:
            pa = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'g', 'DisplayName', DisplayNameIa);
        else
            % plotting ROIb vertebrae:
            pb = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'm', 'DisplayName', DisplayNameIb);
        end
    end
end
legend([pa pb])

% kyphotic/control + regions of interest plotting
subplot(1,5,4)
title('Diseased VS section')
xlabel('Lateral width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting control, ROIa vertebrae:
            pca = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'b', 'DisplayName', DisplayNameIIca);
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting kyphotic, ROIa vertebrae:
            pka = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'g', 'DisplayName', DisplayNameIIka);
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting control, ROIb vertebrae:
            pcb = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'm', 'DisplayName', DisplayNameIIcb);
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting kyphtotic, ROIb vertebrae:
            pkb = plot(wlats{ii}{jj}, zlats{ii}{jj}, 'r', 'DisplayName', DisplayNameIIkb);
        end
    end
end
legend([pca pka pcb pkb])

% vertebral level plotting
subplot(1,5,5)
title('T1 - L6')
xlabel('Lateral width [mm]')
ylabel('position along inf-sup axis [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, levels{ii}{jj}));
        plot(wlats{ii}{jj}, zlats{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'vertebral level';

%% Bulk statistics --> summary statistics
% Constructing and exporting (N x M) data arrays for all associated
% measurements to be used for summary statistics, where N refers to the #
% of curve samples associated with the given measurement and M refers to
% the sampling frequency

% summarizing 2D measurements:
area_ca_summary = zeros(nca, nslices); % initializing area data array, control ROIa group
area_ka_summary = zeros(nka, nslices); % initializing area data array, kyphotic ROIa group
area_cb_summary = zeros(ncb, nslices); % initializing area data array, control ROIb group
area_kb_summary = zeros(nkb, nslices); % initializing area data array, kyphotic ROIb group

hap_ca_summary = zeros(nca, nheights); % initializing AP height data array, control ROIa group
hap_ka_summary = zeros(nka, nheights); % initializing AP height data array, kyphotic ROIa group
hap_cb_summary = zeros(ncb, nheights); % initializing AP height data array, control ROIb group
hap_kb_summary = zeros(nkb, nheights); % initializing AP height data array, kyphotic ROIb group

hl_ca_summary = zeros(nca, nheights); % initializing lateral height data array, control ROIa group
hl_ka_summary = zeros(nka, nheights); % initializing lateral height data array, kyphotic ROIa group
hl_cb_summary = zeros(ncb, nheights); % initializing lateral height data array, control ROIb group
hl_kb_summary = zeros(nkb, nheights); % initializing lateral height data array, kyphotic ROIb group

wAP_ca_summary = zeros(nca, nslices); % initializing AP width data array, control ROIa group
wAP_ka_summary = zeros(nka, nslices); % initializing AP width data array, kyphotic ROIa group
wAP_cb_summary = zeros(ncb, nslices); % initializing AP width data array, control ROIb group
wAP_kb_summary = zeros(nkb, nslices); % initializing AP width data array, kyphotic ROIb group

wlat_ca_summary = zeros(nca, nslices); % initializing lateral width data array, control ROIa group
wlat_ka_summary = zeros(nka, nslices); % initializing lateral width data array, kyphotic ROIa group
wlat_cb_summary = zeros(ncb, nslices); % initializing lateral width data array, control ROIb group
wlat_kb_summary = zeros(nkb, nslices); % initializing lateral width data array, kyphotic ROIb group

Ica = 1; % index tracker for control ROIa group
Ika = 1; % index tracker for kyphotic ROIa group
Icb = 1; % index tracker for control ROIb group
Ikb = 1; % index tracker for kyphotic ROIb group
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending control, ROIa vertebrae data:
            area_ca_summary(Ica,:) = areas{ii}{jj};
            hap_ca_summary(Ica,:) = hAPs{ii}{jj};
            hl_ca_summary(Ica,:) = hlats{ii}{jj};
            wAP_ca_summary(Ica,:) = wAPs{ii}{jj};
            wlat_ca_summary(Ica,:) = wlats{ii}{jj};
            Ica = Ica + 1;
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending kyphotic, ROIa vertebrae data:
            area_ka_summary(Ika,:) = areas{ii}{jj};
            hap_ka_summary(Ika,:) = hAPs{ii}{jj};
            hl_ka_summary(Ika,:) = hlats{ii}{jj};
            wAP_ka_summary(Ika,:) = wAPs{ii}{jj};
            wlat_ka_summary(Ika,:) = wlats{ii}{jj};
            Ika = Ika + 1;
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending control, ROIb vertebrae data:
            area_cb_summary(Icb,:) = areas{ii}{jj};
            hap_cb_summary(Icb,:) = hAPs{ii}{jj};
            hl_cb_summary(Icb,:) = hlats{ii}{jj};
            wAP_cb_summary(Icb,:) = wAPs{ii}{jj};
            wlat_cb_summary(Icb,:) = wlats{ii}{jj};
            Icb = Icb + 1;
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending kyphtotic, ROIb vertebrae data:
            area_kb_summary(Ikb,:) = areas{ii}{jj};
            hap_kb_summary(Ikb,:) = hAPs{ii}{jj};
            hl_kb_summary(Ikb,:) = hlats{ii}{jj};
            wAP_kb_summary(Ikb,:) = wAPs{ii}{jj};
            wlat_kb_summary(Ikb,:) = wlats{ii}{jj};
            Ikb = Ikb + 1;
        end
    end
end

% summarizing 3D measurements:
Nlevels_ROIa = length(ROIa_levels);
Nlevels_ROIb = length(ROIb_levels);
vol_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing volume data array, control ROIa group
vol_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing volume data array, kyphotic ROIa group
vol_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing volume data array, control ROIb group
vol_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing volume data array, kyphotic ROIb group

sa_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing surface area data array, control ROIa group
sa_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing surface area data array, kyphotic ROIa group
sa_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing surface area data array, control ROIb group
sa_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing surface area data array, kyphotic ROIb group

aI_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing inferior surface area data array, control ROIa group
aI_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing inferior surface area data array, kyphotic ROIa group
aI_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing inferior surface area data array, control ROIb group
aI_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing inferior surface area data array, kyphotic ROIb group

aS_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing superior surface area data array, control ROIa group
aS_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing superior surface area data array, kyphotic ROIa group
aS_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing superior surface area data array, control ROIb group
aS_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing superior surface area data array, kyphotic ROIb group

apr_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing AP ratio data array, control ROIa group
apr_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing AP ratio data array, kyphotic ROIa group
apr_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing AP ratio data array, control ROIb group
apr_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing AP ratio data array, kyphotic ROIb group

lrr_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing lateral ratio data array, control ROIa group
lrr_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing lateral ratio data array, kyphotic ROIa group
lrr_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing lateral ratio data array, control ROIb group
lrr_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing lateral ratio data array, kyphotic ROIb group

wedge_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing vertebral wedging data array, control ROIa group
wedge_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing vertebral wedging data array, kyphotic ROIa group
wedge_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing vertebral wedging data array, control ROIb group
wedge_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing vertebral wedging data array, kyphotic ROIb group
for ii = 1:nsubjects
    nlevels = length(areas{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending control, ROIa vertebrae data:
            Ia = dicta(levels{ii}{jj});
            Isca0 = find(sa_ca_summary(:,Ia) == 0, 1, 'first');
            Ivca0 = find(vol_ca_summary(:,Ia) == 0, 1, 'first'); 
            Iapca0 = find(apr_ca_summary(:,Ia) == 0, 1, 'first');
            Ilrca0 = find(lrr_ca_summary(:,Ia) == 0, 1, 'first');
            IaIca0 = find(aI_ca_summary(:,Ia) == 0, 1, 'first');
            IaSca0 = find(aS_ca_summary(:,Ia) == 0, 1, 'first');
            Iwedgeca0 = find(wedge_ca_summary(:,Ia) == 0, 1, 'first');

            if ~isempty(Isca0)
                sa_ca_summary(Isca0, Ia) = surfareas{ii}{jj};
            end
            if ~isempty(Ivca0)
                vol_ca_summary(Ivca0, Ia) = vols{ii}{jj};
            end
            if ~isempty(Iapca0)
                apr_ca_summary(Iapca0, Ia) = apratios{ii}{jj};
            end
            if ~isempty(Ilrca0)
                lrr_ca_summary(Ilrca0, Ia) = lrratios{ii}{jj};
            end
            if ~isempty(IaIca0)
                aI_ca_summary(IaIca0, Ia) = areaInfs{ii}{jj};
            end
            if ~isempty(IaSca0)
                aS_ca_summary(IaSca0, Ia) = areaSups{ii}{jj};
            end
            if ~isempty(Iwedgeca0)
                wedge_ca_summary(Iwedgeca0, Ia) = vertebralWedges{ii}{jj};
            end
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending kyphotic, ROIa vertebrae data:
            Ia = dicta(levels{ii}{jj});
            Iska0 = find(sa_ka_summary(:,Ia) == 0, 1, 'first');
            Ivka0 = find(vol_ka_summary(:,Ia) == 0, 1, 'first'); 
            Iapka0 = find(apr_ka_summary(:,Ia) == 0, 1, 'first');
            Ilrka0 = find(lrr_ka_summary(:,Ia) == 0, 1, 'first');
            IaIka0 = find(aI_ka_summary(:,Ia) == 0, 1, 'first');
            IaSka0 = find(aS_ka_summary(:,Ia) == 0, 1, 'first');
            Iwedgeka0 = find(wedge_ka_summary(:,Ia) == 0, 1, 'first');

            if ~isempty(Iska0)
                sa_ka_summary(Iska0, Ia) = surfareas{ii}{jj};
            end
            if ~isempty(Ivka0)
                vol_ka_summary(Ivka0, Ia) = vols{ii}{jj};
            end
            if ~isempty(Iapka0)
                apr_ka_summary(Iapka0, Ia) = apratios{ii}{jj};
            end
            if ~isempty(Ilrka0)
                lrr_ka_summary(Ilrka0, Ia) = lrratios{ii}{jj};
            end
            if ~isempty(IaIka0)
                aI_ka_summary(IaIka0, Ia) = areaInfs{ii}{jj};
            end
            if ~isempty(IaSka0)
                aS_ka_summary(IaSka0, Ia) = areaSups{ii}{jj};
            end
            if ~isempty(Iwedgeka0)
                wedge_ka_summary(Iwedgeka0, Ia) = vertebralWedges{ii}{jj};
            end
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending control, ROIb vertebrae data:
            Ib = dictb(levels{ii}{jj});
            Iscb0 = find(sa_cb_summary(:,Ib) == 0, 1, 'first');
            Ivcb0 = find(vol_cb_summary(:,Ib) == 0, 1, 'first');
            Iapcb0 = find(apr_cb_summary(:,Ib) == 0, 1, 'first');
            Ilrcb0 = find(lrr_cb_summary(:,Ib) == 0, 1, 'first');
            IaIcb0 = find(aI_cb_summary(:,Ib) == 0, 1, 'first');
            IaScb0 = find(aS_cb_summary(:,Ib) == 0, 1, 'first');
            Iwedgecb0 = find(wedge_cb_summary(:,Ib) == 0, 1, 'first');

            if ~isempty(Iscb0)
                sa_cb_summary(Iscb0, Ib) = surfareas{ii}{jj};
            end
            if ~isempty(Ivcb0)
                vol_cb_summary(Ivcb0, Ib) = vols{ii}{jj};
            end
            if ~isempty(Iapcb0)
                apr_cb_summary(Iapcb0, Ib) = apratios{ii}{jj};
            end
            if ~isempty(Ilrcb0)
                lrr_cb_summary(Ilrcb0, Ib) = lrratios{ii}{jj};
            end
            if ~isempty(IaIcb0)
                aI_cb_summary(IaIcb0, Ib) = areaInfs{ii}{jj};
            end
            if ~isempty(IaScb0)
                aS_cb_summary(IaScb0, Ib) = areaSups{ii}{jj};
            end
            if ~isempty(Iwedgecb0)
                wedge_cb_summary(Iwedgecb0, Ib) = vertebralWedges{ii}{jj};
            end
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending kyphtotic, ROIb vertebrae data:
            Ib = dictb(levels{ii}{jj});
            Iskb0 = find(sa_kb_summary(:,Ib) == 0, 1, 'first');
            Ivkb0 = find(vol_kb_summary(:,Ib) == 0, 1, 'first');
            Iapkb0 = find(apr_kb_summary(:,Ib) == 0, 1, 'first');
            Ilrkb0 = find(lrr_kb_summary(:,Ib) == 0, 1, 'first');
            IaIkb0 = find(aI_kb_summary(:,Ib) == 0, 1, 'first');
            IaSkb0 = find(aS_kb_summary(:,Ib) == 0, 1, 'first');
            Iwedgekb0 = find(wedge_kb_summary(:,Ib) == 0, 1, 'first');

            if ~isempty(Iskb0)
                sa_kb_summary(Iskb0, Ib) = surfareas{ii}{jj};
            end
            if ~isempty(Ivkb0)
                vol_kb_summary(Ivkb0, Ib) = vols{ii}{jj};
            end
            if ~isempty(Iapkb0)
                apr_kb_summary(Iapkb0, Ib) = apratios{ii}{jj};
            end
            if ~isempty(Ilrkb0)
                lrr_kb_summary(Ilrkb0, Ib) = lrratios{ii}{jj};
            end
            if ~isempty(IaIkb0)
                aI_kb_summary(IaIkb0, Ib) = areaInfs{ii}{jj};
            end
            if ~isempty(IaSkb0)
                aS_kb_summary(IaSkb0, Ib) = areaSups{ii}{jj};
            end
            if ~isempty(Iwedgekb0)
                wedge_kb_summary(Iwedgekb0, Ib) = vertebralWedges{ii}{jj};
            end
        end
    end
end

%% Exporting summary arrays

% exporting measurement summary arrays:
exportPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\statistics\vertebrae-summary";
filePath = append(exportPath, '\', 'summary_arrays.mat');
save(filePath, 'area_ca_summary', 'area_ka_summary', 'area_cb_summary', 'area_kb_summary', ...
                'hap_ca_summary', 'hap_ka_summary', 'hap_cb_summary', 'hap_kb_summary', ...
                'hl_ca_summary', 'hl_ka_summary', 'hl_cb_summary', 'hl_kb_summary', ...
                'wAP_ca_summary', 'wAP_ka_summary', 'wAP_cb_summary', 'wAP_kb_summary', ...
                'wlat_ca_summary', 'wlat_ka_summary', 'wlat_cb_summary', 'wlat_kb_summary', ...
                'vol_ca_summary', 'vol_ka_summary', 'vol_cb_summary', 'vol_kb_summary', ...
                'sa_ca_summary', 'sa_ka_summary', 'sa_cb_summary', 'sa_kb_summary', ...
                'aI_ca_summary', 'aI_ka_summary', 'aI_cb_summary', 'aI_kb_summary', ...
                'aS_ca_summary', 'aS_ka_summary', 'aS_cb_summary', 'aS_kb_summary', ...
                'apr_ca_summary', 'apr_ka_summary', 'apr_cb_summary', 'apr_kb_summary', ...
                'lrr_ca_summary', 'lrr_ka_summary', 'lrr_cb_summary', 'lrr_kb_summary', ...
                'wedge_ca_summary', 'wedge_ka_summary', 'wedge_cb_summary', 'wedge_kb_summary', ...
                'ROIa_levels', 'ROIb_levels', 'DisplayNameIa', 'DisplayNameIb');
