function value = nextr(T)
%NEXTR 此处显示有关此函数的摘要
%   使用这个函数去找到股票对应的下一期的收益率
if length(T)==1
    r(1)=nan;
    value={r};
elseif length(T)==2
    r=[T(1);nan];
    value={r};
else
    r=T(2:end);
    r(end+1)=nan;
    value={r};
end
end


