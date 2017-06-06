function clickCurrentTimeLine(src,ev)

set(gcf,'windowbuttonmotionfcn',@dragCurrentTimeLine)
set(gcf,'windowbuttonupfcn',@dragCurrentTimeLineDone)