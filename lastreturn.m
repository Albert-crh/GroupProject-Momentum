function value = lastreturn(T)
%UNTITLED 此处显示有关此函数的摘要
%   使用该函数计算过去k个月的累积收益率，并且只保留k频率
global k
T=T*0.01;
start=1;
cumulative_return=zeros(length(T),1);
for i=k:k:length(T)
    all_return=cumprod(T(start:i)+1)-1;%每次计算过去k个月的累积收益率
    cumulative_return(i)=all_return(end);%拿到最后一个并记录
    start=start+k;
end
value={cumulative_return};
end


