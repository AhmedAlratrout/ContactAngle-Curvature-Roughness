% /*-------------------------------------------------------------------------*\	
% You can redistribute this code and/or modify this code under the 
% terms of the GNU General Public License (GPL) as published by the  
% Free Software Foundation, either version 3 of the License, or (at 
% your option) any later version. see <http://www.gnu.org/licenses/>.
% 
% 
% The code has been developed by Ahmed AlRatrout as a part his PhD 
% at Imperial College London, under the supervision of Dr. Branko Bijeljic 
% and Prof. Martin Blunt. 
% 
% Please see our website for relavant literature:
% AlRatrout et al, AWR, 2017 - https://www.sciencedirect.com/science/article/pii/S0309170817303342
% AlRatrout et al, WRR, 2018 - https://agupubs.onlinelibrary.wiley.com/doi/pdf/10.1029/2017WR022124
% AlRatrout et al, PNAS, 2018 - http://www.pnas.org/
% 
% For further information please contact us by email:
% Ahmed AlRarout:  a.alratrout14@imperial.ac.uk
% Branko Bijeljic: b.bijeljic@imperial.ac.uk
% Martin J Blunt:  m.blunt@imperial.ac.uk
% 
% Description
%     Eliminate disconnected oil ganglia (or particles) under certain size, calculate oil saturation
% 	  and label disconnected oil ganglia (or particles).
% \*---------------------------------------------------------------------------*/

% Reading the 8-bit binary segmented 3D-image 
fID=fopen('ImageName.raw', 'r'); %// Read in as a single byte stream
A = fread(fID, 984*1014*601, 'uchar'); %// Read 3D image

I = reshape(A, [984 1014 601]); %// Reshape the image into a vector
Ifinal = flip(imrotate(I, -90),2); % // Transpose
Ifinal = flip(imrotate(Ifinal, -180),2); % // Transpose

  % Show a slice of the entered 3D-image to make sure you are reading it correctly.
    figure1_ = figure('Color','w');
    % Create axes
    axes1_ = axes('Parent',figure1_);
    hold(axes1_,'on');
%     xlabel('x-axis title');
%     ylabel('y-axis title');
    imagesc(Ifinal(:,:,50));
    hold(axes1_, 'off')
    
fclose(fID);
lengthImage = sum(length(Ifinal(Ifinal==0))+length(Ifinal(Ifinal==1))+length(Ifinal(Ifinal==2)))

Sat1 = length(Ifinal(Ifinal==2))./sum(length(Ifinal(Ifinal==0))+length(Ifinal(Ifinal==2)))

% // generate image with oil (vxls=2) and brine (vxls=0) phases only.
I2 = imsubtract(Ifinal,1); 
I2(I2==-1)=0;
[L, NUM] = bwlabeln(I2);

% // Remove solid phase (voxels = 1)
I3 = Ifinal;
I3(I3==2)=0;


% // Show a single slice of the labelled 3D-image    
   % Plot labeled image
    figure1 = figure('Color','w');
    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
%     xlabel('x-axis title');
%     ylabel('y-axis title');
    imagesc(L(:,:,50)); 
    hold(axes1, 'off')  
    
   I4 = bwareaopen(L, 2000);
   [L2, NUM2] = bwlabeln(I4);
   I5 = im2double(I4);
   I6 = I5.*2;
   BW = imadd(I3,I6);
    

Sat2 = length(BW(BW==2))./sum(length(BW(BW==0))+length(BW(BW==2)))
SatChange = (Sat1 - Sat2)*100


% // Show a single slice of the filtered 3D-image
     figure1 = figure('Color','w');
    % Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
%     xlabel('x-axis title');
%     ylabel('y-axis title');
    imagesc(BW(:,:,50)); 
    hold(axes1, 'off') 

%=========================================================================%    
% Print the Ganglia labeled 3D-image
fID1=fopen('AD20_Sub1_2um_984_1014_601_LabelOilGanglia1.raw', 'w');
Lfinal = imrotate(L, -90); % // Rotate to preseve the original x and y

fwrite(fID1, Lfinal, 'uchar');
fclose(fID1);
%=========================================================================% 
% Print the filtered 3D-image
fID2=fopen('AD20_Sub1_2um_984_1014_601_OilGangAbv2000voxls.raw', 'w');
Sfinal = imrotate(BW, -90); % // Rotate to preseve the original x and y

fwrite(fID2, Sfinal, 'uchar');
fclose(fID2);
