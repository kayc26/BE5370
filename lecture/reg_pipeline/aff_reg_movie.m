%% Load images
clf
I_full=imread('brain_fixed.png');
J_full=imread('brain_moving.png');

subplot(1,2,1); imagesc(I_full); axis image; title('fixed');
rectangle('Position', [100,70,60,40], 'EdgeColor', 'r');
subplot(1,2,2); imagesc(J_full); axis image; title('moving');
rectangle('Position', [100,80,60,40], 'EdgeColor', 'r');

%%
I=double(I_full(70:4:110,100:4:160));
J=double(J_full(80:4:120,100:4:160));

[x,y,u,v] = aff_reg_plot(I,J,pi * 30 / 180,0.,0.);

%% Make a translation movie
for p = -2.0:0.1:2.0
    a = p; b = 0.5 * p;
    aff_reg_plot(I,J,0,a,b);
    getframe();
end

%% Make a rotation movie
for theta = 0:5:360
    aff_reg_plot(I,J,pi * theta / 180,0.,0.);
    getframe();
end