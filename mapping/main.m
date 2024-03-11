% landuse=load('landuse_amsterdam.mat');
landuse=load('landuse_seoul.mat');
[point_w,matrix_w]=boundary_pointgen(landuse.landuse{2},10);
rwy=rwy_gen(point_w,landuse.landuse{2});
% [point_o,matrix_o]=boundary_pointgen(landuse.landuse{2},100);
% point_open=boundary_pointgen(open,50)

