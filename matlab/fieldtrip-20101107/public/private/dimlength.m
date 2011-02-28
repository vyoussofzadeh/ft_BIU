function [n, fn] = dimlength(data, seldim, fld)

% DIMLENGTH(DATA, SELDIM, FLD) is a helper function to obtain n, the number of elements
% along dimension seldim from the appropriate field from the input data containing 
% functional data. The output n It can be called with one input argument only. In that case 
% it will output two cell arrays containing the size of the functional fields, based on the 
% XXXdimord, and the corresponding XXXdimord fields.
% When the data contains a single dimord field (everything except source data), the cell-arrays
% in the output only contain one element.
 
if nargin<3
  fld = 'dimord';
end

% get all fields of the data structure
fn    = fieldnames(data);

% get all dimord like fields
selfn = find(~cellfun('isempty', strfind(fn, 'dimord')));
fn    = fn(selfn);
for k = 1:numel(fn)
  fndimord{k} = data.(fn{k});
end

% call recursively to get the dimensionality of all fields XXX
% which are accompanied by a XXXdimord field
% or of the dimord (if not source data)
if nargin==1
  for k = 1:numel(fndimord)
    dimtok = tokenize(fndimord{k}, '_');
    ndim   = numel(dimtok);
    n{k,1} = zeros(1, ndim);
    for i = 1:ndim
      n{k}(i) = dimlength(data, dimtok{i}, fn{k});
    end
  end
  return
end

switch seldim
  case 'rpt'
    if numel(fld)>6 && isfield(data, fld(1:end-6)),
      % source level data
      dimtok = tokenize(data.(fld), '_'); 
      tmp    = data.(fld(1:end-6));
      if iscell(tmp)
        if isfield(data, 'inside'),
          ix = data.inside(1);
        else
          ix = 1;
        end
        tmp    = tmp{ix};
        dimtok = dimtok(2:end);
      end
      ix = find(~cellfun('isempty', strfind(dimtok, seldim)));
      n  = size(tmp, ix);

   elseif strcmp(data.(fld), 'rpt_pos')
      %HACK to be fixed
      x = setdiff(fld(data),'inside');
      for k = 1:length(x)
        dims = size(getsubfield(data,x{k}));
	if dims(2)==size(data.pos,1) && numel(dims)==2,
	  n = dims(1);
	  return
	end
      end

    elseif strcmp(data.(fld), 'rpt_pos_freq'),
      %HACK to be fixed
      x = fld(data);
      for k = 1:length(x)
        dims = size(getsubfield(data,x{k}));
        if dims(2)==size(data.pos,1) && (numel(dims)==2 || dims(3)==length(data.freq)),
          n = dims(1);
	  return
	end
      end
      
    elseif strcmp(data.(fld), 'rpt_pos_time'),
      %HACK to be fixed
      x = fld(data);
      for k = 1:length(x)
        dims = size(getsubfield(data,x{k}));
        if dims(2)==size(data.pos,1) && (numel(dims)==2 || dims(3)==length(data.time)),
          n = dims(1);
	  return
	end
      end
      
    elseif strcmp(data.(fld)(1:4), 'rpt_')
      n  = [];
      if isfield(data, 'cov'),           n = [n size(data.cov,           1)]; end
      if isfield(data, 'crsspctrm'),     n = [n size(data.crsspctrm,     1)]; end
      if isfield(data, 'powcovspctrm'),  n = [n size(data.powcovspctrm,  1)]; end 
      if isfield(data, 'powspctrm'),     n = [n size(data.powspctrm,     1)]; end
      if isfield(data, 'trial'),         n = [n size(data.trial,         1)]; end
      if isfield(data, 'fourierspctrm'), n = [n size(data.fourierspctrm, 1)]; end
      
      if ~all(n==n(1)), error('inconsistent number of repetitions for dim "%s"', seldim); end
      n = n(1);
    else
      %error('cannot determine number of repetitions for dim "%s"', seldim);
      n = nan;
    end

  case 'rpttap'
    if numel(fld)>6 && isfield(data, fld(1:end-6)),
      dimtok = tokenize(data.(fld), '_'); 
      tmp    = data.(fld(1:end-6));
      if iscell(tmp)
        if isfield(data, 'inside'),
          ix = data.inside(1);
        else
          ix = 1;
        end
        tmp    = tmp{ix};
        dimtok = dimtok(2:end);
      end
      ix = find(~cellfun('isempty', strfind(dimtok, seldim)));
      n  = size(tmp, ix);
    
    elseif strcmp(data.(fld)(1:7), 'rpttap_')
      n  = [];
      if isfield(data, 'cov'),           n = [n size(data.cov,           1)]; end
      if isfield(data, 'crsspctrm'),     n = [n size(data.crsspctrm,     1)]; end
      if isfield(data, 'powcovspctrm'),  n = [n size(data.powcovspctrm,  1)]; end 
      if isfield(data, 'powspctrm'),     n = [n size(data.powspctrm,     1)]; end
      if isfield(data, 'trial'),         n = [n size(data.trial,         1)]; end
      if isfield(data, 'fourierspctrm'), n = [n size(data.fourierspctrm, 1)]; end
      
      if ~all(n==n(1)), error('inconsistent number of repetitions for dim "%s"', seldim); end
      n = n(1);
    else
      %error('cannot determine number of repetitions for dim "%s"', seldim);
      n = nan;
    end

  case 'chan'
    if ~isfield(data, 'inside'), 
      try, 
        n = length(data.label);
      catch
        n = size(data.labelcmb, 1);
      end
    else
      n = nan; %FIXME discuss appending label to source-like data
    end
  case 'freq'
    n = length(data.freq);
  case 'time'
    n = length(data.time);
  case {'pos' '{pos}'}
    n = size(data.pos,1);
  case {'ori'}
    if isfield(data, 'ori'), 
      n = size(data.ori,1);
    else
      n = 1;
    end
  otherwise
    error('unsupported dim "%s"', seldim);
end