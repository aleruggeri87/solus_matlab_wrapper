classdef objArr
    methods
        function disp(objAry)
            objType=class(objAry);
            dim=sprintf('  %dx%d ', size(objAry,1), size(objAry,2));
            disp([dim '<a href="matlab:help ' objType '">' objType '</a>'])
            fprintf('\n  Properties:\n');
            p=properties(objType);
            M=1;
            for k=1:length(p) % find maximum number length
                m=max(floor(log10(double(cat(1,objAry.(p{k})))))+1);
                if m>M
                    M=m;
                end
            end
            frmtStr=sprintf('%%%dd, ',M);
            maxL=max(cellfun('length',p))+1;
            for k=1:length(p) % print real strings
                fprintf('   %s%s: ', repmat(' ',maxL-length(p{k}),1), p{k});
                fprintf(frmtStr, objAry.(p{k}));
                fprintf('\b\b\n');
            end
            if numel(objAry)>8 % print guide numbers
                idx=5:5:numel(objAry);
                fprintf('    %s  %s           ', repmat(' ',maxL,1), '1');
                for k=1:length(idx)
                    fprintf('%d%s', idx(k), repmat(' ', 3*4-floor(log10(idx(k)))+2,1));
                end
                fprintf('\n\n')
            else
                fprintf('\n')
            end
        end
    end
end
