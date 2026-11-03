close all; clear; clc;
REPO = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); % repository root

video_folder = [REPO,'/output/movie_title/'];

X = -26:0.2:33;
ti = title(num2str(1,'%.1f'),'FontWeight','normal');
set(gca,'FontSize', 20);
set(ti, 'horizontalAlignment', 'right')

for x_i = 1:length(X)
    x_temp = X(x_i);
    if x_temp<0
        ti.String = [char(8211),num2str(-x_temp,'%.1f')];
    else
        ti.String = [num2str(x_temp,'%.1f')];
    end

    saveas(gcf, [video_folder,'title_',num2str(x_i, '%03d'),'.jpg'])
end




