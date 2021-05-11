classdef SlackAPI < handle
    properties
        ID = ''; 
    end
    methods(Static, Access = private)
        function res = GET_request(www)
            res = webread(www);            
        end
        %%
        function status = Upload(www, FilePath)
            import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
            handler = sun.net.www.protocol.https.Handler;
            url = java.net.URL([],www,handler);
            urlConnection = url.openConnection;            
            urlConnection.setDoOutput(true);
            urlConnection.setRequestProperty('Content-Type','multipart/form-data; boundary=***********************');
            printStream = java.io.PrintStream(urlConnection.getOutputStream);
            dataOutputStream = java.io.DataOutputStream(urlConnection.getOutputStream);
            [~,name,ext] = fileparts(FilePath);
            f = fopen(FilePath); 
            d = fread(f,Inf,'*uint8'); 
            fclose(f);             
            printStream.println('--***********************');
            printStream.print('Content-Disposition: form-data; name="file"');
            if ~ischar(d)
            printStream.println(['; filename="',name,ext,'"']);
            printStream.println('Content-Type: application/octet-stream');
            printStream.println();
            dataOutputStream.write(d,0,length(d));
            printStream.println();
            else
            printStream.println();
            printStream.println();
            printStream.println(d);
            end
            printStream.println('--***********************--');
            printStream.close;            
            inputStream = urlConnection.getInputStream;
            byteArrayOutputStream = java.io.ByteArrayOutputStream;
            isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
            isc.copyStream(inputStream,byteArrayOutputStream);
            inputStream.close;
            byteArrayOutputStream.close;
            resp = jsondecode(native2unicode(typecast(byteArrayOutputStream.toByteArray','uint8'),'UTF-8'));
            status = resp.ok;
        end   
    end
    methods(Access = private)        
        function res = JSON_request(obj,www, json)
            options = weboptions('HeaderFields',{'Content-type' 'application/json'; ... 
                'Authorization' ['Bearer ', obj.ID]}, ...
                'RequestMethod','post');
            res = webwrite(www, json, options);
        end
        %%
        function channel = Str2Ch(obj,str)
            if str(1) == '@',channel = obj.name2id(str(2:end));
            elseif str(1) == '#',channel = obj.channel2id(str(2:end));
            else,channel = str;
            end
        end
        %%
        function status = SendMsgJSON(obj, channel, msg , as_usr)            
            www = 'https://slack.com/api/chat.postMessage';
            json.channel = channel;
            json.text = msg;
            json.as_user = as_usr;           
            resp = obj.JSON_request(www, json);
            status = resp.ok;
        end
        %%
        function status = UploadFile(obj, channel, FilePath)
            www = "https://slack.com/api/files.upload?token=" + obj.ID + ...
                "&channels=" + channel + "&pretty=1";
            status = obj.Upload(www,FilePath);
        end
    end
    methods(Access = public)
        function obj = SlackAPI(id)            
            obj.ID = id;
        end        
        function SetID(obj, id)
            obj.ID = id;
        end
        %%
        function status = SendMsg(obj, channel, msg, as_usr)
        %SENDMSG Send message to Slack channel or user
        %   SendMsg('@username','Hello World!') to USER
        %
        %   SendMsg('#general','Hi Glaxy') to CHANNEL
        %
        %   SendMsg('CHS7MKMC3','Hi') to ID
            if nargin < 4
                as_usr = true;
            end
            status = SendMsgJSON(obj,obj.Str2Ch(channel), msg, as_usr);
        end
        %%
        function status = SendFile(obj, channel, FilePath)
        %SENDMSG Send file to Slack channel or user
        %   SendMsg('@username','Hello World!') to USER
        %
        %   SendMsg('#general','Hi Glaxy') to CHANNEL
        %
        %   SendMsg('CHS7MKMC3','Hi') to ID
            if exist(FilePath, 'file') == 2
                status = obj.UploadFile(obj.Str2Ch(channel), FilePath);
            else
                error('File does not exist.')
            end            
        end
        %%
        function [status, list] = GetUserList(obj)
            www = 'https://slack.com/api/users.list';
            resp = obj.JSON_request(www, nan);
            status = resp.ok;
            list = resp.members;
        end
        %%
        function [status, list] = GetChannelsList(obj)
            www = 'https://slack.com/api/channels.list';
            resp = obj.JSON_request(www, nan);
            status = resp.ok;
            list = resp.channels;
        end
        %%
        function id = name2id(obj, name)
            www = 'https://slack.com/api/users.list';
            resp = obj.JSON_request(www, nan);
            status = resp.ok;
            list = resp.members;
            for i = 1:length(list)
                if strcmp(list{i,1}.name, name)
                    id = list{i,1}.id;
                    return;
                end
            end
            id = nan;
        end
        %%
        function id = channel2id(obj, channel)
            www = 'https://slack.com/api/channels.list';
            resp = obj.JSON_request(www, nan);
            status = resp.ok;
            list = resp.channels;
            for i = 1:length(list)
                if strcmp(list(i).name, channel)
                    id = list(i).id;
                    return;
                end
            end
            id = nan;
            www = 'https://slack.com/api/groups.list';
            resp = obj.JSON_request(www, nan);
            status = resp.ok;
            list = resp.groups;
            for i = 1:length(list)
                if strcmp(list(i).name, channel)
                    id = list(i).id;
                    return;
                end
            end
            id = nan;
        end        
    end
end