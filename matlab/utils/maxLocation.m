function W = maxLocation(preds,bbox,dims)

    % compute pixel location of each keypoint

    deltaX = (bbox(3)-bbox(1)+1)/dims(1);
    deltaY = (bbox(4)-bbox(2)+1)/dims(2);

    W(1,:) = preds(1,:)*deltaX - 0.5*deltaX + bbox(1);
    W(2,:) = preds(2,:)*deltaY - 0.5*deltaY + bbox(2);

end