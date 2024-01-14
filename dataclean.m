function signal = dataclean(T)
%DATACLEAN 此处显示有关此函数的摘要
%   使用这个函数保留有完整的前96个月数据的股票，方便后面统一分组比较
global reserve_yymm
if length(T)==length(reserve_yymm) & T==reserve_yymm
   signal=ones(length(reserve_yymm),1);
   signal={signal};
elseif length(T)>length(reserve_yymm) & T(1:length(reserve_yymm))==reserve_yymm
    signal=ones(length(reserve_yymm),1);
    signal(length(reserve_yymm)+1:length(T))=0;
    signal={signal};
else 
     signal=zeros(length(T),1);%如果不符合要求全部赋予0 
     signal={signal};
end

end
