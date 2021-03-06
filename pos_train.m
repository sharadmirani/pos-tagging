clear; clc;

filename = 'pos.train.txt';

fid = fopen(filename);

tline = '';

lineCount = 1;

% Define hashmaps
myWordMap = containers.Map;
mySymMap = containers.Map;
myWordInvMap = {};
mySymInvMap = {};
wordCount = 1;
symCount = 1;

myWordMap('START') = wordCount;
mySymMap('START') = symCount;
myWordInvMap{wordCount} = 'START';
mySymInvMap{symCount} = 'START';

wordCount = wordCount + 1;
symCount = symCount + 1;

myWordMap('__UNK__') = wordCount;
myWordInvMap{wordCount} = '__UNK__';
wordCount = wordCount + 1;

% Training the HMM
while ischar(tline)
    
    disp([1 lineCount]);
    
    tline = fgetl(fid);
    
    while ~strcmp(tline, '') && ischar(tline)
        
        c = strsplit(tline);
        
        try
            myWordMap(lower(c{1}));
        catch
            myWordMap(lower(c{1})) = wordCount;
            myWordInvMap{wordCount} = lower(c{1});
            wordCount = wordCount + 1;
        end
        
        try
            mySymMap(lower(c{2}));
        catch
            mySymMap(lower(c{2})) = symCount;
            mySymInvMap{symCount} = lower(c{2});
            symCount = symCount + 1;
        end
        
        tline = fgetl(fid);

    end
    
    lineCount = lineCount + 1;
    
end

fclose(fid);

myTrans = zeros(symCount-1, symCount-1);
myEmis = zeros(symCount - 1, wordCount);

fid = fopen(filename);
tline = '';

lineCount = 1;

while ischar(tline)
    
    disp([2 lineCount]);
    
    tline = fgetl(fid);
    oldSym = 'START';
    
    while ~strcmp(tline, '') && ischar(tline)
        
        c = strsplit(tline);
        
        myTrans(mySymMap(oldSym), mySymMap(lower(c{2}))) = myTrans(mySymMap(oldSym), mySymMap(lower(c{2}))) + 1; %#ok<*SAGROW>
        myEmis(mySymMap(lower(c{2})), myWordMap(lower(c{1}))) = myEmis(mySymMap(lower(c{2})), myWordMap(lower(c{1}))) + 1;
        
        oldSym = lower(c{2});
        
        tline = fgetl(fid);

    end
    
    myTrans(mySymMap(oldSym), mySymMap('START')) = myTrans(mySymMap(oldSym), mySymMap('START')) + 1;
    
    lineCount = lineCount + 1;
    
end

myEmis(1, 1) = lineCount - 1;

myTrans = myTrans + 0.01;
myTrans = myTrans ./ repmat(sum(myTrans, 2), 1, size(myTrans, 2));

myEmis = myEmis ./ repmat(sum(myEmis, 2), 1, size(myEmis, 2));
myEmis(:, myWordMap('__UNK__')) = 0.0001*[0; ones(symCount - 2, 1)];
myEmis = myEmis ./ repmat(sum(myEmis, 2), 1, size(myEmis, 2));

fclose(fid);
