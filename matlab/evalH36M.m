%% Evaluation for Human3.6M full test set
% We assume that the network has already been applied on the Human3.6M sample images.
% This code reads the network predictions and estimates metric 3D pose 
% from the volumetric output. Full results for the Human3.6M dataset 
% (subjects S9 and S11) are printed in file H36M.txt

clear; startup;

% define paths for data and predictions
datapath = '../data/h36m/';
predpath = '../exp/h36m/';
annotfile = sprintf('%s/annot/valid.mat',datapath);
load(annotfile);
Nimg = length(annot.imgname);

% define the reconstruction from the volumetric representation
% if recType = 1, we use the groundtruth depth of the root joint
% if recType = 2, we estimate the root depth based on the subject's skeleton size
% if recType = 3, we estimate the root depth based on the training subjects' mean skeleton size
recType = 3;

% volume parameters
outputRes = 64;     % x,y resolution
depthRes = 64;      % z resolution
numKps = 17;        % number of joints

% Recover 3D predictions
Sall = zeros(Nimg,3,numKps);
for img_i = 1:Nimg
    
    % read input info
    imgname = annot.imgname{img_i};
    center = annot.center(img_i,:);
    scale = annot.scale(img_i);
    Sgt = squeeze(annot.S(img_i,:,:));
    K = annot.K{img_i};
    
    Lgt = limbLength(Sgt,skel);
    zroot = Sgt(3,1);
    bbox = getHGbbox(center,scale);
    
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
    
	Sall(img_i,:,:) = S;

end

% Print results in file H36M.txt
errorH36M(Sall,annot.S,annot.imgname);
