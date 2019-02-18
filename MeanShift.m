function [clustCent,data2cluster,cluster2dataCell] = MeanShift(x,width)

[numDim,NumOfPoints] = size(x);
numClust        = 0;
BAND          = width^2;
initPtInds      = 1:NumOfPoints;
PointCheck = zeros(1,NumOfPoints,'uint8');              
numInitPts      = NumOfPoints;                              
Votes    = zeros(1,NumOfPoints,'uint16');            

while numInitPts
    StartPoint           = initPtInds(ceil( (numInitPts-1e-6)*rand)); 
    CurrentMean          = x(:,StartPoint);                           % intilize mean to this points location
    thisClusterVotes    = zeros(1,NumOfPoints,'uint16');         %used to resolve conflicts on cluster membership
    Members       = [];
    while 1     %loop untill convergence
        
        sqDistToAll = sum((repmat(CurrentMean,1,NumOfPoints) - x).^2);    %dist squared from mean to all points still active
        inInds      = find(sqDistToAll < BAND);               %points within bandWidth
        thisClusterVotes(inInds) = thisClusterVotes(inInds)+1;  %add a vote for all the in points belonging to this cluster
        
        
        PreviousMean   = CurrentMean;                                   %save the old mean
        CurrentMean      = mean(x(:,inInds),2);                %compute the new mean
        Members   = [Members inInds];                       %add any point within bandWidth to the cluster
        PointCheck(Members) = 1;                         %mark that these points have been visited
        
       
        

        %**** if mean doesn't move much stop this cluster ***
        if norm(CurrentMean-PreviousMean) < 1e-3*width
            
            %check for merge posibilities
            mergeWith = 0;
            for cN = 1:numClust
                distToOther = norm(CurrentMean-clustCent(:,cN));     %distance from posible new clust max to old clust max
                if distToOther < width/2                    %if its within bandwidth/2 merge new and old
                    mergeWith = cN;
                    break;
                end
            end
            
            
            if mergeWith > 0    % something to merge
                clustCent(:,mergeWith)       = 0.5*(CurrentMean+clustCent(:,mergeWith));             %record the max as the mean of the two merged (I know biased twoards new ones)
                Votes(mergeWith,:)    = Votes(mergeWith,:) + thisClusterVotes;    %add these votes to the merged cluster
            else   
                numClust                    = numClust+1;                   %increment clusters
                clustCent(:,numClust)       = CurrentMean;                       %record the mean  
                Votes(numClust,:)    = thisClusterVotes;
            end

            break;
        end

    end
        
    initPtInds      = find(PointCheck == 0);           
    numInitPts      = length(initPtInds);                   %number of active points in set

end

[val,data2cluster] = max(Votes,[],1);                %a point belongs to the cluster with the most votes
if nargout > 2
    cluster2dataCell = cell(numClust,1);
    for cN = 1:numClust
        myMembers = find(data2cluster == cN);
        cluster2dataCell{cN} = myMembers;
    end

end

