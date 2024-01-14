%%
% a
clear
close all
% 假设 T_wide 是包含宽格式数据的表格
% 读取数据 (如果数据不在 MATLAB 中)
return_m_hor_wide = readtable('return_monthly.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');
market_cap_lm_hor_wide=readtable('me_lag.xlsx','ReadVariableNames',true,'PreserveVariableNames',true,'Format','auto');

% 使用 stack 函数转换数据
% 假设从第三列开始的列是日期列，需要堆叠
varNamesToStack1 = return_m_hor_wide.Properties.VariableNames(3:end);
T_long1 = stack(return_m_hor_wide, varNamesToStack1, 'NewDataVariableName', 'return_m', 'IndexVariableName', 'date');

varNamesToStack2 = market_cap_lm_hor_wide.Properties.VariableNames(3:end);
T_long2 = stack(market_cap_lm_hor_wide, varNamesToStack2, 'NewDataVariableName', 'lme', 'IndexVariableName', 'date');

% 处理 NaN 值 - 删除包含 NaN 的行
T_long1 = rmmissing(T_long1);
T_long2 = rmmissing(T_long2);

% 将两个table合并
returnsTable = innerjoin(T_long1,T_long2);
%-----------------------
day=returnsTable.date;
day1=char(day);
yymm=year(day1)*12+month(day1);
returnsTable.yymm=yymm;

% b
% 处理数据，保留所有股票都有的date,防止持有某一组合到下一期时其中股票缺失
[G,yymm]=findgroups(returnsTable.yymm);
[G2,code]=findgroups(returnsTable.code);
global reserve_yymm
reserve_yymm=yymm(1:96);%由于各股票数据残缺情况不一致，决定保留有前96个月的股票
signal=splitapply(@dataclean,returnsTable.yymm,G2);
returnsTable.signal=cell2mat(signal);
returnsTable=returnsTable(returnsTable.signal==1,:);
[G,yymm]=findgroups(returnsTable.yymm);%得到新表的分组
[G2,code]=findgroups(returnsTable.code);

global k
k=3;
returns_3=splitapply(@lastreturn,returnsTable.return_m,G2);
returnsTable.returns=cell2mat(returns_3);
returnsTable_3=returnsTable(returnsTable.returns~=0,:);%得到k=3的表格
k=6;
returns_6=splitapply(@lastreturn,returnsTable.return_m,G2);
returnsTable.returns=cell2mat(returns_6);
returnsTable_6=returnsTable(returnsTable.returns~=0,:);%得到k=6的表格
k=12;
returns_12=splitapply(@lastreturn,returnsTable.return_m,G2);
returnsTable.returns=cell2mat(returns_12);
returnsTable_12=returnsTable(returnsTable.returns~=0,:);
k=24;
returns_24=splitapply(@lastreturn,returnsTable.return_m,G2);
returnsTable.returns=cell2mat(returns_24);
returnsTable_24=returnsTable(returnsTable.returns~=0,:);
% the following code are paul's part
returnsTable.returns=returnsTable.return_m*0.01;%统一用returns方便后面函数调用
[final_ret_1,ewret_table_1,~]=momentumn(returnsTable);
[final_ret_3,ewret_table_3,~]=momentumn(returnsTable_3);
[final_ret_6,~,~]=momentumn(returnsTable_6);
[final_ret_12,~,~]=momentumn(returnsTable_12);
[final_ret_24,~,~]=momentumn(returnsTable_24);
spread_1=final_ret_1(5)-final_ret_1(1);%-0.0153，每一期所有收益率最高的组合的持有到
%下一期减去所有收益率最低的组合持有到下一期的收益率
spread_3=final_ret_3(5)-final_ret_3(1);%-0.1193
spread_6=final_ret_6(5)-final_ret_6(1);%-0.2755
spread_12=final_ret_12(5)-final_ret_12(1);%-0.0333
spread_24=final_ret_24(5)-final_ret_24(1);%-0.0332
%拿到所有时间下平均的下一期的收益率，并没有发现动量效应，甚至可能因为时间跨度太大中间导致
%反向效应。也就是上一期收益率越高下一期反而约低。但是若拆解到某一组合连续的两期可以直观
%感受到更强的动量效应
%(c)
factors = unstack(ewret_table_3,'ewret_nextr','returnport1');
factors1=factors(~isnan(factors.x1),"x1");
factors2=factors(~isnan(factors.x2),"x2");
factors3=factors(~isnan(factors.x3),"x3");
factors4=factors(~isnan(factors.x4),"x4");
factors5=factors(~isnan(factors.x5),"x5");
factors_mat=[factors1,factors2,factors3,factors4,factors5];
data=table2array(factors_mat);
[coeff,score,latent,tsquared,explained,mu] = pca(data);
first_two_factors = data * coeff(:,1:2);%构造pca因子

beta1 = zeros(5,1);beta2 = zeros(5,1);
constant = ones(length(first_two_factors),1);
for i = 1:5
    [b,bint,r,rint,stats] = ...
        regress(data(:,i),[constant,first_two_factors]);
    beta1(i) = b(2);
    beta2(i) = b(3);
end
plot([beta1,beta2],'-x');
legend('First','Second');
%由图像可得到第一个因子在不同组合下表现较平稳，第二个因子在更高的收益率组合下明显有更正向
%的表现，因此第一个因子或许可以解释为市场风险因子，第二因子可能是动量因子。

%如果把原先k=3的数据data看作样本训练集，那么现在按照相同的方式构造k=1的数据作为样本外的
%测试集，当然最好应该是同样是用k=3的其他公司股票的5个portfolio，但这里方便起见勉强
%用一下吧
factors_1= unstack(ewret_table_1,'ewret_nextr','returnport1');
factors1_1=factors_1(~isnan(factors_1.x1),"x1");
factors2_1=factors_1(~isnan(factors_1.x2),"x2");
factors3_1=factors_1(~isnan(factors_1.x3),"x3");
factors4_1=factors_1(~isnan(factors_1.x4),"x4");
factors5_1=factors_1(~isnan(factors_1.x5),"x5");
factors_mat_1=[factors1_1,factors2_1,factors3_1,factors4_1,factors5_1];
data_1=table2array(factors_mat_1);
data_1=data_1(1:31,:);%使测试数量一致
beta1_1 = zeros(5,1);beta2_1 = zeros(5,1);
for i = 1:5
    [b1,bint1,r1,rint1,stats1] = ...
        regress(data_1(:,i),[constant,first_two_factors]);
    beta1_1(i) = b1(2);
    beta2_1(i) = b1(3);
end
plot([beta1_1,beta2_1],'-x')
legend('First','Second');
%作图后发现第一个因子仍然平稳，但第二个因子在上一期收益率更高的组合下反而效果更弱。可能
%因子效果在样本集外还太弱。
factor_mom=data(:,5)-data(:,1);%得到在相同时间下的上一期最高收益率组合与最低收益率组合持有到现在的收益率之差
gamma1 = zeros(5,1);
for i = 1:5
    [b2,bint2,r2,rint2,stats2] = ...
        regress(data(:,i),[constant,factor_mom]);
    gamma1(i) = b2(2);
end
plot(gamma1,'-x')%在样本集内同样表现良好，上一期收益率越高下一期收益率越高

gamma2 = zeros(5,1);
for i = 1:5
    [b3,bint3,r3,rint3,stats3] = ...
        regress(data_1(:,i),[constant,factor_mom]);
    gamma2(i) = b3(2);
end
plot(gamma2,'-x')%这个因子在这个测试集内，使上一期收益率越高下一期收益率越低，与pca因子表现一样
%可能是因为前面提到的测试集的选择问题，但可以推测这个因子与PCA的第二个因子在两个数据集里面有类似的表现，
%两个因子很有可能代表了一样的意义。



