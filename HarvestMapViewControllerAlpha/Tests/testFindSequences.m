q=[-100 te0 0 0 -100 -100 -100 -100 0 0 -100 -100 0 0 0 0 0 -100 -100 -100 -100 -100];
a=diff([0 q 0]);
b=find(a==-100); % start
c=find(a==100)-1; % end
