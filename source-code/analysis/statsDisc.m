%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
% Engineering - Etchverry 2162
%
% Processing disc geometry measurement data and computing bulk statistics 
% across control/kyphotic + regions of interest experimental groups.
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
folderPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\discs\measurements";

% loading all measurement data:
direcPath = dir(fullfile(folderPath, '*.mat'));
for i = 1:length(direcPath)
    baseFileName = direcPath(i).name;
    fullFileName = fullfile(folderPath, baseFileName);

    load(fullFileName) % loading .mat file
end

% keeping everything except measurement data:
clearvars -except discLevelNames subjects discWedges volDiscs ...
                    hAPs yAPs areasDisc ZsDisc

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
% The second indexing dimension, data{ii}{jj}, refers to the disc level
% jj of subject ii, where jj = [1, 2, ..., # of disc lvls in ii]. The third
% indexing dimension is used for measurements of n > 1 dimensions (like
% area and height, which area measured at various locations).

% disc spinal positions (regions of interest) partition:
all_level_names = {'T1-T2', 'T2-T3', 'T3-T4', 'T4-T5', 'T5-T6', 'T6-T7', 'T7-T8', ...
                    'T8-T9', 'T9-T10', 'T10-T11', 'T11-T12', 'T12-T13', 'T13-T14', 'T14-T15', ...
                    'T15-L1', 'L1-L2', 'L2-L3', 'L3-L4', 'L4-L5', 'L5-L6'};
ROIa_levels = {'T1-T2', 'T2-T3', 'T3-T4', 'T4-T5', 'T5-T6', 'T6-T7', 'T7-T8', ...
                'T8-T9', 'T9-T10', 'T10-T11', 'T11-T12', 'T12-T13', 'T13-T14', 'T14-T15'};
ROIb_levels = {'T15-L1', 'L1-L2', 'L2-L3', 'L3-L4', 'L4-L5', 'L5-L6'};
DisplayNameIa = 'thoracic';
DisplayNameIb = 'lumbar';
DisplayNameIIca = 'con, tho';
DisplayNameIIka = 'kyp, tho';
DisplayNameIIcb = 'con, lum';
DisplayNameIIkb = 'kyp, lum';

% control VS kyphotic partitioning processing:
iscontrol = cell(size(discLevelNames));
for ii = 1:length(discLevelNames)
    nlevels = length(discWedges{ii});
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
isROIa = cell(size(discLevelNames));
for ii = 1:length(discLevelNames)
    nlevels = length(discWedges{ii});
    isROIa{ii} = cell(1, nlevels);
    for jj = 1:nlevels
        if any(strcmp(ROIa_levels, discLevelNames{ii}{jj}))
            isROIa{ii}{jj} = 1;
        elseif any(strcmp(ROIb_levels, discLevelNames{ii}{jj}))
            isROIa{ii}{jj} = 0;
        end
    end
end

% porcine subjects overview:
ic = [1, 4, 5, 6, 9]; % indices of control porcine spines
ik = [2, 3, 7, 8]; % indices of kyphotic porcine spines
nsubjects = length(discLevelNames); % number of porcine subjects
ncontrols = length(ic); % number of control porcine subjects
nkyphotics = length(ik); % number of kyphotic porcine subjects

% porcine disc levels overview:
nca = 0; % # of control, ROIa segmentations
nka = 0; % # of kyphotic, ROIb segmentations
ncb = 0; % # of control, ROIa segmentations
nkb = 0; % # of kyphotic, ROIb segmentations
for ii = 1:nsubjects
    nlevels = length(discWedges{ii});
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
ndisc_levels = nca + nka + ncb + nkb;
ncontrol_disc_levels = nca + ncb;
nkyphotic_disc_levels = nka + nkb;
nROIa_levels = nca + nka;
nROIb_levels = ncb + nkb;

% sampling frequencies of spatial variables:
nslices = length(areasDisc{1}{1}); % # of slices in each area partition
nheights = length(hAPs{1}{1}); % # of height measurements in each height partition

% displaying results:
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('Porcine subjects overview:')
disp('# of subjects: ' + string(nsubjects))
disp('# of control subjects: ' + string(ncontrols))
disp('# of kyphotic subjects: ' + string(nkyphotics))
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
disp('Porcine disc levels overview:')
disp('# of disc levels: ' + string(ndisc_levels))
disp('# of control levels: ' + string(ncontrol_disc_levels))
disp('# of kyphotic levels: ' + string(nkyphotic_disc_levels))
disp('# of ROIa levels: ' + string(nROIa_levels) + ' (control: ' + string(nca) + ', kyphotic: ' + string(nka) + ')')
disp('# of ROIb levels: ' + string(nROIb_levels) + ' (control: ' + string(ncb) + ', kyphotic: ' + string(nkb) + ')')
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

%% Partitioning data into experimental groups wrt each disc level

% disc level proccessing
values = 1:length(all_level_names);
valuesa = 1:length(ROIa_levels);
valuesb = 1:length(ROIb_levels);
dict = containers.Map(all_level_names, values);
dicta = containers.Map(ROIa_levels, valuesa);
dictb = containers.Map(ROIb_levels, valuesb);

% bulk levels data properties:
nlevels_total = zeros(1, length(all_level_names)); % number of geometries associated w/ each level
nlevels_control = zeros(1, length(all_level_names)); % number of control geometries associated w/ each level
nlevels_kyphotic = zeros(1, length(all_level_names)); % number of kyphotic geometries associated w/ each level
for ii = 1:nsubjects
    nlevels = length(discWedges{ii});
    for jj = 1:nlevels
        I = dict(discLevelNames{ii}{jj});
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
    nlevels = length(ZsDisc{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj})
    end
end

% kyphotic vs control plotting
subplot(1,5,2)
title('Control VS kyphotic')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
for ii = 1:nsubjects
    nlevels = length(areasDisc{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj}
            % plotting control vertebrae:
            pcon = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'b', 'DisplayName', 'control');
        else
            % plotting kyphotic vertebrae:
            pkyp = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'r', 'DisplayName', 'kyphotic');
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
    nlevels = length(areasDisc{ii});
    for jj = 1:nlevels
        if isROIa{ii}{jj}
            % plotting ROIa vertebrae:
            pa = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'g', 'DisplayName', DisplayNameIa);
        else
            % plotting ROIb vertebrae:
            pb = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'm', 'DisplayName', DisplayNameIb);
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
    nlevels = length(areasDisc{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting control, ROIa vertebrae:
            pca = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'b', 'DisplayName', DisplayNameIIca);
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % plotting kyphotic, ROIa vertebrae:
            pka = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'g', 'DisplayName', DisplayNameIIka);
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting control, ROIb vertebrae:
            pcb = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'm', 'DisplayName', DisplayNameIIcb);
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % plotting kyphtotic, ROIb vertebrae:
            pkb = plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'r', 'DisplayName', DisplayNameIIkb);
        end
    end
end
legend([pca pka pcb pkb])

% vertebral level plotting
subplot(1,5,5)
title('T1 - L6 discs')
xlabel('csa [mm^2]')
ylabel('height [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(areasDisc{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, discLevelNames{ii}{jj}));
        plot(areasDisc{ii}{jj}, ZsDisc{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'disc level';

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
    nlevels = length(hAPs{ii});
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
    nlevels = length(hAPs{ii});
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
    nlevels = length(hAPs{ii});
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
    nlevels = length(hAPs{ii});
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
title('T1 - L6 discs')
xlabel('sup-inf height [mm]')
ylabel('position along AP [mm]')
hold on
cmap = jet(numel(all_level_names)); % discrete colormap with 21 unique colors
for ii = 1:nsubjects
    nlevels = length(hAPs{ii});
    for jj = 1:nlevels
        % plotting area vs slice position for subject ii @ level jj:
        color_idx = find(strcmp(all_level_names, discLevelNames{ii}{jj}));
        plot(hAPs{ii}{jj}, yAPs{ii}{jj}, 'Color', cmap(color_idx, :))
    end
end
colormap(cmap);
cb = colorbar('Ticks', linspace(0, 1, numel(all_level_names)), ...
         'TickLabels', all_level_names);
cb.Label.String = 'disc level';

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

Ica = 1; % index tracker for control ROIa group
Ika = 1; % index tracker for kyphotic ROIa group
Icb = 1; % index tracker for control ROIb group
Ikb = 1; % index tracker for kyphotic ROIb group
for ii = 1:nsubjects
    nlevels = length(areasDisc{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending control, ROIa vertebrae data:
            area_ca_summary(Ica,:) = areasDisc{ii}{jj};
            hap_ca_summary(Ica,:) = hAPs{ii}{jj};
            Ica = Ica + 1;
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending kyphotic, ROIa vertebrae data:
            area_ka_summary(Ika,:) = areasDisc{ii}{jj};
            hap_ka_summary(Ika,:) = hAPs{ii}{jj};
            Ika = Ika + 1;
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending control, ROIb vertebrae data:
            area_cb_summary(Icb,:) = areasDisc{ii}{jj};
            hap_cb_summary(Icb,:) = hAPs{ii}{jj};
            Icb = Icb + 1;
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending kyphtotic, ROIb vertebrae data:
            area_kb_summary(Ikb,:) = areasDisc{ii}{jj};
            hap_kb_summary(Ikb,:) = hAPs{ii}{jj};
            Ikb = Ikb + 1;
        end
    end
end

% summarizing 3D measurements:
Nlevels_ROIa = length(ROIa_levels);
Nlevels_ROIb = length(ROIb_levels);
wedge_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing disc wedging data array, control ROIa group
wedge_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing disc wedging data array, kyphotic ROIa group
wedge_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing disc wedging data array, control ROIb group
wedge_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing disc wedging data array, kyphotic ROIb group

vol_ca_summary = zeros(min(nlevels_control), Nlevels_ROIa); % initializing disc volume data array, control ROIa group
vol_ka_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIa); % initializing disc volume data array, kyphotic ROIa group
vol_cb_summary = zeros(min(nlevels_control), Nlevels_ROIb); % initializing disc volume data array, control ROIb group
vol_kb_summary = zeros(min(nlevels_kyphotic), Nlevels_ROIb); % initializing disc volume data array, kyphotic ROIb group
for ii = 1:nsubjects
    nlevels = length(discWedges{ii});
    for jj = 1:nlevels
        if iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending control, ROIa disc data:
            Ia = dicta(discLevelNames{ii}{jj});
            Iwedgeca0 = find(wedge_ca_summary(:,Ia) == 0, 1, 'first');
            Ivolca0 = find(vol_ca_summary(:,Ia) == 0, 1, 'first');

            if ~isempty(Iwedgeca0)
                wedge_ca_summary(Iwedgeca0, Ia) = discWedges{ii}{jj};
            end
            if ~isempty(Ivolca0)
                vol_ca_summary(Ivolca0, Ia) = volDiscs{ii}{jj};
            end
        elseif ~iscontrol{ii}{jj} && isROIa{ii}{jj}
            % appending kyphotic, ROIa disc data:
            Ia = dicta(discLevelNames{ii}{jj});
            Iwedgeka0 = find(wedge_ka_summary(:,Ia) == 0, 1, 'first');
            Ivolka0 = find(vol_ka_summary(:,Ia) == 0, 1, 'first');

            if ~isempty(Iwedgeka0)
                wedge_ka_summary(Iwedgeka0, Ia) = discWedges{ii}{jj};
            end
            if ~isempty(Ivolka0)
                vol_ka_summary(Ivolka0, Ia) = volDiscs{ii}{jj};
            end
        elseif iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending control, ROIb disc data:
            Ib = dictb(discLevelNames{ii}{jj});
            Iwedgecb0 = find(wedge_cb_summary(:,Ib) == 0, 1, 'first');
            Ivolcb0 = find(vol_cb_summary(:,Ib) == 0, 1, 'first');

            if ~isempty(Iwedgecb0)
                wedge_cb_summary(Iwedgecb0, Ib) = discWedges{ii}{jj};
            end
            if ~isempty(Ivolcb0)
                vol_cb_summary(Ivolcb0, Ib) = volDiscs{ii}{jj};
            end
        elseif ~iscontrol{ii}{jj} && ~isROIa{ii}{jj}
            % appending kyphtotic, ROIb disc data:
            Ib = dictb(discLevelNames{ii}{jj});
            Iwedgekb0 = find(wedge_kb_summary(:,Ib) == 0, 1, 'first');
            Ivolkb0 = find(vol_kb_summary(:,Ib) == 0, 1, 'first');

            if ~isempty(Iwedgekb0)
                wedge_kb_summary(Iwedgekb0, Ib) = discWedges{ii}{jj};
            end
            if ~isempty(Ivolkb0)
                vol_kb_summary(Ivolkb0, Ib) = volDiscs{ii}{jj};
            end
        end
    end
end

%% Exporting summary arrays

% exporting measurement summary arrays:
exportPath = "C:\Users\yousuf\Desktop\grad\projects\imaging\protocols\statistics\disc-summary";
filePath = append(exportPath, '\', 'summary_arrays.mat');
save(filePath, 'area_ca_summary', 'area_ka_summary', 'area_cb_summary', 'area_kb_summary', ...
                'hap_ca_summary', 'hap_ka_summary', 'hap_cb_summary', 'hap_kb_summary', ...
                'wedge_ca_summary', 'wedge_ka_summary', 'wedge_cb_summary', 'wedge_kb_summary', ...
                'vol_ca_summary', 'vol_ka_summary', 'vol_cb_summary', 'vol_kb_summary', ...
                'ROIa_levels', 'ROIb_levels', 'DisplayNameIa', 'DisplayNameIb');
