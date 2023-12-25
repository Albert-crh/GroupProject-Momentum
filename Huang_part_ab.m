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

% b-half
% 输入变量
K = 3;
numGroups = 5;

% 筛选出年份大于2年的公司
companyCounts = groupsummary(returnsTable, 'name');
rowsToRemove = companyCounts.GroupCount < 24;
companyCounts(rowsToRemove, :) = [];
returnsTable = innerjoin(returnsTable,companyCounts);

% 进行收益率的计算
returnsTable1 = table();
returnsTable1.name = companyCounts.name;
returnsTable1 = sortrows(returnsTable1,"name","ascend");
returnsTable = sortrows(returnsTable,"name","ascend");

returnsTable1.returnsK = zeros(height(returnsTable1), 1);% 初始化矩阵列

for i = 1:height(returnsTable1)
    if i==1
        start = 115 - K;
    % 选择过去 K 个月的收益率
        pastReturns = returnsTable.return_m(start:start+K);
        
        % 计算累积收益率
        cumulativeReturn = prod(1 + 0.01*pastReturns) - 1;
        
        % 存储结果
        returnsTable1.returnsK(i) = cumulativeReturn*100;
    else
        start = start + companyCounts.GroupCount(i) - K;
        % 选择过去 K 个月的收益率
        pastReturns = returnsTable.return_m(start:start+K);
            
            % 计算累积收益率
        cumulativeReturn = prod(1 + 0.01*pastReturns) - 1;
            
            % 存储结果
        returnsTable1.returnsK(i) = cumulativeReturn*100;
    end
end

% 合并
mergedTable = innerjoin(returnsTable,returnsTable1);

% 根据收益率分为五组
values = mergedTable.returnsK;
quantileEdges = quantile(values, linspace(0, 1, numGroups + 1));

% 对数据进行分组
groupIDs = discretize(values, quantileEdges);

% 将分组结果添加到原始表中
mergedTable.Group = groupIDs;





