function [New] = TruthCorrection(Old)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

New=imbinarize(Old,0.65);
New=logical(New);
New=not(New);





end

