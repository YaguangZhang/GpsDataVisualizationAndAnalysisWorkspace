   x = 0:.01:1;
   y = exp(x);
   ynoisy = y + randn(size(y))/2;
   h1 = geoshow(x,y,'Color','blue');
   hold on
   h2 = geoshow(x,ynoisy,'Color','red');
   [pl,xs,ys] = selectdata('sel','lasso','ignore',h1);