% INFIELDCLASSIFICATIONFORCOMBINESPARAMETERS Set the values of infield test
% parameters for combines.
%
% Yaguang Zhang, Purdue, 03/21/2015

% Fundamental rules to use in the classification: speed test + sample
% density test + quasi-colinear road extension.

% ----------------------------------------------------------------
% Parameters that need to be learned.
% ----------------------------------------------------------------
% Points with higher speed than or equal to this will be classified as -100
% (must be on the road).
ONROAD_SPEED_BOUND = 4.5; % Default 4.5 m/s (10.1 miles per hour).
MIN_DEV_IND_DENSITY_IN_FIELD = 10; % Default 10 for 200 side-width densities.

% Points scanned by the propagation algorithm with less distance to the
% "road line" than this will be classified as on the road.
INLINE_DISTANCE_BOUND = 7; % Default 7 meters (for JVK route 2).
% For basic inline propagation of low density area.
INLINE_DISTANCE_BOUND_LOW_DENSITY = 14; % Default 13.7 meters (for JVK route 34).
% For the extended propagation of far-away on-the-road segment.
INLINE_DISTANCE_BOUND_FAR = 10; % Default 3.95 meters (for JVK route 25).
% For inline test of low-density point sequences. Very strict to make
% sure it's not in a field.
INLINE_DISTANCE_BOUND_LOW_DEN_SEQ = 4.5;

% For low denstiy inline test, the newly found line should not be "inside"
% its unlabeled sequence area. This ratio is used for a rough test of this
% kind. The computed OverlapToInlineSeqRatio should be less than or equal
% to this to be accepted as valid on-the-road line. We only conduct this
% test for square field.
MAX_OVERLAP_TO_INLINE_SEQ_RATIO = 0.5;
% To detect the shape of the field, we convhull and reducem to check the
% number of points needed to roughly represent the shape. If this number >
% MIN_NUM_POINTS_NEEDED_FOR_CIRCLE, it?s treated as a circle.
MIN_NUM_POINTS_NEEDED_FOR_CIRCLE = 100;

% The minimum diameter of a valid field.
MIN_FIELD_DIAMETER = 200; % In meters.

% Note these 2 parameters are defined in labelLocationsForCombines.m.
% THRESHOLD_REALLY_LOW_DENSITY = 1000/SQUARE_SIDE_LENGTH;

% ----------------------------------------------------------------
% Parameters that can be set by common sense.
% ----------------------------------------------------------------
% Points between road sequences with time lasting less than or equal to
% this will be treated as "on the road" (-95).
GAP_FILLING_TIME_THRESHOLD = 120000; % 120s.
% Points on the extended road with time lasting larger than or equal to this
% will be treated as "on the road" (-50).
EXTENDED_PRO_TIME_THRESHOLD = 60000; % 60s.
% Points with low sample density with time lasting larger than this will be
% treated as "on the road" (-60).
LOW_DEN_TIME_THRESHOLD = 30000; % 30s.

% For each field sequence, there should be at least MIN_NUM_FIELD_SEQ
% points available. Please set this variable to be at least 3, so that a
% convhull can be used to find the filed polygon.
MIN_NUM_FIELD_SEQ = 60;


% ----------------------------------------------------------------
% Parameters that are for Matlab.
% ----------------------------------------------------------------
% The gradient bound for g to decide (x0,y0) as a "vertical data set", for
% which f may not be a good fitting. We will discard f and use g instead if
% g's gradient is smaller than this.
GRADIENT_BOUND_G_TO_DISCARD_F = 0.0001;

% EOF