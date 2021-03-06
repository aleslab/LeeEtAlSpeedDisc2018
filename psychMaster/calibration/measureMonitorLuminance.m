function [luminanceCalibInfo] = measureMonitorLuminance(inverseGamma)
% Shows how to make measurements using the ColorCAL II CDC interface.
% This script calls several other separate functions which are included
% below.
%
% CIExyY returns the XYZ values for each measurement (each row
% represents a different measurement).

% 31/1/2016 - Written by JMA. Modified from CRS provided example


% Sets how many samples to take.
samples = 1;



% % First, the ColorCAL II should have its zero level calibrated. This can
% % simply be done by placing one's hand over the ColorCAL II sensor to block
% % all light.
% disp('Please cover the ColorCAL II so that no light can enter it, then press any key');
% % Wait for a keypress to indicate the ColorCAL II sensor is covered.
% pause;
% % This is a separate function (see further below in this script) that will
% % calibrate the ColorCAL II's zero level (i.e. the value for no light).
% %ColorCALIIZeroCalibrate(ColorCALIICDCPort);
% %ColorCal2Serial('ZeroCalibration');
% % Confirm the calibration is complete. Position the ColorCAL II to take a
% % measurement from the screen.
% disp('OK, you can now uncover ColorCAL II. Please position ColorCAL II where desired, then press any key to continue');
% % Wait for a keypress to confirm ColorCAL II is in position before
% % continuing.
% pause;

% Obtains the XYZ colour correction matrix specific to the ColorCAL II
% being used, via the CDC port. This is a separate function (see further
% below in this script).
cMatrix = ColorCal2Serial('ReadColorMatrix');

myCorrectionMatrix = cMatrix(1:3,:);

%cMatrix = ColorCal2('ReadColorMatrix');
%      s = ColorCal2('MeasureXYZ');
%      correctedValues = cMatrix(1:3,:) * [s.x s.y s.z]';

try
%Open a window

expInfo = openExperiment();
%[oldClut, dacBits, lutSize] = Screen('ReadNormalizedGammaTable', expInfo.screenNum);
BackupCluts;
%If given a gamma table use it.
if nargin>0
    fullTable = repmat(inverseGamma,1,3);
    [oldClut sucess]=Screen('LoadNormalizedGammaTable',expInfo.curWindow,fullTable);
else
    oldClut = LoadIdentityClut(expInfo.curWindow);
end

Screen('TextSize',expInfo.curWindow, 14);

Screen('Flip', expInfo.curWindow);

nValues = 64;
displayValues = linspace(0,1,nValues)'*[1 1 1]; %linear algebra here to replicate the matrix
averageMeasurement = zeros(nValues,3);

for iValue = 1:nValues
    % Cycle through each sample.
    
    Screen('FillRect',expInfo.curWindow,displayValues(iValue,:));
    DrawFormattedText(expInfo.curWindow, num2str(iValue),0,0,[255, 0, 0, 255]);

    Screen('Flip',expInfo.curWindow);
    % Pause for approximately .25 second to allow sufficient time for the
    % test patch to be displayed. We do not want our measurement to be
    % taken during the screen transition time from its old value to its new
    % value.
    
    
    WaitSecs(0.25);
    CIExyY= nan(samples,3);
    
    for iSamp = 1:samples
               
        % Ask the ColorCAL II to take a measurement. It will return 3 values.
        % This is a separate function (see further below in this script).
        s = ColorCal2Serial('MeasureXYZ');
        correctedValues = myCorrectionMatrix * [s.x s.y s.z]';
        % The returned values need to be multiplied by the ColorCAL II's
        % individual calibration matrix, as retrieved earlier. This will
        % convert the three values into CIE XYZ.
        
        CIExyY(iSamp, 1:3)  = XYZToxyY(correctedValues)';
        
    end
    
    allCIExyY(iValue,:,:) = CIExyY;
    averageMeasurement(iValue,:) = mean(CIExyY,1);
end


    %save info that goes with this calibration
    luminanceCalibInfo.description = 'Contains monitor luminance calibration information';
    luminanceCalibInfo.date = now;    
    luminanceCalibInfo.computer = Screen('Computer');
    %Ok, so HI-DPI displays like retina macs make life oh so fun.  The
    %physical pixels on the display are not equal to the graphical pixels
    %used for rendering.  Need to keep track of this. 
    luminanceCalibInfo.modeInfo = Screen('Resolution', expInfo.screenNum); %This gets the screen mode
    [width, height]=Screen('WindowSize', expInfo.screenNum); %This gets the actual pixels the mode is using
    luminanceCalibInfo.monitorPixelWidth= width;
    luminanceCalibInfo.expInfo = expInfo;
    luminanceCalibInfo.allCIExyY = allCIExyY;
    luminanceCalibInfo.meanCIExyY = averageMeasurement; 
    luminanceCalibInfo.oldClut = oldClut;
    luminanceCalibInfo.clutSize = size(oldClut,1);
    
% %     %type = 1 is Fit a simple power function
% %     [gammaFit,gammaInputFit,fitComment,gammaParams]=FitDeviceGamma(CIExyY,displayValues(:,1),1,luminanceCalibInfo.clutSize);
% %     
% %     inverseGamma = InvertGammaTable(linspace(0,1,luminanceCalibInfo.clutSize)',gammaFit,luminanceCalibInfo.clutSize);
% %     
% %     luminanceCalibInfo.gammaFit     = gammaFit;
% %     luminanceCalibInfo.gammaInputFit= gammaInputFit;
% %     luminanceCalibInfo.fitComment   = fitComment;
% %     luminanceCalibInfo.gammaParams  = gammaParams;
% %     luminanceCalibInfo.inverseGamma = inverseGamma;
% %     
%     modeString = ['_' num2str(luminanceCalibInfo.modeInfo.width) 'x' num2str(luminanceCalibInfo.modeInfo.height) ...
%         '_' num2str(luminanceCalibInfo.modeInfo.hz) 'Hz_' num2str(luminanceCalibInfo.modeInfo.pixelSize) 'bpp_'];
%     
%     filename = ['pm_luminance_' modeString datestr(now,'yyyymmdd_HHMMSS') '.mat'];
%     
%     if ispref('psychMaster','calibdir');
%         calibdir = getpref('psychMaster','calibdir');
%     elseif ispref('psychMaster','base');
%         calibdir = fullfile(getpref('psychMaster','base'),'calibrationData');
%     else
%         calibdir = '';
%     end
%     
%     
%     saveFilename = fullfile(calibdir,filename);
%     
%     if ~exist(calibdir,'dir')
%         mkdir(calibdir)
%     end
%     
%     save(saveFilename,'luminanceCalibInfo','-struct')
%     
    
closeExperiment;

% Convert recorded XYZ values into CIE xyY values using PsychToolbox
% supplied function XYZToxyY (included at the bottom of the script).



catch
    disp('caught')
    errorMsg = lasterror;
    closeExperiment;
    psychrethrow(psychlasterror);
end
    
