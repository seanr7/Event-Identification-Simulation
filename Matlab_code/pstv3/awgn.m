function y=awgn(varargin)  
% db=10*log10(sum(b1.^2)/sum((by-b1).^2))
%  AWGN??????????????
% y = awgn(x,SNR) ???x????????????SNR?dB????x??????0dBW???x???????????
% y = awgn(x,SNR,SIGPOWER) ??SIGPOWER?????????dBW???????????SIGPOWER?'measured'???????????????????
% y = awgn(x,SNR,SIGPOWER,STATE) ??RANDN????
% y = awgn(�,POWERTYPE) ??SNR?SIGPOWER????POWERTYPE???'dB'?'linear'???POWERTYPE?'dB'???SNR?dB?? ???SIGPOWER?dBW??????POWERTYPE?'linear'???SNR?????????SIGPOWER??????

%AWGN Add white Gaussian noise to a signal.  
%   Y = AWGN(X,SNR) adds white Gaussian noise to X.  The SNR is in dB.  
%   The power of X is assumed to be 0 dBW.  If X is complex, then   
%   AWGN adds complex noise.  
%  
%   Y = AWGN(X,SNR,SIGPOWER) when SIGPOWER is numeric, it represents   
%   the signal power in dBW. When SIGPOWER is 'measured', AWGN measures  
%   the signal power before adding noise.  
%  
%   Y = AWGN(X,SNR,SIGPOWER,STATE) resets the state of RANDN to STATE.  
%  
%   Y = AWGN(..., POWERTYPE) specifies the units of SNR and SIGPOWER.  
%   POWERTYPE can be 'db' or 'linear'.  If POWERTYPE is 'db', then SNR  
%   is measured in dB and SIGPOWER is measured in dBW.  If POWERTYPE is  
%   'linear', then SNR is measured as a ratio and SIGPOWER is measured  
%   in Watts.  
%  
%   Example 1:   
%        % To specify the power of X to be 0 dBW and add noise to produce  
%        % an SNR of 10dB, use:  
%        X = sqrt(2)*sin(0:pi/8:6*pi);  
%        Y = awgn(X,10,0);  
%  
%   Example 2:   
%        % To specify the power of X to be 3 Watts and add noise to  
%        % produce a linear SNR of 4, use:  
%        X = sqrt(2)*sin(0:pi/8:6*pi);  
%        Y = awgn(X,4,3,'linear');  
%  
%   Example 3:   
%        % To cause AWGN to measure the power of X and add noise to  
%        % produce a linear SNR of 4, use:  
%        X = sqrt(2)*sin(0:pi/8:6*pi);  
%        Y = awgn(X,4,'measured','linear');  
%  
%   See also WGN, RANDN, and BSC.  
  
%   Copyright 1996-2008 The MathWorks, Inc.  
%   $Revision: 1.9.4.6 $  $Date: 2008/08/22 20:23:43 $   
  
% --- Initial checks  
error(nargchk(2,5,nargin,'struct'));  
  
% --- Value set indicators (used for the string flags)  
pModeSet    = 0;  
measModeSet = 0;  
  
% --- Set default values  
sigPower = 0;  
pMode    = 'db';  
measMode = 'specify';  
state    = [];  
  
% --- Placeholder for the signature string  
sigStr = '';  
  
% --- Identify string and numeric arguments  
for n=1:nargin  
   if(n>1)  
      sigStr(size(sigStr,2)+1) = '/';  
   end  
   % --- Assign the string and numeric flags  
   if(ischar(varargin{n}))  
      sigStr(size(sigStr,2)+1) = 's';  
   elseif(isnumeric(varargin{n}))  
      sigStr(size(sigStr,2)+1) = 'n';  
   else  
      error('comm:awgn:InvalidArg','Only string and numeric arguments are allowed.');  
   end  
end  
  
% --- Identify parameter signatures and assign values to variables  
switch sigStr  
   % --- awgn(x, snr)  
   case 'n/n'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
  
   % --- awgn(x, snr, sigPower)  
   case 'n/n/n'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      sigPower = varargin{3};  
  
   % --- awgn(x, snr, 'measured')  
   case 'n/n/s'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      measMode = lower(varargin{3});  
  
      measModeSet = 1;  
  
   % --- awgn(x, snr, sigPower, state)  
   case 'n/n/n/n'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      sigPower = varargin{3};  
      state    = varargin{4};  
  
   % --- awgn(x, snr, 'measured', state)  
   case 'n/n/s/n'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      measMode = lower(varargin{3});  
      state    = varargin{4};  
  
      measModeSet = 1;  
  
   % --- awgn(x, snr, sigPower, 'db|linear')  
   case 'n/n/n/s'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      sigPower = varargin{3};  
      pMode    = lower(varargin{4});  
  
      pModeSet = 1;  
  
   % --- awgn(x, snr, 'measured', 'db|linear')  
   case 'n/n/s/s'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      measMode = lower(varargin{3});  
      pMode    = lower(varargin{4});  
  
      measModeSet = 1;  
      pModeSet    = 1;  
  
   % --- awgn(x, snr, sigPower, state, 'db|linear')  
   case 'n/n/n/n/s'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      sigPower = varargin{3};  
      state    = varargin{4};  
      pMode    = lower(varargin{5});  
  
      pModeSet = 1;  
  
   % --- awgn(x, snr, 'measured', state, 'db|linear')  
   case 'n/n/s/n/s'  
      sig      = varargin{1};  
      reqSNR   = varargin{2};  
      measMode = lower(varargin{3});  
      state    = varargin{4};  
      pMode    = lower(varargin{5});  
  
      measModeSet = 1;  
      pModeSet    = 1;  
  
   otherwise  
      error('comm:awgn:InvalidSyntax','Syntax error.');  
end     
  
% --- Parameters have all been set, either to their defaults or by the values passed in,  
%     so perform range and type checks  
  
% --- sig  
if(isempty(sig))  
   error('comm:awgn:NoInput','An input signal must be given.');  
end  
  
if(ndims(sig)>2)  
   error('comm:awgn:InvalidSignalDims','The input signal must have 2 or fewer dimensions.');  
end  
  
% --- measMode  
if(measModeSet)  
   if(~strcmp(measMode,'measured'))  
      error('comm:awgn:InvalidSigPower','The signal power parameter must be numeric or ''measured''.');  
   end  
end  
  
% --- pMode  
if(pModeSet)  
   switch pMode  
   case {'db' 'linear'}  
   otherwise  
      error('comm:awgn:InvalidPowerType','The signal power mode must be ''db'' or ''linear''.');  
   end  
end  
  
% -- reqSNR  
if(any([~isreal(reqSNR) (length(reqSNR)>1) (isempty(reqSNR))]))  
   error('comm:awgn:InvalidSNR','The signal-to-noise ratio must be a real scalar.');  
end  
  
if(strcmp(pMode,'linear'))  
   if(reqSNR<=0)  
      error('comm:awgn:InvalidSNRForLinearMode','In linear mode, the signal-to-noise ratio must be > 0.');  
   end  
end  
  
% --- sigPower  
if(~strcmp(measMode,'measured'))  
  
   % --- If measMode is not 'measured', then the signal power must be specified  
   if(any([~isreal(sigPower) (length(sigPower)>1) (isempty(sigPower))]))  
      error('comm:awgn:InvalidSigPower','The signal power value must be a real scalar.');  
   end  
     
   if(strcmp(pMode,'linear'))  
      if(sigPower<0)  
         error('comm:awgn:InvalidSigPowerForLinearMode','In linear mode, the signal power must be >= 0.');  
      end  
   end  
  
end  
  
% --- state  
if(~isempty(state))  
   if(any([~isreal(state) (length(state)>1) (isempty(state)) any((state-floor(state))~=0)]))  
      error('comm:awgn:InvaildState','The State must be a real, integer scalar.');  
   end  
end  
  
% --- All parameters are valid, so no extra checking is required  
  
% --- Check the signal power.  This needs to consider power measurements on matrices  
if(strcmp(measMode,'measured'))  
   sigPower = sum(abs(sig(:)).^2)/length(sig(:));  
  
   if(strcmp(pMode,'db'))  
      sigPower = 10*log10(sigPower);  
   end  
end  
  
% --- Compute the required noise power  
switch lower(pMode)  
   case 'linear'  
      noisePower = sigPower/reqSNR;  
   case 'db'  
      noisePower = sigPower-reqSNR;  
      pMode = 'dbw';  
end  
  
% --- Add the noise  
if(isreal(sig))  
   opType = 'real';  
else  
   opType = 'complex';  
end  
  
y = sig+wgn(size(sig,1), size(sig,2), noisePower, 1, state, pMode, opType);  
