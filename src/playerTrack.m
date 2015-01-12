function [PlayInUpCol,PlayInUpRow,PlayInDownCol,PlayInDownRow] = playerTrack( VideofileName,numberOfFrame ,lt,rt,lb,rb)
%read the frame from video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xyloObj = VideoReader(VideofileName);
rows = xyloObj.Height;
cols = xyloObj.Width;
RGB = read(xyloObj,numberOfFrame);
%spilt court
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i=(int16(lb(2,1))-(rows/4)):rows
%       for j=int16(lb(1,1)):int16(rb(1,1))
%           courtDownHalf(i-(int16(lb(2,1))-(rows/4))+1,j-int16(lb(1,1))+1,:)=RGB(i,j,:);
%       end
% end
%i=centerline to rows
int16(lb(2,1))-(rows/4)
int16(lt(2,1))+(rows/12)
for i=(int16(lb(2,1))-(rows/4)):rows
    for j=1:cols
        frameDownHalf(i-(int16(lb(2,1))-(rows/4))+1,j,:)=RGB(i,j,:);
    end
end
%i=1 to center line 
for i=1:int16(lt(2,1))+(rows/12)
    for j=1:cols
        frameUpHalf(i,j,:)=RGB(i,j,:);
    end
end
% figure
% subplot(1,3,1),imshow(RGB);title('Image')
% subplot(1,3,2),imshow(frameDownHalf);title('Image�U�b')
% subplot(1,3,3),imshow(frameUpHalf);title('Image�W�b')
%court quntize and count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HSVDownframe = rgb2hsv(frameDownHalf);
HDownframe = HSVDownframe(:,:,1);
VDownframe = HSVDownframe(:,:,3);
[QframeDownHalfH,~] = quntize(HDownframe,12);
[QframeDownHalfV,~] = quntize(VDownframe,12);
[DRows,DCols,~] =size(HSVDownframe)
figure,imshow(frameDownHalf)
HframeDownMean=sum(sum(double(QframeDownHalfH)))/(DRows*DCols);
HframeDownVar=var(double(QframeDownHalfH(:)));
VframeDownMean=sum(sum(double(QframeDownHalfV)))/(DRows*DCols);
VframeDownVar=var(double(QframeDownHalfV(:)));
%for i=1 to height of downHalf
for i=1:rows-(int16(lb(2,1))-(rows/4))+1
    for j=1:cols
        if (abs(double(QframeDownHalfH(i,j))-HframeDownMean) > double(sqrt(HframeDownVar)) || ...
                abs(double(QframeDownHalfV(i,j))-double(VframeDownMean)) > double(sqrt(VframeDownVar)))
            frameDownYesOrNot(i,j,:) = 255;
        else            
            frameDownYesOrNot(i,j,:) = 0;
        end
    end
end

%Upframe quntize and count
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HSVUpframe = rgb2hsv(frameUpHalf);
HUpframe = HSVUpframe(:,:,1);
VUpframe = HSVUpframe(:,:,3);
[QframeUpHalfH,~] = quntize(HUpframe,12);
[QframeUpHalfV,~] = quntize(VUpframe,12);
[URows,UCols] =size(HSVUpframe);
HframeUpMean=sum(sum(double(QframeUpHalfH)))/(URows*UCols);
HframeUpVar=var(double(QframeUpHalfH(:)));
VframeUpMean=sum(sum(double(QframeUpHalfV)))/(URows*UCols);
VframeUpVar=var(double(QframeUpHalfV(:)));

%for i=1 to height of UpHalf
for i=1:int16(lt(2,1))+(rows/12)
     for j=1:cols
         if (abs(double(QframeUpHalfH(i,j))-HframeUpMean) > double(sqrt(HframeUpVar)) || ...
                 abs(double(QframeUpHalfV(i,j))-double(VframeUpMean)) > double(sqrt(VframeUpVar)))
             frameUpYesOrNot(i,j,:)=255;
         else            
             frameUpYesOrNot(i,j,:)=0;
         end
     end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fDownrows,fDowncols]=size(frameDownYesOrNot);
 for i=1:fDownrows
        for j=1:fDowncols
            %if i between center line to lb
            if(i<int16(lb(2,1))-(rows-fDownrows))
                %if j between lb to rb
                if(j>int16(lb(1,1))+int16(fDowncols/9) && j<int16(rb(1,1))-int16(fDowncols/9))
                    frameDownYesOrNot1(i,j,:)=frameDownYesOrNot(i,j,:);
                else
                    frameDownYesOrNot1(i,j,:)=255;
                end
            else
                frameDownYesOrNot1(i,j,:)=255;
            end
       end
end
Downcount=0;
sumDowni=0;
sumDownj=0;
PlayInDownXY=zeros(1000,2);
for i=1:fDownrows
     for j=1:fDowncols
         if(frameDownYesOrNot1(i,j)==0)
             Downcount=Downcount+1;
             sumDowni=sumDowni+i;
             sumDownj=sumDownj+j;
             PlayInDownXY(Downcount,1)=i;
             PlayInDownXY(Downcount,2)=j;
         end
     end
end
PlayInDownRow=ceil(double(sumDowni/Downcount)+(rows-fDownrows));
PlayInDownCol=ceil(double(sumDownj/Downcount));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fUprows,fUpcols]=size(frameUpYesOrNot);
 for i=1:fUprows
        for j=1:fUpcols
            %if i between lt to fUprows
            if(i>int16(lt(2,1))-int16(fUprows/5) && i<int16(lt(2,1)))
                %if j between lt to rt
                if(j>int16(lt(1,1))-int16(fUpcols/10) && j<int16(rt(1,1))+int16(fUpcols/10))
                    frameUpYesOrNot1(i,j,:)=frameUpYesOrNot(i,j,:);
                else
                    frameUpYesOrNot1(i,j,:)=255;
                end
            else
                frameUpYesOrNot1(i,j,:)=255;
            end
       end
end
count=0;
sumi=0;
sumj=0;
PlayInUpXY=zeros(1000,2);
for i=1:fUprows
     for j=1:fUpcols
         if(frameUpYesOrNot1(i,j)==0)
             count=count+1;
             sumi=sumi+i;
             sumj=sumj+j;
             PlayInUpXY(count,1)=i;
             PlayInUpXY(count,2)=j;
         end
     end
end
PlayInUpRow=ceil(double(sumi/count));
PlayInUpCol=ceil(double(sumj/count));
figure,image(frameDownHalf)
figure,image(frameDownYesOrNot)
figure,image(frameDownYesOrNot1)

figure,image(RGB)
hold on;
plot(PlayInDownCol,PlayInDownRow,'r.','MarkerSize',20)
plot(PlayInUpCol,PlayInUpRow,'r.','MarkerSize',20)

end
