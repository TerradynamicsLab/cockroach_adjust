function vq = fLinearInterpolation_YW(v)
l = length(v);
i_good = ~isnan(v);
xq = 1:l;
vq = interp1(xq(i_good),v(i_good),xq);
end