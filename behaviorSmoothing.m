function out = behaviorSmoothing(frameGrid)
%simplified, uses whole grid.

a = squeeze(sum(frameGrid,1));
a = squeeze(sum(a,1));

for i = 1:length(a)-1
    out(i) = abs(a(i+1)-a(i));
end

out(find(out>4*std(out))) = 4*std(out);

out = smooth(smooth(out));

% figure();
% plot(out);


