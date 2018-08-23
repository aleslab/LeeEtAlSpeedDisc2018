clearvars;
cd /Users/Abigail/Documents/psychtoolboxProjects/psychMaster/Data %lab mac

participantCodes = {'AA' 'AB' 'AD' 'AG' 'AH'}; %'AE'  'AI' 'AL' = experiment 3
% 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'J' 'K' = experiment 1;
%'M' 'O' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'AL' = experiment 2
ParOrNonPar = 2; %non-parametric bootstrap for all
BootNo = 1000; %number of simulations for all bootstraps and goodness of fits

for iParticipant = 1:length(participantCodes)
    
    currParticipantCode = cell2mat(participantCodes(iParticipant));
    %experiment 1 conditions
    %     conditionList = {'MoveLine_accelerating_depth_midspeed'; ...
    %         'MoveLine_accelerating_depth_slow'; 'MoveLine_accelerating_lateral_midspeed'; ...
    %         'MoveLine_accelerating_lateral_slow'; 'MoveLine_CRS_depth_midspeed'; ...
    %         'MoveLine_CRS_depth_slow'; 'MoveLine_CRS_lateral_midspeed'; 'MoveLine_CRS_lateral_slow'};
    
    %experiment 2 conditions
    %     conditionList = {'MoveLine_accelerating_depth_midspeed'; ...
    %         'MoveLine_accelerating_depth_slow'; 'MoveLine_accelerating_looming_midspeed'; ...
    %         'MoveLine_accelerating_looming_slow'; 'MoveLine_accelerating_cd_midspeed'; ...
    %         'MoveLine_accelerating_cd_slow'};
    
    %experiment 3 conditions
    conditionList = {'SpeedDisc_fixed_duration'; 'SpeedDisc_fixed_distance'};
    
    analysisType = {'speed_only'; 'speed_only_arcmin'; 'real_world_difference'; 'real_world_proportion_difference'}; %'real_world_change' 'speed_change_full', ...
    %'speed_change_changepoint_arcmin', ... 'speed_change_full_arcmin' 'speed_change_changepoint'
    
    for iAnalysis = 1:length(analysisType)
        currAnalysisType = cell2mat(analysisType(iAnalysis));
        for iCond = 1:length(conditionList)
            currCondition = cell2mat(conditionList(iCond));
            condAndParticipant = strcat(currCondition, '_', currParticipantCode);
            
            %experiment 1
            %fileDir = strcat('/Users/Abigail/Documents/Experiment Data/Experiment 1/Participant_', currParticipantCode, '/', condAndParticipant, '_*');
            
            %experiment 2
            %fileDir = strcat('/Users/Abigail/Documents/Experiment Data/Experiment 2/Participant_', currParticipantCode, '/', condAndParticipant, '_*');
            
            %experiment 3
            fileDir = strcat('/Users/Abigail/Documents/Experiment Data/Experiment 3/Participant_', currParticipantCode, '/', condAndParticipant, '_*');
            
            filenames = dir(fileDir);
            filenames = {filenames.name}; %makes a cell of filenames from the same
            %participant and condition to be loaded together
            
            for iFiles = 1:length(filenames)
                filenamestr = char(filenames(iFiles));
                dataFile(iFiles) = load(filenamestr); %loads all of the files to be analysed together
            end
            
            allExperimentData = [dataFile.experimentData]; %all of the experiment data in one combined struct
            allSessionInfo = dataFile.sessionInfo; %all of the session info data in one combined struct
            ResponseTable = struct2table(allExperimentData); %The data struct is converted to a table
            
            %excluding invalid trials
            wantedData = ~(ResponseTable.validTrial == 0); %creates a logical of which trials in the data table were valid
            validIsResponseCorrect = ResponseTable.isResponseCorrect(wantedData); %
            validCondNumber = ResponseTable.condNumber(wantedData);
            if iscell(validIsResponseCorrect) %if this is a cell because there were invalid responses
                correctResponsesArray = cell2mat(validIsResponseCorrect); %convert to an array
                correctResponsesLogical = logical(correctResponsesArray); %then convert to a logical
            else
                correctResponsesLogical = logical(validIsResponseCorrect); %immediately convert to a logical
            end
            
            %Calculating the number of correct responses for each condition for the
            %valid trials
            correctTrials = validCondNumber(correctResponsesLogical); %the conditions of each individual correct response
            correctTrialConditions = unique(correctTrials); %the conditions for which a correct response was made
            condCorrectNumbers = histc(correctTrials, correctTrialConditions); %the total number of correct responses for each condition
            condCorrectNumbers = condCorrectNumbers';
            % %Finding the total number of trials for each condition for the valid trials
            allTrialConditions = unique(validCondNumber); %the conditions for which any response was made
            allTrialNumbers = histc(validCondNumber, allTrialConditions); %the total number of responses for each condition
            allTrialNumbers = allTrialNumbers';
            %allCorrectPercentages = (condCorrectNumbers./allTrialNumbers); %creates a double of the percentage correct responses for every condition
            
            if length(condCorrectNumbers) > 7 && length(condCorrectNumbers) == 9
                
                level8 = condCorrectNumbers(8);
                
                level9 = condCorrectNumbers(9);
                
                condCorrectNumbers = condCorrectNumbers(1:7);
                
                allTrialNumbers = allTrialNumbers(1:7);
                
            elseif length(condCorrectNumbers) > 7 && length(condCorrectNumbers) == 8
                
                level8 = condCorrectNumbers(8);
                
                level9 = 0;
                
                condCorrectNumbers = condCorrectNumbers(1:7);
                
                allTrialNumbers = allTrialNumbers(1:7);
                
            end
            
            %% Specifying what the levels were in different types of analysis
            
            %PROPORTION SPEED CHANGE AT POINT OF CHANGE
            
            if strcmp(currAnalysisType, 'speed_change_changepoint');
                
                xLabelTitle  = 'Proportion speed change at changepoint';
                
                %midspeed accelerating conditions
                if strcmp(currCondition, 'MoveLine_accelerating_depth_midspeed')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_midspeed') ...
                        || strcmp(currCondition, 'MoveLine_accelerating_looming_midspeed');
                    
                    speedDiff = [0 0.22 0.40 0.55 0.67 0.77 0.86]; %2dp
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_slow')...
                        || strcmp(currCondition, 'MoveLine_accelerating_looming_slow');
                    
                    speedDiff = [0 0.22 0.40 0.54 0.67 0.77 0.86]; %2dp
                    
                    %CRS depth conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_midspeed');
                    
                    speedDiff = [0 0.50 0.62 0.71 0.79 0.86 0.91]; %2dp
                    
                    %slow and midspeed CRS lateral conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_slow');
                    
                    speedDiff = [0 0.37 0.51 0.63 0.73 0.81 0.88]; %2dp
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_midspeed');
                    
                    speedDiff = [0 0.50 0.62 0.71 0.79 0.86 0.91]; %2dp
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_slow');
                    
                    speedDiff = [0 0.37 0.51 0.63 0.73 0.81 0.89]; %2dp
                    
                end
                
                
                %ARCMIN SPEED CHANGE AT POINT OF CHANGE
                
            elseif strcmp(currAnalysisType, 'speed_change_changepoint_arcmin');
                
                xLabelTitle  = 'Speed change at changepoint (arcmin/s)';
                
                %midspeed accelerating conditions
                if strcmp(currCondition, 'MoveLine_accelerating_depth_midspeed')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_midspeed');
                    
                    speedDiff = [0 10.5 19.9 28.4 36.1 43.0 49.4];
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_slow');
                    
                    speedDiff = [0 5.3 10.4 15.2 19.8 24.1 28.4];
                    
                elseif strcmp(currCondition, 'MoveLine_accelerating_looming_midspeed');
                    
                    speedDiff = [0 7.0 13.3 18.9 24.0 28.7 32.9];
                    
                elseif strcmp(currCondition, 'MoveLine_accelerating_looming_slow');
                    
                    speedDiff = [0 3.5 7.0 10.1 13.2 16.2 18.8];
                    
                    %CRS depth conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_midspeed');
                    
                    speedDiff = [0 31.6 42.4 52.8 62.4 71.2 79.8];
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_slow');
                    
                    speedDiff = [0 10.2 15.4 20.6 25.8 30.6 35.4];
                    
                    %CRS lateral conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_midspeed');
                    
                    speedDiff = [0 31.6 42.4 52.6 62.2 71.3 79.8];
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_slow');
                    
                    speedDiff = [0 10.1 15.5 20.7 25.7 30.7 35.5];
                    
                end
                
                %PROPORTION SPEED CHANGE OVER ENTIRE INTERVAL, FACTORING OUT
                %ACCELERATION OF NULL
            elseif strcmp(currAnalysisType, 'speed_change_full');
                
                xLabelTitle  = 'Proportion speed change over full interval';
                
                %midspeed accelerating conditions
                if strcmp(currCondition, 'MoveLine_accelerating_depth_midspeed')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_midspeed');
                    
                    Bs = 69.5;
                    As = 30.1;
                    
                    Bt = [69.5 78.1 86.8 95.5 104.1 112.8 121.4];
                    At = [30.1 26.4 22.6 18.8 15.1 11.3 7.53];
                    
                    B = [47.6 63.4 68.8 74 78.8 83.2 87.4];
                    
                    
                    for iFast = 1:length(Bt)
                        
                        fullFastIntervalChange(iFast) = ((Bt(iFast) - At(iFast)) - (Bs - As))/((Bt(iFast)+B(iFast))/2);
                        
                    end
                    
                    speedDiff = fullFastIntervalChange;
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_slow');
                    
                    Bs = 27.2;
                    As = 18.0;
                    
                    Bt = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];
                    At = [18.0 15.8 13.5 11.3 9.01 6.76 4.50];
                    
                    B = [22.3 27.4 30.0 32.6 35.2 37.6 40.0];
                    
                    
                    for iSlow = 1:length(Bt)
                        
                        fullSlowIntervalChange(iSlow) = ((Bt(iSlow) - At(iSlow)) - (Bs - As))/((Bt(iSlow)+B(iSlow))/2);
                        
                    end
                    
                    speedDiff = fullSlowIntervalChange;
                    
                    %                 elseif strcmp(currCondition, 'MoveLine_accelerating_looming_midspeed');
                    %
                    %                     speedDiff = [];
                    %
                    %                 elseif strcmp(currCondition, 'MoveLine_accelerating_looming_slow');
                    %
                    %                     speedDiff = [];
                    
                    %CRS depth conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_midspeed');
                    
                    B = [47.6 63.4 68.8 74.0 78.8 83.2 87.4];
                    A = [47.6 31.8 26.4 21.2 16.4 12.0 7.6];
                    Bt = [69.5 78.1 86.8 95.5 104.1 112.8 121.4];
                    
                    for iCRSDM = 1:length(Bt)
                        
                        fullCRSDMIntervalChange(iCRSDM) = (B(iCRSDM) - A(iCRSDM))/((Bt(iCRSDM)+B(iCRSDM))/2);
                        
                    end
                    
                    speedDiff = fullCRSDMIntervalChange;
                    
                    
                    %slow and midspeed CRS lateral conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_slow');
                    
                    B = [22.3 27.4 30.0 32.6 35.2 37.6 40.0];
                    A = [22.3 17.2 14.6 12.0 9.4 7.0 4.6];
                    Bt = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];
                    
                    for iCRSDS = 1:length(Bt)
                        
                        fullCRSDSIntervalChange(iCRSDS) = (B(iCRSDS) - A(iCRSDS))/((Bt(iCRSDS)+B(iCRSDS))/2);
                        
                    end
                    
                    speedDiff = fullCRSDSIntervalChange;
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_midspeed');
                    
                    B = [47.6 63.4 68.8 73.9 78.7 83.2 87.5];
                    A = [47.6 31.8 26.4 21.3 16.5 11.9 7.7];
                    Bt = [69.5 78.1 86.8 95.5 104.1 112.8 121.4];
                    
                    for iCRSLM = 1:length(Bt)
                        
                        fullCRSLMIntervalChange(iCRSLM) = (B(iCRSLM) - A(iCRSLM))/((Bt(iCRSLM)+B(iCRSLM))/2);
                        
                    end
                    
                    speedDiff = fullCRSLMIntervalChange;
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_slow');
                    
                    B = [22.3 27.4 30.1 32.7 35.2 37.7 40.1];
                    A = [22.3 17.3 14.6 12.0 9.5 7.0 4.6];
                    Bt = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];
                    
                    for iCRSLS = 1:length(Bt)
                        
                        fullCRSLSIntervalChange(iCRSLS) = (B(iCRSLS) - A(iCRSLS))/((Bt(iCRSLS)+B(iCRSLS))/2);
                        
                    end
                    
                    speedDiff = fullCRSLSIntervalChange;
                    
                end
                
                
                %ARCMIN SPEED CHANGE OVER ENTIRE INTERVAL FACTORING OUT
                %ACCELERATION OF NULL
                
            elseif strcmp(currAnalysisType, 'speed_change_full_arcmin');
                
                xLabelTitle  = 'Speed change over full interval (arcmin/s)';
                
                %midspeed accelerating conditions
                if strcmp(currCondition, 'MoveLine_accelerating_depth_midspeed')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_midspeed');
                    
                    speedDiff = [0 12.3 24.8 37.3 49.6 62.1 74.5];
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow')...
                        || strcmp(currCondition, 'MoveLine_accelerating_cd_slow');
                    
                    speedDiff = [0 5.6 11.3 16.9 22.6 28.2 33.9];
                    
                elseif strcmp(currCondition, 'MoveLine_accelerating_looming_midspeed');
                    
                    speedDiff = [0 8.3 16.6 24.8 33.2 41.5 49.7];
                    
                elseif strcmp(currCondition, 'MoveLine_accelerating_looming_slow');
                    
                    speedDiff = [0 3.7 7.5 11.3 15.0 18.8 22.6];
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_midspeed');
                    
                    speedDiff = [0 31.6 42.4 52.8 62.4 71.2 79.8];
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_slow');
                    
                    speedDiff = [0 10.2 15.4 20.6 25.8 30.6 35.4];
                    
                    %CRS lateral conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_midspeed');
                    
                    speedDiff = [0 31.6 42.4 52.6 62.2 71.3 79.8];
                    
                elseif strcmp(currCondition, 'MoveLine_CRS_lateral_slow');
                    
                    speedDiff = [0 10.1 15.5 20.7 25.7 30.7 35.5];
                    
                end
            elseif strcmp(currAnalysisType, 'real_world_change');
                
                xLabelTitle  = 'Speed change in the world (cm/s)';
                
                if strfind(currCondition, 'midspeed')
                    
                    speedDiff = [0 10 20 30 40 50 60];
                    
                elseif strfind(currCondition, 'slow')
                    
                    speedDiff = [0 5 10 15 20 25 30];
                    
                end
                
            elseif strcmp(currAnalysisType,'speed_only')
                
                xLabelTitle = 'Proportion speed difference relative to standard';
                
                if strfind(currCondition, 'fixed_duration')
                    
                    speedDiff = [0 0.15 0.26 0.36 0.44 0.51 0.57];
                    
                elseif strfind(currCondition, 'fixed_distance')
                    
                    speedDiff = [0 0.11 0.20 0.27 0.34 0.39 0.43];
                    
                end
                
            elseif strcmp(currAnalysisType, 'speed_only_arcmin')
                
                xLabelTitle = 'Speed difference relative to standard (arcmin/s)';
                
                if strfind(currCondition, 'fixed_duration')
                    
                    speedDiff = [0 6.6 13.6 21.5 30.1 39.6 50.4];
                    
                elseif strfind(currCondition, 'fixed_distance')
                    
                    speedDiff = [0 5.5 11.2 16.3 22.4 28.1 33.3];
                    
                end
                
                
            elseif strcmp(currAnalysisType, 'real_world_difference')
                
                xLabelTitle  = 'Speed difference in the world relative to standard (cm/s)';
                
                speedDiff = [0 5 10 15 20 25 30];
                
                
            elseif strcmp(currAnalysisType, 'real_world_proportion_difference')
                
                xLabelTitle  = 'Proportion speed difference in the world relative to standard (cm/s)';
                
                speedDiff = [0 0.11 0.2 0.27 0.33 0.38 0.43];
                
            end
            %% Psychometric function fitting adapted from PAL_PFML_Demo
            
            tic
            
            PF = @PAL_CumulativeNormal;
            
            %Threshold and Slope are free parameters, guess and lapse rate are fixed
            paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter
            
            %Parameter grid defining parameter space through which to perform a
            %brute-force search for values to be used as initial guesses in iterative
            %parameter search.
            searchGrid.alpha = linspace(min(speedDiff),max(speedDiff),101);
            searchGrid.beta = linspace(0,(30/max(speedDiff)),101);
            searchGrid.gamma = 0.5;  %scalar here (since fixed) but may be vector
            searchGrid.lambda = 0;  %ditto
            
            %Perform fit
            disp('Fitting function.....');
            [paramsValues, LL, exitflag] = PAL_PFML_Fit(speedDiff,condCorrectNumbers, ...
                allTrialNumbers,searchGrid,paramsFree,PF);
            
            disp('done:')
            message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
            disp(message);
            message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
            disp(message);
            
            disp('Determining standard errors.....');
            
            if ParOrNonPar == 1
                [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapParametric(...
                    speedDiff, allTrialNumbers, paramsValues, paramsFree, BootNo, PF, ...
                    'searchGrid', searchGrid);
            else
                [SD, paramsSim, LLSim, converged] = PAL_PFML_BootstrapNonParametric(...
                    speedDiff, condCorrectNumbers, allTrialNumbers, [], paramsFree, BootNo, PF,...
                    'searchGrid',searchGrid);
            end
            
            disp('done:');
            message = sprintf('Standard error of Threshold: %6.4f',SD(1));
            disp(message);
            message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
            disp(message);
            
            disp('Determining Goodness-of-fit.....');
            
            [Dev, pDev] = PAL_PFML_GoodnessOfFit(speedDiff, condCorrectNumbers, allTrialNumbers, ...
                paramsValues, paramsFree, BootNo, PF, 'searchGrid', searchGrid);
            
            disp('done:');
            
            %Put summary of results on screen
            message = sprintf('Deviance: %6.4f',Dev);
            disp(message);
            message = sprintf('p-value: %6.4f',pDev);
            disp(message);
            
            %Create simple plot
            ProportionCorrectObserved=condCorrectNumbers./allTrialNumbers;
            StimLevelsFineGrain=[min(speedDiff):max(speedDiff)./1000:max(speedDiff)];
            ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
            
            figure;
            axes
            hold on
            plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 .7 0],'linewidth',4);
            plot(speedDiff,ProportionCorrectObserved,'-k.','markersize',40);
            set(gca, 'fontsize',16);
            set(gca, 'Xtick', speedDiff);
            axis([min(speedDiff) max(speedDiff) .4 1]);
            xlabel(xLabelTitle);
            ylabel('proportion correct');
            title(condAndParticipant, 'interpreter', 'none');
            
            figFileName = strcat('psychometric_', currAnalysisType, '_', condAndParticipant, '.pdf');
            saveas(gcf, figFileName);
            
            if strcmp(currAnalysisType, 'arcmin');
                
                RawDataExcelFileName = strcat('raw_data_', condAndParticipant, '.csv');
                writetable(ResponseTable, RawDataExcelFileName);
            end
            
            
            %%
            stimAt75PercentCorrect = PAL_CumulativeNormal(paramsValues, 0.75, 'Inverse');
            slopeAt75PercentThreshold = PAL_CumulativeNormal(paramsValues, stimAt75PercentCorrect, 'Derivative');
            % this slope value might not be particularly close to the beta
            %value that comes out of the paramsValues things as with the
            %cumulative normal function the beta value is the inverse of
            %the standard deviation, which is related/proportional to the
            %slope but not actually the slope.
            
            for iBoot = 1:BootNo
                boot75Threshold(iBoot) = PAL_CumulativeNormal(paramsSim(iBoot,:), 0.75, 'Inverse');
                bootSlopeAt75Threshold(iBoot) = PAL_CumulativeNormal(paramsSim(iBoot,:), boot75Threshold(iBoot), 'Derivative');
            end
            
            thresholdSE = std(boot75Threshold);
            slopeSE = std(bootSlopeAt75Threshold);
            
            sortedThresholdSim = sort(boot75Threshold);
            sortedSlopeSim = sort(bootSlopeAt75Threshold);
            thresholdCI = [sortedThresholdSim(25) sortedThresholdSim(BootNo-25)];
            slopeCI = [sortedSlopeSim(25) sortedSlopeSim(BootNo-25)];
            
            psychInfo(iCond).condition = currCondition;
            %correct values that i've calculated
            psychInfo(iCond).stimAt75PercentCorrect = stimAt75PercentCorrect;
            psychInfo(iCond).slopeAt75PercentThreshold = slopeAt75PercentThreshold;
            psychInfo(iCond).alphaCI = thresholdCI;
            psychInfo(iCond).betaCI = slopeCI;
            psychInfo(iCond).thresholdSE = thresholdSE;
            psychInfo(iCond).slopeSE = slopeSE;
            psychInfo(iCond).level8 = level8;
            psychInfo(iCond).level9 = level9;
            %the original parameters, standard errors from bootstrapping
            %and values from goodness of fit (dev and pdev).
            psychInfo(iCond).condParamsValues = paramsValues;
            psychInfo(iCond).condParamsSE = SD;
            psychInfo(iCond).condParamsDev = Dev;
            psychInfo(iCond).condParamsPDev = pDev;
            
            toc
        end
        psychTable = struct2table(psychInfo);
        psychExcelFileName = strcat('psychometric_data_', currAnalysisType, '_', currParticipantCode, '.csv');
        writetable(psychTable, psychExcelFileName);
    end
end
