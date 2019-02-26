function [Ims Kms] = MShift(I,bandwidth, FigFlag)

I = im2double(I);
X = reshape(I,size(I,1)*size(I,2),3);                                         

[clustCent,data2cluster,clustMembsCell] = MeanShift(X',bandwidth);    % MeanShiftCluster


for i = 1:length(clustMembsCell)                                              % Replace Image Colors With Cluster Centers
X(clustMembsCell{i},:) = repmat(clustCent(:,i)',size(clustMembsCell{i},2),1); 
end
Ims = reshape(X,size(I,1),size(I,2),3);                                         % Segmented Image
Kms = length(clustMembsCell);
if FigFlag
    figure()
    subplot(121); imshow(I); title('original')
    subplot(122); imshow(Ims); title('segmented')
end


end
