function [final_ret,ewret_table,returnport2]  = momentumn(returnsTable)
%UNTITLED 此处显示有关此函数的摘要
%  使用这个函数去得到分组后的收益率
[G,code]=findgroups(returnsTable.code);%根据公司分组
nexttime_r=splitapply(@nextr,returnsTable.returns,G);%使用函数得到下一期的利率
returnsTable.nexttime_r=cell2mat(nexttime_r);%加入表格中

[G2,yymm]=findgroups(returnsTable.yymm);%根据月分组
N=5;%分5组
return_bp = zeros(length(yymm),N-1);%记录分割点,这个是按月分
for i = 1:N-1
    divide = @(input)prctile(input,i/N*100);
    return_bp(:,i) = splitapply(divide,returnsTable.returns,G2);
end
return_breaks = table(yymm,return_bp);
returnsTable1 = outerjoin(returnsTable,return_breaks,'Keys','yymm','MergeKeys',true,'Type','left');%连接表格与分割点
returnport = rowfun(@return_bucket,returnsTable1(:,{'returns','return_bp'}),'OutputFormat','cell');%得到收益率排序
returnsTable1.returnport = cell2mat(returnport);%得到排名
[G3,yymm1,returnport1] = findgroups(returnsTable1.yymm,returnsTable1.returnport);%根据时间和排名分组
ewret = splitapply(@mean,returnsTable1.returns,G3);%得到相同时间、排名下的等权平均
ewret_nextr=splitapply(@nanmean,returnsTable1.nexttime_r,G3);%持有到下一期的收益的平均
ewret_table = table(ewret,ewret_nextr,yymm1,returnport1);
[G4,returnport2] = findgroups(ewret_table.returnport1);%把相同时间的都放到一块
final_ret = splitapply(@nanmean,ewret_table(:,{'ewret_nextr'}),G4);%得到最终的结果
end

