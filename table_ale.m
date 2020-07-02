function table_ale(data, label, title, precision, col1)
    %% Syntax
    % table_ale(data, label)
    % table_ale(data, label, title)
    % table_ale(data, label, title, precision)
	% table_ale(data, label, title, precision, col1)
    %
    %% Input Arguments
    % data      : numeric data to be displayed in table
    % label     : cell that contains column headers
    % title     : optional table title
    % precision : optional display number precision
	% col1      : optional first column
    %
    %% Example
    % clc
    % title='Il mio bellissimo titolo';
    % label={'1aa1', 'Seconda Colonna', 'Questa è la terza colonna!'};
    % data=rand(7,3)*50;
    % table_ale(data,label,title,3)
    %% Example2
    % clc
    % title='Il mio bellissimo titolo';
    % label={'qq', '1aa1', 'Seconda Colonna', 'Questa è la terza colonna!'};
	% col1={'a','b','c','d','e','f','g'}'
    % data=rand(7,3)*50;
    % table_ale(data,label,title,3,col1)
    %% Check dati in ingresso
	M=size(data,1);
	N=size(data,2);
	
	if nargin==5 % colonna 1?
		if size(col1,1)~=M
			error 'Length of first column does not match input data'
		end
		if N~=length(label)-1
			error 'Please check data and label dimensions'
		end
		col1_on=true;
	else
		col1=[];
		if N~=length(label)
			error 'Please check data and label dimensions'
		end
		col1_on=false;
	end
	

	
	if nargin<3 || isempty(title) % devo visualizzare il titolo?
        print_title=false;
	else
        print_title=true;
	end
    
	if nargin~=4 % l'utente mi sta passando la precisione?
        precision=4;
	end
       
    if max(max(abs(data)))>=10^precision
        min_width=precision+5;
    else
        min_width=precision;
    end
    
    if rem(min_width,2) % min_width è pari o dispari?
        small_odd=min_width+2;
        small_even=min_width+1;
    else
        small_odd=min_width+1;
        small_even=min_width+2;
    end

    %% creo le stringhe da stampare
    spacer='+';
    header='|';
    frmtstr='|%s';
	if col1_on % stampo prima colonna
		L=zeros(length(col1)+2,1);
		for k=1:M
			L(k)=length(col1{k});
		end
		L(end-1)=min_width+1;
		L(end)=length(label{1})+2;
		L=max(L);
		for k=1:M
			col1{k}=[' ' col1{k} repmat(' ', 1, 1+L-length(col1{k}))];
		end
		frmtstr=[frmtstr '|'];
		N=N+1;
	else
		col1=cell(M,1);
	end	
    for k=1:N
        % creo la riga che uso come separatore
        L=length(label{k});
        if L <= min_width % gestisco label corte
            if rem(L,2) % label corta e dispari
                corrL=small_odd;
            else % label corta e pari
                corrL=small_even;
            end
            filler = repmat(' ', 1, (corrL-L)/2+1);
            L=corrL;
        else
            filler = ' ';
        end
        spacer=[spacer ' ' repmat('-', 1, L) ' +'];
        % creo la riga di intestazione
        header=[header filler label{k} filler '|'];
        % creo la stringa di formattazione dati
		if ~(col1_on && k==1) 
			frmtstr=[frmtstr ' %+' num2str(L) '.' num2str(precision) 'g |'];
		end
	end
	
    if print_title
        LX=(length(header)-length(title)-4)/2;
        title=['| ' repmat(' ',1,floor(LX)) title ...
            repmat(' ',1,ceil(LX)+1) '|'];
        top=['+ ' repmat('-', 1, length(title)-4) ' +'];
    else
        title=[];
        top=[];
    end

    %% visualizzo la tabella a schermo
    disp([top;title;spacer; header; spacer])
    for k=1:size(data,1)
        row=sprintf(frmtstr, col1{k}, data(k,:));
        if ispc
            %row = strrep(row, 'e+0', 'e+');
        end
        %row = strrep(row, '. ', '  ');
        disp(row);
    end
    disp(spacer)

end
%% by AleR87 --- last mod. 02/03/13.
%% 20171113: added first column support