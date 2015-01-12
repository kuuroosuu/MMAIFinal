function [ frameNum, court, topLeft, botLeft, topRight, botRight ] = courtDetection( fileName, frame, videoFrames )

disp('Begin court detection ... ');
[~, name] = fileparts(fileName);

if(exist(['src/cache/' name '_courtDetect.mat'], 'file'))
    load(['src/cache/' name '_courtDetect.mat']);
    disp('Court detection complete.');
    return;
end

if(~exist('videoFrames','var'))
    if(exist(['src/cache/' name '_frame.mat'], 'file'))
        load(['src/cache/' name '_frame.mat']);
    else
        videoObj = VideoReader(['video/' fileName]);
        videoFrames = read(videoObj);
        save(['src/cache/' name '_frame.mat'], 'videoFrames', '-v7.3');
    end
end

load('src\cache\courtPt.mat');
if(exist('frame','var'))
    frameNum = size(frame,2);
else
    frameNum = size(videoFrames,4);
end
court = cell(1,frameNum);
topLeft = zeros(frameNum,2);
botLeft = zeros(frameNum,2);
topRight = zeros(frameNum,2);
botRight = zeros(frameNum,2);
if(exist('frame','var'))
    for i = 1 : frameNum
        disp([num2str(i) ' / ' num2str(frameNum)]);
        [court{i}, topLeft(i,:), botLeft(i,:), topRight(i,:), botRight(i,:)] = courtSub(videoFrames(:,:,:,frame(i)), courtPt);
    end
else
    for i = 1 : frameNum
        disp([num2str(i) ' / ' num2str(frameNum)]);
        [court{i}, topLeft(i,:), botLeft(i,:), topRight(i,:), botRight(i,:)] = courtSub(videoFrames(:,:,:,i), courtPt);
    end
end
save(['src/cache/' name '_courtDetect.mat'], 'frameNum', 'court', 'topLeft', 'botLeft', 'topRight', 'botRight');
disp('Court detection complete.');

end

function [ court, topLeft, botLeft, topRight, botRight ] = courtSub ( videoFrame, courtPt )
    l = whitePixelDetection(videoFrame);
    [h, theta, rho] = hough(l);
    peaks = houghpeaks(h, 10, 'Threshold', 0.2*max(h(:)), 'NHoodSize', [ceil(size(h,1)/100)+1 ceil(size(h,2)/100)+1]);
    lines = houghlines(l, theta, rho, peaks);
    if(size(lines,2)<4)
        court = [];
        topLeft = [0 0];
        botLeft = [0 0];
        topRight = [0 0];
        botRight = [0 0];
        return
    end
    verLines = {};
    horLines = {};
    for j = 1 : size(lines,2)
        if(abs(lines(j).theta)<45)
            verLines = [verLines lines(j)];
        else
            horLines = [horLines lines(j)];
        end
    end
    lx = inf;
    rx = -inf;
    for j = 1 : size(verLines,2)
        tmp = (verLines{j}.rho - sin(verLines{j}.theta*pi/180)*(size(l,1)/2)) / cos(verLines{j}.theta*pi/180);
        if(tmp < lx)
            lLine = verLines{j};
            lx = tmp;
        end
        if(tmp > rx)
            rLine = verLines{j};
            rx = tmp;
        end
    end
    ty = -inf;
    by = inf;
    for j = 1 : size(horLines,2)
        if(horLines{j}.rho < 0)
            if(horLines{j}.rho > ty)
                tLine = horLines{j};
                ty = horLines{j}.rho;
            end
            if(horLines{j}.rho < by)
                bLine = horLines{j};
                by = horLines{j}.rho;
            end
        end
    end
    if(~exist('lLine','var') || ...
            ~exist('tLine','var') || ...
            ~exist('bLine','var') || ...
            ~exist('bLine','var'))
        court = [];
        topLeft = [0 0];
        botLeft = [0 0];
        topRight = [0 0];
        botRight = [0 0];
        return
    end
    lt = houghLineIntersect(lLine, tLine)';
    rt = houghLineIntersect(rLine, tLine)';
    lb = houghLineIntersect(lLine, bLine)';
    rb = houghLineIntersect(rLine, bLine)';
    if(norm(lt-rt,2) < 10 || ... 
            norm(lt-lb,2) < 1 || ... 
            norm(lt-rb,2) < 1 || ... 
            norm(rt-lb,2) < 1 || ... 
            norm(rt-rb,2) < 1 || ... 
            norm(lb-rb,2) < 1)
        court = [];
        topLeft = [0 0];
        botLeft = [0 0];
        topRight = [0 0];
        botRight = [0 0];
        return
    end
    court = squrMap([courtPt(21,:);courtPt(1,:);courtPt(5,:);courtPt(25,:)], [lb;lt;rt;rb], courtPt);
    topLeft = court(1,:);
    botLeft = court(21,:);
    topRight = court(5,:);
    botRight = court(25,:);
end
