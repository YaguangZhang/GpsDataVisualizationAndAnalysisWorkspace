function dragCurrentTimeLine(src,ev)
clicked=get(gca,'currentpoint');
xcoord=clicked(1,1,1);

l1=findobj(gcf,'tag','line1');
l2=findobj(gcf,'tag','line2');

set([l1 l2],'xdata',[xcoord xcoord]);