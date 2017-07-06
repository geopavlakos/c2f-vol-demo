function L = limbLength(S,skel)

    % compute limb lengths given the skeleton structure

    L = [];
    for i = 1:length(skel.tree)
        if ~ isempty(skel.tree(i).children)
            for j = skel.tree(i).children
                L = [L,norm(S(1:3,i)-S(1:3,j))];
            end
        end
    end
    
end