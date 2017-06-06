%TESTGENMOVIEBYGPSTIME Generate illustration movies according to the
%specified GPS time ranges and also manually set visiable areas as a test.
%
% Yaguang Zhang, Purdue, 09/16/2015

% Movie 1 to 4 are the demos for the ITSC2015 talk. Movie 1: going to the
% first field.
GPS_TIME_RANGE = [1404921635151, 1404923735151];
PLAYBACK_SPEED = 60;
% [latMin, latMax, lonMin, lonMax]
AXIS_VISIBLE =  [-1.021326433042495 -1.021189730885284 0.407038324144376 0.407105027092418]*100;
genMovieByGpsTime;

% Play a sound to notify the user to set the visible area for the next
% movie clip.
load gong.mat;
soundsc(y);

% Movie 2: harvesting the first field.
GPS_TIME_RANGE = [1404921785151, 1404930835151];
PLAYBACK_SPEED = 50;
AXIS_VISIBLE =  [-1.021347812798594 -1.021253985036183 0.407047520542614 0.407093316683585]*100;
genMovieByGpsTime;

load handel.mat;
soundsc(y);

% Movie 3: going to the second field.
GPS_TIME_RANGE = [1404928635151, 1404931835151];
PLAYBACK_SPEED = 60;
AXIS_VISIBLE = [-1.021799045157598 -1.021047390270051 0.406746812115570 0.407113746304976]*100;
genMovieByGpsTime;

load gong.mat;
soundsc(y, 2*Fs);

% Movie 4: harvesting the second field.
GPS_TIME_RANGE = [1404929375151, 1404941765151];
PLAYBACK_SPEED = 50;
AXIS_VISIBLE = [-1.021455851647390 -1.021342339755327 0.406753066478565 0.406808494282660]*100;
genMovieByGpsTime;

load handel.mat;
soundsc(y, 2*Fs);

% EOF