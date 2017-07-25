ajustedA = imadjust(A,stretchlim(A));
image(ajustedA)
ajustedMoreA = decorrstretch(A,'Tol',0.01);
image(ajustedMoreA)

%  imfill
%  strel
%  imopen

%  Automatic registration
%  Intensity based / feature based
