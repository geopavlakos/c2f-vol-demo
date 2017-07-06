addpath(genpath('utils'));

% skeleton struct for Human3.6M
load skel_h36m.mat
% mean limb lengths for training subjects of Human3.6M (S1,S5,S6,S7,S8)
load limb_train.mat
% discretization boundaries (and centers) for volumetric representation
load voxel_limits.mat
Zcen = (limits(1:64) + limits(2:65))/2;