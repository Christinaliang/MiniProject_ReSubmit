function [clustCent,data2cluster,cluster2dataCell] = MeanShift(x,width)
% Step 1: pick one un-visited point as begining center and define a neighourhood;
% Step 2: shift center to the mean of that neighourhood, denied a new
% neibourhood;

% Step 3: repeat Step 1 and 2, if center doesnt move after few interation, then a cluster is
% defined.

% Step 4: pick another un-visited pioint, and repeat Setp 2 and 3;
% Step 5: if converge, check if this cluster has been defined previously,
% with a different begining point.









[numDim,NumOfPoints] = size(x);
numClust= 0;
BAND= width^2;
initPtInds= 1:NumOfPoints;
PointCheck= uint8(zeros(1,NumOfPoints));              
numInitPts=NumOfPoints;                              
Votes=uint8(zeros(1,NumOfPoints));            

while numInitPts
    StartPoint= initPtInds(ceil( (numInitPts-1e-6)*rand)); 
    CurrentMean= x(:,StartPoint);                                         % intilize mean to this points location
    thisClusterVotes= uint8(zeros(1,NumOfPoints));                        % used to resolve conflicts on cluster membership
    Members       = [];
    while 1     %loop untill convergence
        
        sqDistToAll = sum((repmat(CurrentMean,1,NumOfPoints) - x).^2);    % dist squared from mean to all points still active
        Insiders      = find(sqDistToAll < BAND);                         % points within bandWidth
        thisClusterVotes(Insiders) = thisClusterVotes(Insiders)+1;        % add a vote for all the in points belonging to this cluster
        
        
        PreviousMean   = CurrentMean;                                     % save the old mean
        CurrentMean      = mean(x(:,Insiders),2);                         % compute the new mean
        Members   = [Members Insiders];                                   % add any point within bandWidth to the cluster
        PointCheck(Members) = 1;                                          % Makr current point as "checked", so we can move on.
        
       
        

        %**** the mean converged, stop shifting mean, and then check if clusters can be merged.***
        if norm(CurrentMean-PreviousMean) < 1e-3*width
            
            %check for merge posibilities
            mergeTarget = 0;
            for cN = 1:numClust
                distToOther = norm(CurrentMean-clustCent(:,cN));     %distance from posible new clust max to old clust max
                if distToOther < width/2                             %if its within bandwidth/2 merge new and old
                    mergeTarget = cN;
                    break;
                end
            end
            
            
            if mergeTarget > 0    % something to merge
                clustCent(:,mergeTarget)       = 0.5*(CurrentMean+clustCent(:,mergeTarget));             %record the max as the mean of the two merged (I know biased twoards new ones)
                Votes(mergeTarget,:)    = Votes(mergeTarget,:) + thisClusterVotes;    % add these votes to the merged cluster
            else   
                numClust                    = numClust+1;                         % increment clusters
                clustCent(:,numClust)       = CurrentMean;                        % record the mean  
                Votes(numClust,:)    = thisClusterVotes;
            end

            break;
        end

    end
        
    initPtInds      = find(PointCheck == 0);           
    numInitPts      = length(initPtInds);                   %number of active points in set

end

[val,data2cluster] = max(Votes,[],1);                       %a point belongs to the cluster with the most votes
if nargout > 2
    cluster2dataCell = cell(numClust,1);
    for cN = 1:numClust
        myMembers = find(data2cluster == cN);
        cluster2dataCell{cN} = myMembers;
    end

end

