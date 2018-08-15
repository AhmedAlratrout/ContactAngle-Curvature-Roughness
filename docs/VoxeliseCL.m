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
%     Voxelized 3-phase contact line.
% 
% \*---------------------------------------------------------------------------*/

% Reading the 8-bit binary segmented 3D-image 
fID=fopen('AD20_Sub1_2um_984_1014_601_OilGangAbv2000voxls.raw', 'r'); %// Read in as a single byte stream
A = fread(fID, 984*1014*601, 'uchar'); %// Reshape so that it's a 3D matrix - Note that this is column major

I = reshape(A, [984 1014 601]);

% Reading the measured contact angles
filename1 = 'contactAngles_x.txt';
delimiterIn = ' ';
headerlinesIn = 1;
file1 = importdata(filename1,delimiterIn,headerlinesIn);

CA = file1.data(:,5);
x = file1.data(:,1);% vertex x-coordinates of the CL
y = file1.data(:,2);% vertex x-coordinates of the CL
z = file1.data(:,3);% vertex x-coordinates of the CL

VS = 2.00002; % voxel size of the original image
X = round(x./VS); % voxel x-coordinates of the CL
Y = round(y./VS); % voxel y-coordinates of the CL 
Z = round(z./VS); % voxel z-coordinates of the CL

B=nan(size(I)+2);
B(2:end-1,2:end-1,2:end-1)=I;
F = 0*I;

A = accumarray([X Y Z],1,[984 1014 601]);
A(A>1)=1;

%% ==================== %%
% Plot slice of 3D image
    figure1_ = figure('Color','w');
    % Create axes
    axes1_ = axes('Parent',figure1_);
    hold(axes1_,'on');
%     xlabel('Pore Diameter, microns')
%     ylabel('Fraction, %');
    imagesc(A(:,:,23)); % // Show a single slice of the 3D-image
    hold(axes1_, 'off')
%=========================================================================%
% Print the labeled image
fID1=fopen('AD20_Sub1_2um_984_1014_601_OilGangAbv2000voxls_CL.raw', 'w');

fwrite(fID1, A, 'int32');
fclose(fID1);
