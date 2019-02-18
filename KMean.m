function [T] = KMean(I,F,K,Ite)
DL   = zeros(size(F,1),K+2);                         % Initializaiton: Distances and Labels
CENTS = F( ceil(rand(K,1)*size(F,1)) ,:);             % Initializaiton: Center
for n = 1:Ite
   for i = 1:size(F,1)
      for j = 1:K  
        DL(i,j) = norm(F(i,:) - CENTS(j,:));      
      end
      [Distance, CN] = min(DL(i,1:K));               
      DL(i,K+1) = CN;                                % Update Cluster Label
      DL(i,K+2) = Distance;                          % Update Minimum Distance
   end
   for i = 1:K
      A = (DL(:,K+1) == i);                         
      CENTS(i,:) = mean(F(A,:));                      
      if sum(isnan(CENTS(:))) ~= 0                    % initilize CENTS(i,:) if needed
         NC = find(isnan(CENTS(:,1)) == 1);           
         for Ind = 1:size(NC,1)
         CENTS(NC(Ind),:) = F(randi(size(F,1)),:);
         end
      end
   end
end

X = zeros(size(F));
for i = 1:K
idx = find(DL(:,K+1) == i);
X(idx,:) = repmat(CENTS(i,:),size(idx,1),1); 
end
T = reshape(X,size(I,1),size(I,2),3);
%% Show
%figure()
%subplot(121); imshow(I); title('original')
%subplot(122); imshow(T); title('segmented')


end

