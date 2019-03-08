function [nOut] = raiseTheRoof(n,win)


%n = Experiment(1).MovementArrayAdj
%n = outlo
%win=100
%check window win along array x to see if the moving average is two times
%higher or more, and if so double the value
nOut = zeros(size(n));
winHalf = round(win/2);
winq = round(winHalf/2);
nOut(1:winHalf) = n(1:winHalf);
nOut(end-winHalf:end) = n(end-winHalf:end);


for i = winHalf+1:length(n)-(winHalf+1)
    localM = mean(n(i-winHalf:i+winHalf));
    if localM/n(i)>2
        bumpVal = n(i)*2;
        nOut(i) = bumpVal;
        %more extreme: if a greater distance is all high activity, raise it
        %more
        if i > (winHalf+2)*3 && i < length(n)-(winHalf+1)*3 % first make sure we've cleared endpoints
            localMBigger = mean(n(i-winHalf*3:i+winHalf*3));
            if localMBigger/n(i)>2
                nOut(i-winq:i+winq) = bumpVal*2;
            end
        end
    else
        nOut(i) = n(i);
    end
end



