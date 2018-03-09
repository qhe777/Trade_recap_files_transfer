file_path = 'C:\mypath';
file_name = 'trade_recap.csv';
recap_file=fullfile(file_path, file_name);
mydate=datestr(now,'yyyy.mm.dd');
data_path = sprintf('C:\\mypath\\%s_filename',mydate);

% sheetname='Summary';
% headers={'Date','Broker','Account','Ticker_Number','Shares',...
%     'Sell_Total','Buy_Total','Approved','Sent','File_Location'};
% fid = fopen(recap_file, 'w') ;
% fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',headers{:});
% fclose(fid);
dataformat=sprintf('%s\\*.csv',data_path);
datainfo = dir(dataformat);
m = length(datainfo);
if m==2
    unionfilename_1 = regexp(datainfo(1).name,'^\w+\.\w+\.\w+','match');
    unionfilename_2 = regexp(datainfo(2).name,'^\w+\.\w+\.\w+','match');
    if strcmp(unionfilename_1,unionfilename_2) 
        %% union files
        unionfilename=sprintf('%s.csv',unionfilename_1{:});
        cd(data_path);
        copyfile(datainfo(1).name,unionfilename,'f');
          % copy one
        fid_1 = fopen(datainfo(2).name,'r');
        format = repmat('%q',[1,38]);
        C = textscan(fid_1,format,'Delimiter', ',','HeaderLines',1 ,'Whitespace','\b');
        fclose(fid_1);
        c = [C{:}];
          % append the other one
        fid_2 = fopen(unionfilename,'a');
        inputformat=repmat('%s,',[1,37]);
        inputformat=[inputformat,'%s\n'];
        for i=1:size(c,1)
            fprintf(fid_2,inputformat,c{i,:});
        end
        fclose(fid_2);
        
        %% extract data from the union file
        fid_3 = fopen(unionfilename,'r');
        format = repmat('%q',[1,38]);
        C = textscan(fid_3,format,'Delimiter', ',','HeaderLines',1 ,'Whitespace','\b');
        fclose(fid_3);
        [G,ID] = findgroups(C{1});
        n=numel(ID);
        mydata={};
        mydata(:,1)=[{mydate},repmat({'.'},[1,n-1])]; % fix needed
        mydata(:,2)=[C{18}(1),repmat({'.'},[1,n-1])];
        mydata(:,3)=ID;
        for i=1:n
            mydata{i,4}=numel(unique(C{2}(G==i)));
            mydata{i,5}=sum(str2double(C{6}(G==i)));
            mydata{i,6}=sum(str2double(C{14}(G==i & strcmp(C{16},'S'))));
            mydata{i,7}=sum(str2double(C{14}(G==i & strcmp(C{16},'B'))));
        end
        mydata(:,8)=[{0},repmat({[]},[1,n-1])];
        mydata(:,9)=[{0},repmat({[]},[1,n-1])];
        mydata(:,10)=[{fullfile(data_path,unionfilename)},repmat({''},[1,n-1])];
        %% write summary into trade_recap table
        fid_4 = fopen(recap_file, 'a') ;
        while fid_4 < 0
            pause(30)
            fid_4 = fopen(recap_file, 'a') ;
        end
        for i =1:n
            fprintf(fid_4,'%s,%s,%s,%f,%f,%f,%f,%d,%d,%s\n',mydata{i,:});
        end
        fclose(fid_4);
    else
        %% file names did not match
        message={mydate,'file names did not match'};
        inputformat='%s,%s\n';
        fid_4 = fopen(recap_file, 'a') ;
        while fid_4 < 0
            pause(30)
            fid_4 = fopen(recap_file, 'a') ;
        end
        fprintf(fid_4,inputformat,message{:});
        fclose(fid_4);
    end
elseif m==1
    %% extract data from this file
    unionfilename=regexp(datainfo(1).name,'^\w+\.\w+\.\w+','match');
    fid_3 = fopen(unionfilename,'r');
    format = repmat('%q',[1,38]);
    C = textscan(fid_3,format,'Delimiter', ',','HeaderLines',1 ,'Whitespace','\b');
    fclose(fid_3);
    [G,ID] = findgroups(C{1});
    n=numel(ID);
    mydata={};
    mydata(:,1)=[{mydate},repmat({'.'},[1,n-1])]; % fix needed
    mydata(:,2)=[C{18}(1),repmat({'.'},[1,n-1])];
    mydata(:,3)=ID;
    for i=1:n
        mydata{i,4}=numel(unique(C{2}(G==i)));
        mydata{i,5}=sum(str2double(C{6}(G==i)));
        mydata{i,6}=sum(str2double(C{14}(G==i & strcmp(C{16},'S'))));
        mydata{i,7}=sum(str2double(C{14}(G==i & strcmp(C{16},'B'))));
    end
    mydata(:,8)=[{0},repmat({[]},[1,n-1])];
    mydata(:,9)=[{0},repmat({[]},[1,n-1])];
    mydata(:,10)=[{fullfile(data_path,unionfilename)},repmat({''},[1,n-1])];
    %% write summary into trade_recap table
    fid_4 = fopen(recap_file, 'a') ;
    while fid_4 < 0
        pause(30)
        fid_4 = fopen(recap_file, 'a') ;
    end
    for i =1:n
        fprintf(fid_4,'%s,%s,%s,%f,%f,%f,%f,%d,%d,%s\n',mydata{i,:});
    end
    fclose(fid_4);
else
    %% files number abnormal
    message={mydate,'files number abnormal'};
    inputformat='%s,%s\n';
    fid_4 = fopen(recap_file, 'a') ;
    while fid_4 < 0
        pause(30)
        fid_4 = fopen(recap_file, 'a') ;
    end
    fprintf(fid_4,inputformat,message{:});
    fclose(fid_4);
end
