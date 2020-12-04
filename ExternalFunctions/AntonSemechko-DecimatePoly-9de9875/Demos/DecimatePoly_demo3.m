function DecimatePoly_demo3
% Last demo showing how DecimatePoly can be used to improve time 
% performance of an in-polygon test. 


% Read in the beetle contour
try
    C=load('DemoContours.mat','C1');
    C=C.C1;
catch err %#ok<*NASGU>
    msg={'Unable to locate demo file titled DemoContours.mat'};
    msg{2}='Make sure you unpacked contents of the DecimatePoly.zip into your current work directory.';
    for i=1:2, disp(msg{i}); end
    return
end

% Center the contour
C=[C(:,2) C(:,1)];
C=bsxfun(@minus,C,mean(C,1));
C(:,2)=-C(:,2);

% Generate a set of uniformly distributed points
x=2*rand(2E4,2)-1;
x=bsxfun(@times,x,[150 240]);

% Initialize waitbar
hw = waitbar(0,'Please be patient for 10 sec','Name','DecimatePoly demo','Color','w');
set(hw,'units','normalized')
p=get(hw,'position');
set(hw,'position',[0.5-p(3)/2 0.72+p(4) p(3:4)])

% Perform in-polygon test using original contour
tic
chk0=inpolygon(x(:,1),x(:,2),C(:,1),C(:,2));
t0=toc;


% Visualize original contour and along with sample points
hf=figure('color','w');
set(hf,'units','normalized')
set(hf,'position',[0.2 0.1 0.6 0.6])
h1=subplot(1,3,1);
plot(x(chk0,1),x(chk0,2),'+g','MarkerSize',6), hold on
plot(x(~chk0,1),x(~chk0,2),'+r','MarkerSize',6)
plot(C(:,1),C(:,2),'-k','LineWidth',2), axis equal
set(h1,'XLim',[-155 155],'YLim',[-245 245])
l=legend(h1,'inside','outside','boundary');
set(l,'Orientation','horizontal','Location','North','FontWeight','bold')

h1=get(h1,'Title');
msg=sprintf('Orgnl. Contr. = %u verts',size(C,1)-1);
set(h1,'String',msg,'FontWeight','bold','FontSize',20);
drawnow


% Initialize axes comparing the orignal and simplified contours
h2=subplot(1,3,2);

%H=plot(C(:,1),C(:,2),'-k');
H=fill(C(:,1),C(:,2),'g');
set(H,'EdgeColor','none','FaceAlpha',0.5)

axis equal, hold on
set(h2,'XLim',[-155 155],'YLim',[-245 245])
ledg={'100%'};
drawnow

waitbar(1/16,hw,sprintf('%3.0f%% complete ...',1/16*100))


% Perform in-polygon tests using simpler versions of the contour and compute  
% misclassification rates
n=15; 
j=1;
[t,Err,r]=deal(zeros(n,1));
for i=1:n
    
    % Decimate the contour
    r(i)=i+2;
    Ci=DecimatePoly(C,[r(i)/100 2]);
        
    if mod(r(i),3)==0
        j=j+1;
        H(j)=plot(h2,Ci(:,1),Ci(:,2),'-','LineWidth',2);
        ledg{j,1}=sprintf('%u%%',r(i));
    end
    
    % Perform test
    tic
    chk=inpolygon(x(:,1),x(:,2),Ci(:,1),Ci(:,2));
    t(i)=toc;
    waitbar((i+1)/16,hw,sprintf('%3.0f%% complete ...',(i+1)/16*100))
    figure(hw)
    
    % Quantify error using Dice coeff
    Err(i)=2*sum(chk&chk0)/(sum(chk)+sum(chk0));
        
end

legend(h2,H,ledg)
if ishandle(hw), delete(hw); end


% Plot the results
subplot(1,3,3);
[h3,H1,H2]=plotyy(r,Err,r,t0./t);
set(get(h3(1),'Ylabel'),'String','Dice Coeff','FontSize',20,'FontWeight','bold') 
set(get(h3(2),'Ylabel'),'String','Speed-up X','FontSize',20,'FontWeight','bold') 
set(h3,'FontSize',15)

xlabel('Percent Simplification','FontSize',20)

set(H1,'Marker','.','MarkerSize',20,'LineWidth',2)
set(H2,'Marker','.','MarkerSize',20,'LineWidth',2)

set(h3,'XLim',[0 n+5])
drawnow


