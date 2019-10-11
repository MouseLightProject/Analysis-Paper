function [swc] = importSWCFast(cFile)
    fid = fopen(cFile);
    C = textscan(fid,'# %s','Delimiter','\n');
    offset = regexp(C{:},'(?<=OFFSET ).*','match');
    offset = [offset{:}];
    if ~isempty(offset)
        offset = textscan(offset{:},'%f %f %f');
        offset = [offset{:}];
        swc = textscan(fid,'%f %f %f %f %f %f %f');
        swc = [swc{:}];
        swc(:,3:5) = swc(:,3:5) + offset;
    else
        warning('Didnt find offset (non workstation file)');
        swc = textscan(fid,'%f %f %f %f %f %f %f');
        swc = [swc{:}];
    end
    fclose(fid);
end

