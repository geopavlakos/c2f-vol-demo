function S = estimate3D(W,Zrel,K,varargin)

    if length(varargin) == 2
        L = varargin{1};
        skel = varargin{2};
        z0 = 2000;
        myFun = @(z)rootEstimate(z,W,Zrel,K,L,skel);
        zroot = fminsearch(myFun,z0);
    elseif length(varargin) == 1
        zroot = varargin{1};
    end
    
    Z = Zrel + zroot;
    
    S = computeSkel(W,Z,K);
    
end

function err = rootEstimate(d,W,Zrel,K,L,skel)

    % compute skeleton error for a candidate value of root depth (d)

    Z = Zrel + repmat(d,1,numel(Zrel));
    S = computeSkel(W,Z,K);
    Lest = limbLength(S,skel);
    err = sqrt(sum((Lest-L).^2));
    
end

function S = computeSkel(W,Z,K)

    % compute 3D coordinates given pixel coordinates and absolute depths

    fx = K(1,1);
    fy = K(2,2);
    cx = K(1,3);
    cy = K(2,3);

    X = ((W(1,:) - cx).*Z)./fx;
    Y = ((W(2,:) - cy).*Z)./fy;
    
    S = [X;Y;Z];
    
end