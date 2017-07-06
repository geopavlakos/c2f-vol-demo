%% Visualization for Human3.6M sample data
% We assume that the network has already been applied on the Human3.6M sample images.
% This code reads the network predictions and visualizes them.
% The demo sequence is Posing_1 from Subject 9 and from camera with code 55011271.

clear; startup;

% define paths for data and predictions
datapath = '../data/h36m-sample/';
predpath = '../exp/h36m-sample/';
annotfile = sprintf('%s/annot/valid.mat',datapath);
load(annotfile);

% define the reconstruction from the volumetric representation
% if recType = 1, we use the groundtruth depth of the root joint
% if recType = 2, we estimate the root depth based on the subject's skeleton size
% if recType = 3, we estimate the root depth based on the training subjects' mean skeleton size
recType = 3;

% volume parameters
outputRes = 64;     % x,y resolution
depthRes = 64;      % z resolution
numKps = 17;        % number of joints

% main loop to read network output and visualize it
nPlot = 3;
h = figure('position',[300 300 200*nPlot 200]);
for img_i = 1:length(annot.imgname)
    
    % read input info
    imgname = annot.imgname{img_i};
    center = annot.center(img_i,:);
    scale = annot.scale(img_i);
    Sgt = squeeze(annot.S(img_i,:,:));
    K = annot.K{img_i};
    
    Lgt = limbLength(Sgt,skel);
    zroot = Sgt(3,1);
    bbox = getHGbbox(center,scale);
    I = imread(sprintf('%s/images/%s.jpg',datapath,imgname));
    img_crop = cropImage(I,bbox);
    
    % read network's output
    joints = hdf5read([predpath 'valid_' num2str(img_i)  '.h5'],'preds3D');
    % pixel location
    W = maxLocation(joints(1:2,:),bbox,[outputRes,outputRes]);
    % depth (relative to root)
    Zrel = Zcen(joints(3,:));
    
    % reconstruct 3D skeleton
    if recType == 1
        S = estimate3D(W,Zrel,K,zroot);
    elseif recType == 2
        S = estimate3D(W,Zrel,K,Lgt,skel);
    elseif recType == 3
        S = estimate3D(W,Zrel,K,Ltr,skel);
    end
    
    % visualization
    clf;
    % image
    subplot('position',[0/nPlot 0 1/nPlot 1]);
    imshow(img_crop); hold on;
    % 3D reconstructed pose
    subplot('position',[1/nPlot 0 1/nPlot 1]);
    vis3Dskel(S,skel);
    % 3D reconstructed pose in novel view
    subplot('position',[2/nPlot 0 1/nPlot 1]);
    vis3Dskel(S,skel,'viewpoint',[-90 0]);
    camroll(10);
    pause(0.01);
    
end