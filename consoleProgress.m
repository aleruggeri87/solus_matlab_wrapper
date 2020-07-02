function consoleProgress(x, text, X_START, XSCREEN)
% function consoleProgress(x, text, X_START, XSCREEN)
%
% Script di prova
% clc
% custom_text='Testo di prova';
% consoleProgress(0, custom_text);
% pause(.1);
% p=1;
% for x=0:0.001:1;
%     consoleProgress(x);
%     pause(p);
%     p=0.8*p;
% end
% consoleProgress(1);

% todo:
% lastwarn e lasterr

    persistent t_start;
    persistent i;
    persistent custom_text;
    persistent L LT
    persistent XSCREENi XSTARTi;
    
    fun_art=['\' '|' '/' '-'];
    
    % controllo il numero di argomenti
    if nargin>=2 && x==0
        % primo passo:
        % inizializzo contatore per fun e testo personalizzato
        i=1;
        LT=length(text);
        if LT>50
            warning('consoleProgress:TextTooLong',...
                'Text has been shorted to 50 characters!');
            custom_text=text(1:50);
            LT=50;
        else
            custom_text=text;
        end
        L=[];
        % controllo se ho anche i parametri addizionali, altrimenti metto
        % quelli di default
        if nargin < 4
            XSCREENi=80;
            if nargin < 3
                if LT<30
                     XSTARTi=32;
                else
                    XSTARTi=LT+3;
                end
            else
                XSTARTi=X_START;
            end
        else
            XSCREENi=XSCREEN;
        end
    else
        % non è il primo passo: aumento contatore x fun art
        if i>=4
            i=1;
        else
            i=i+1;
        end
        
    end
    
    % creo stringa da plottare
    x_rep=ceil(x*(XSCREENi-XSTARTi-11));
    if isunix % linux: da ricontrollare dopo ultime modifiche su win!
        if x==0 && nargin==2 % prima iterazione
            disp_str=[custom_text strcat(repmat('.',1,XSTARTi-LT-9)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREENi-XSTARTi-x_rep-1)) ']'];
            disp(disp_str)
            t_start=tic; % inizializzo timer
        elseif x>=1 % 100%: mostro tempo di esecuzione
            t_stop=toc(t_start);
            temp_time_str=['[ '  datestr(datenum(0,0,0,0,0,t_stop),'HH:MM:SS') ' ]'];
            disp_str=[custom_text strcat(repmat('.',1,XSCREENi-LT-length(temp_time_str))) temp_time_str];
            disp([repmat(char(8),1,XSCREENi), disp_str]);
        else
            if x_rep==XSCREENi-XSTARTi 
                disp_str=[custom_text strcat(repmat('.',1,XSTARTi-LT-8)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) strcat(repmat(32,1,XSCREENi-XSTARTi-x_rep)) ']'];
                disp([repmat(char(8),1,XSCREENi), disp_str]);
            elseif x_rep==1 || x_rep==0
                disp_str=[custom_text strcat(repmat('.',1,XSTARTi-LT-9)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREENi-XSTARTi-x_rep)) ']'];
                disp([repmat(char(8),1,XSCREENi), disp_str]);
            else
                disp_str=[custom_text strcat(repmat('.',1,XSTARTi-LT-8)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREENi-XSTARTi-x_rep)) ']'];
                disp([repmat(char(8),1,XSCREENi), disp_str]);
            end	
        end
    else % win
        if x>=1 % ultima iterazione: mostro tempo trascorso
            t_stop=toc(t_start);
            temp_time_str=['[ '  datestr(datenum(0,0,0,0,0,t_stop),'HH:MM:SS') ' ]'];
            disp_str=[custom_text strcat(repmat('.',1,XSCREENi-LT-length(temp_time_str))) temp_time_str];
            if ~isempty(L)
                fprintf('%s%s\n',repmat(char(8), 1,L), disp_str);
            end
            L=[];
        else    
            if nargin>=2 && x==0 % prima iterazione
                t_start=tic; % inizializzo timer
            end
            points=strcat(repmat('.',1,XSTARTi-LT));
            equals=strcat(repmat('=',1,x_rep));
            spaces=strcat(repmat(32,1,XSCREENi-XSTARTi-x_rep-11));
            str=sprintf('%s%s[ %4.1f%% |%s%s%s]\n', custom_text, points, ...
                x*100, equals, fun_art(i), spaces);
            if ~isempty(L)
                fprintf('%s%s',repmat(char(8), 1,L), str);
            else
                fprintf('%s',str);
            end
            L=length(str);
        end
    end
end

% 
%     persistent t_start;
%     persistent i;
%     persistent custom_text;
%     
%     XSCREEN=80;
%     X_START=30;
%     fun_art=['\' '|' '/' '-'];
% 
%     % inizializzo contatore per fun e testo personalizzato
%     if nargin==2 && x==0
%         i=1;
%         custom_text=text;
%     else
%         i=i+1;
%     end
%     fun=fun_art(rem(i,4)+1);
%     
%     % creo stringa da plottare
%     x_rep=ceil(x*(XSCREEN-X_START));
%     if isunix
%         if x==0 && nargin==2 % prima iterazione
%             disp_str=[custom_text strcat(repmat('.',1,X_START-LT-9)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREEN-X_START-x_rep-1)) ']'];
%             disp(disp_str)
%             t_start=tic; % inizializzo timer
%         elseif x>=1 % 100%: mostro tempo di esecuzione
%             t_stop=toc(t_start);
%             temp_time_str=['[ '  datestr(datenum(0,0,0,0,0,t_stop),'HH:MM:SS') ' ]'];
%             disp_str=[custom_text strcat(repmat('.',1,XSCREEN-LT-length(temp_time_str))) temp_time_str];
%             disp([repmat(char(8),1,XSCREEN), disp_str]);
%         else
%             if x_rep==XSCREEN-X_START 
%                 disp_str=[custom_text strcat(repmat('.',1,X_START-LT-8)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) strcat(repmat(32,1,XSCREEN-X_START-x_rep)) ']'];
%                 disp([repmat(char(8),1,XSCREEN), disp_str]);
%             elseif x_rep==1 || x_rep==0
%                 disp_str=[custom_text strcat(repmat('.',1,X_START-LT-9)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREEN-X_START-x_rep)) ']'];
%                 disp([repmat(char(8),1,XSCREEN), disp_str]);
%             else
%                 disp_str=[custom_text strcat(repmat('.',1,X_START-LT-8)) '[' sprintf('% 3.0f', x*100) '% |' strcat(repmat('=',1,x_rep-1)) fun strcat(repmat(32,1,XSCREEN-X_START-x_rep)) ']'];
%                 disp([repmat(char(8),1,XSCREEN), disp_str]);
%             end	
%         end
%     else
%         if x~=0
%             disp([repmat(char(8),1,XSCREEN), 6]);
%         end
%         disp(['[' sprintf('% 3.0f', x*100) '% ]']);
%     end