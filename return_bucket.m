function value = return_bucket(returns,T)
%RETURN_BUCKET 此处显示有关此函数的摘要
%   使用该函数用来收益率分组
if isnan(returns)
    value=1;
elseif max(T)>returns
    value=find(T-returns>0,1,'first');%寻找第一个大于波动的分位数，后面是对应日期
elseif max(T)<=returns
    value=5;
end
end

