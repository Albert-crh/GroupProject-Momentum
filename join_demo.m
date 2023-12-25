% This files illustrates the idea of inner join and outer join


% First, create the demo table

% One table for stock return information

A=table();
A.firm=['a','b','c']';
A.ret=[1,2,5]';

% The second table for balance sheet information

B=table();
B.firm=['b','c','d']';
B.book=[10,30,50]'; % book value


% Link two tables together: in our case: we have one variable firm id that
% identifies observations in both tables

% Note that the variable name is the same in both tables; MATLAB
% automatically detects that;
% Otherwise, you need to specify the keys that identifies matching
% observations 

% Innerjoin

C0=innerjoin(A,B);

% Outjoin


C1=outerjoin(A,B,'MergeKeys',true); 

C2=outerjoin(A,B,'Type','Left','MergeKeys',true);

C3=outerjoin(A,B,'Type','Right','MergeKeys',true);



