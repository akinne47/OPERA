function res=classical_leverage(train_row,test_row,method)
%
%Prediction of Applicability Domain based on Classical Leverage Approach
%
%------------- INPUT ---------------------------------------------------
% train_row   :   Training Set (n1 x descriptors) 
% test_row    :   Test set for validation purpose (n2 x descriptors)
% method      :   Type of pre-treatment scaling needed
%                 'cent' -> Centering
%                 'scal' -> Variance Scaling
%                 'auto' -> AutoScaling (Centering + Variance Scaling)
%                 'rang' -> Range Scaling (0-1)
%                 'none' -> No Scaling
%
%------------ OUTPUT ---------------------------------------------------
% res               : Structure containing following fields:
% Ht_diag           : Diagonal values of Leverage (hat) matrix of test molecules on training set (n2 x 1)
% inorout           : Array indicating test set compounds are in or outside the applicability domain
%
% The model space can be represented by a twodimensional matrix comprising n chemicals (rows) and k variables (columns), called the descriptor
% matrix (X). The leverage of a chemical provides a measure of the distance of the chemical from the centroid of X. Chemicals close to the 
% centroid are less influential in model building than are extreme points. The leerages of all chemicals in the data set are generated by 
% manipulating X, to give the so-called Influence Matrix or Hat Matrix (H).
%
% The leverages or hat values (hi) of the chemicals (i) in the descriptor
% space are the diagonal elements of H. A �warning leverage� (h*) is generally fixed at 3p/n, where n is the number of training chemicals, 
% and p the number of model variables plus one. A chemical with high leverage in the training set greatly influences the regression line: 
% the fitted regression line is forced near to the observed value and its residual (observed-predicted value) is small, so the chemical 
% does not appear to be an outlier, even though it may actually be outside the AD. In contrast, if a chemical in the test set has a hat 
% value greater than the warning leverage h*, this means that the prediction is the result of substantial extrapolation and therefore may
% not be reliable.
%
% Reference paper:
% Current Status of Methods for Defining the Applicability Domain of (Quantitative) Structure�Activity Relationships
% The Report and Recommendations of ECVAM Workshop 52
% Tatiana I. Netzeva, Andrew P. Worth, Tom Aldenberg, Romualdo Benigni, Mark T.D.
% Cronin, Paola Gramatica, Joanna S. Jaworska, Scott Kahn, Gilles Klopman, Carol A. Marchant, Glenn Myatt, Nina Nikolova-Jeliazkova, 
% Grace Y. Patlewicz, Roger Perkins, David W. Roberts, Terry W. Schultz, David T. Stanton, Johannes J.M. van de Sandt, Weida Tong, 
% Gilman Veith and Chihae Yang
%
% ATLA 33, 1�19, 2005
%
% Faizan Sahigara
% Milano Chemometrics and QSAR Research Group
% www.disat.unimib.it/chm
%


%disp('The training set is :')
%disp(train_row)
%disp('The test set is :')
%disp(test_row)

% trset=train_row;
% tstset=test_row;

k=size(train_row,2);
train_row(:,k+1)=1;

l=size(test_row,2);
test_row(:,l+1)=1;

% Data pre-treatment for training and test sets
%data_scal=data_pretreatment(train_row,method);
%train_row=data_scal;
%disp('The training set after scaling:')
%disp(train)

%test_scal=test_pretreatment(train_row,test_row,method);
%test_row=test_scal;
%disp('The test set after scaling:')
%disp(test)


% [pp,PS]=mapminmax(train_row');
% train=pp';
% ppt=mapminmax('apply',test_row',PS);
% test=ppt';

% Leverage calculation and setting the threshold

[Ht_diag,threshold]=calc_lev(train_row,test_row); %[H,Ht,H_diag,

res.Ht_diag=Ht_diag;
%res.H=H;

% Matrix to see which test molecules fall within AD

inorout=outputmatrix(Ht_diag,threshold);
res.inorout=inorout;
res.nout=sum(inorout);

%plot_data(train,test,H_diag,Ht_diag,threshold)

%plotmds(trset,tstset,inorout)

%m=mean(train);
end
%===============================================================================================================================

% Function for training set pre_treatment 
function data_scal=data_pretreatment(data,method)
if strcmp(method,'cent')
% Mean centering: Each descriptor (column) value is substracted with its mean. The mean in treated data will be 0.
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            data_scal(i,j)=data(i,j)-mean(data(:,j));
        end
    end
elseif strcmp(method,'scal')
% Scaling: Each descriptor (column) value is divided by its standard deviation.
     for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if std(data(:,j))==0
                data_scal(i,j)=0;
            else
                data_scal(i,j)=data(i,j)/std(data(:,j));
            end
        end
     end
elseif strcmp(method,'auto')
% AutoScaling: The value is substrated with its mean and then divided by its standard deviation (Centering + Scaling)
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if std(data(:,j))==0
                data_scal(i,j)=0;
            else
                data_scal(i,j)= (data(i,j)-mean(data(:,j)))/std(data(:,j));
            end
        end
    end
elseif strcmp(method,'rang')
% Range Scaling: Descriptor (column) value is first substrated from its min value and then divided by the difference between max and min value for that descriptor (column).
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if(max(data(:,j)))==0
                data_scal(i,j)=0;
            else
                data_scal(i,j)=((data(i,j)-min(data(:,j)))/(max(data(:,j))-min(data(:,j))));
            end
        end
        
    end
else
data_scal=data;
end

end

%===============================================================================================================================

% Function for test set pre_treatment
function test_scal=test_pretreatment(train,data,method)
if strcmp(method,'cent')
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            test_scal(i,j)=data(i,j)-mean(train(:,j));
        end
    end
elseif strcmp(method,'scal')
     for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if std(train(:,j))==0
                test_scal(i,j)=0;
            else
                test_scal(i,j)=data(i,j)/std(train(:,j));
            end
        end
     end
elseif strcmp(method,'auto')
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if std(train(:,j))==0
                test_scal(i,j)=0;
            else
                test_scal(i,j)= (data(i,j)-mean(train(:,j)))/std(train(:,j));
            end
        end
    end
elseif strcmp(method,'rang')
    for i=1:length(data(:,1))
        for j=1:length(data(1,:))
            if(max(train(:,j)))==0
                test_scal(i,j)=0;
            else
                test_scal(i,j)=((data(i,j)-min(train(:,j)))/(max(train(:,j))-min(train(:,j))));
            end
        end
        
    end
else
test_scal=data;
end

end

%===============================================================================================================================

function plot_data (train,test,H_diag,Ht_diag,threshold)

if length(train(1,:)) == 2
    
% If number of descriptors = 2
figure
hold on
grid on

r1 = max(train(:,1)) - min(train(:,1));

% Plot the training samples
plot(train(:,1),train(:,2),'.k')
for j=1:length(train(:,1))
    text(train(j,1) + r1/90,train(j,2),num2str(j)); 
end

% Plot the test samples
plot(test(:,1),test(:,2),'.r') 
for j=1:length(test(:,1))
    text(test(j,1) + r1/90,test(j,2),['T' num2str(j)]); 
end
hold off

title([' Scaled Training (Black) and Test Samples (Red) '])
xlabel({'Threshold:',threshold})
ylabel('Variable 1 v/s Variable 2')

figure

r1 = max(Ht_diag) - min(Ht_diag);
axis([0 length(Ht_diag) 0 max(Ht_diag)])
plot(Ht_diag,'.r')
for j=1:length(Ht_diag)
    text(j + r1/90,Ht_diag(j),num2str(j)); 
end
title([' Applicability Domain prediction using Classical Leverage Approach '])
xlabel({'Threshold:',threshold})
ylabel('Test set leverages')
line([1 length(Ht_diag)],[threshold threshold],'Color','b','LineStyle',':')

end

if length(train(1,:)) == 3
    
% If number of descriptors = 3
figure
hold on
grid on

r1 = max(train(:,1)) - min(train(:,1));

% Plot the training samples
plot3(train(:,1),train(:,2),train(:,3),'.k')
for j=1:length(train(:,1))
    text(train(j,1) + r1/90,train(j,2),num2str(j)); 
end

% Plot the test samples
plot3(test(:,1),test(:,2),test(:,3),'.r') 
for j=1:length(test(:,1))
    text(test(j,1) + r1/90,test(j,2),['T' num2str(j)]); 
end
hold off

title([' Scaled Training (Black) and Test Samples (Red) '])
xlabel('Variable 1')
ylabel('Variable 2')
zlabel('Variable 3')
end

end
%===============================================================================================================================
% Function to calculate the leverages of test molecules on training set and setting the threshold
function [Ht_diag,threshold]=calc_lev(train,test)%[H,Ht,H_diag,

 %H=(train*((train'*train)^-1)*train');
 
% p=length(train(1,:));
% n=length(train(:,1));
% %Hc_norm=(n/p)*Hc
% 
% H_diag=diag(H);
% mah_matrix=sqrt(H*n);

Ht=(test*((train'*train)^-1)*(test'));
Ht_diag=diag(Ht);

%p=length(train(1,:))+1;
p=length(train(1,:));

n=length(train(:,1));

threshold=3*(p/n);
end

%===============================================================================================================================
% Function to find test molecules fall within the defined AD or not
function inorout=outputmatrix(Ht_diag,threshold)

% Array of 0 and 1s is given as output:
% 1 indicates the compound is outside the applicability domain
% 0 indicates the compound is inside  the applicability domain

for n=1:length(Ht_diag)
    if (Ht_diag(n)>threshold)
        str2=['The compound ',num2str(n),' of test set is outside the applicability domain'];
        %disp(str2);
        inorout(n)=1;
    else
        str2=['The compound ',num2str(n),' of test set is inside the applicability domain'];
        %disp(str2);
        inorout(n)=0;
    end 
end
end

%===============================================================================================================================


function plotmds(trset,tstset,AD)

figure

tr=size(trset,1);
n=tr+size(tstset,1);
D=squareform(pdist([trset; tstset]));
[x, S] = order_mds(D,2);

%plot(trset(:,1),trset(:,2),'k.','LineStyle','none');
plot(x(1:tr,1),x(1:tr,2),'k.',x(tr+1:n,1),x(tr+1:n,2),'r.');

r1 = max(x(:,1)) - min(x(:,1));

for i=1:size(trset,1)
    PlotCircle(x(i,1),x(i,2),r1/100,500,'k');
    text(x(i,1) + r1/50,x(i,2),{i},'FontSize',12,'color','k');
end

for i=1:size(tstset,1)
   
    if AD(i,1)==0;
        %PlotCircle(tstset(i,1),tstset(i,2),maxD/10,100,'g');
        PlotCircle(x(tr+i,1),x(tr+i,2),r1/60,500,'g');
        axis square;

       
    else
        
        %PlotCircle(tstset(i,1),tstset(i,2),maxD/10,100,'r');
        PlotCircle(x(tr+i,1),x(tr+i,2),r1/60,500,'r');
        text(x(tr+i,1) + r1/50,x(tr+i,2),{i},'FontSize',12,'color','r');
        axis square;

    end
end
end