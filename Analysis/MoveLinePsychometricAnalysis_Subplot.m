clearvars;
dataDir = uigetdir();
cd(dataDir)

participantCodes = {'G'};
ParOrNonPar = 2; %non-parametric bootstrap for all
BootNo = 1000; %number of simulations for all bootstraps and goodness of fits

for iParticipant = 1:length(participantCodes)
    
    currParticipantCode = cell2mat(participantCodes(iParticipant));
    
    conditionList = {'MoveLine_accelerating_depth_midspeed'; ...
        'MoveLine_accelerating_depth_slow'; 'MoveLine_accelerating_lateral_midspeed'; ...
        'MoveLine_accelerating_lateral_slow'; 'MoveLine_CRS_depth_midspeed'; ...
        'MoveLine_CRS_depth_slow'; 'MoveLine_CRS_lateral_midspeed'; 'MoveLine_CRS_lateral_slow'}; 
    % the list of conditions to analyse data from
    
    analysisType = {'speed_change_changepoint'};
    % the type or types of analysis to run (speed_change_changepoint is
    % used in the main body of the paper, the other three are not used in 
    %the paper as they result in more biased values)
    
    for iAnalysis = 1:length(analysisType)
        currAnalysisType = cell2mat(analysisType(iAnalysis));
        for iCond = 1:length(conditionList)
            currCondition = cell2mat(conditionList(iCond));
            condAndParticipant = strcat(currCondition, '_', currParticipantCode);

            fileDir = fullfile(dataDir,[condAndParticipant, '_*']); 
            %If no data files are found and collated, check that this is going to the correct directory
            
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
            
            %% Specifying what the levels were in different types of analysis
            %All x-axis values in this section are entered manually (have
            %been calculated separately)
            
            %PROPORTION SPEED CHANGE AT POINT OF CHANGE
            
            if strcmp(currAnalysisType, 'speed_change_changepoint');
                
                xLabelTitle  = 'Proportion speed change at changepoint';
                
                %midspeed accelerating conditions
                if strcmp(currCondition, 'MoveLine_accelerating_depth_midspeed')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed');
                    
                    speedDiff = [0 0.22 0.40 0.55 0.67 0.77 0.86]; %2dp; x-axis for psychometric function
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow');
                    
                    speedDiff = [0 0.22 0.40 0.54 0.67 0.77 0.86]; %2dp; x-axis for psychometric function
                    
                    %CRS depth conditions
                elseif strcmp(currCondition, 'MoveLine_CRS_depth_midspeed');
                    
                    speedDiff = [0 0.50 0.62 0.71 0.79 0.86 0.91]; %2dp; x-axis for psychometric function
                    
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
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed');
                    
                    speedDiff = [0 10.5 19.9 28.4 36.1 43.0 49.4];
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow');
                    
                    speedDiff = [0 5.3 10.4 15.2 19.8 24.1 28.4];
                    
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
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed');
                    
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
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow');
                    
                    Bs = 27.2;
                    As = 18.0;
                    
                    Bt = [27.2 30.6 34.0 37.4 40.8 44.2 47.6];
                    At = [18.0 15.8 13.5 11.3 9.01 6.76 4.50];
                    
                    B = [22.3 27.4 30.0 32.6 35.2 37.6 40.0];
                    
                    
                    for iSlow = 1:length(Bt)
                        
                        fullSlowIntervalChange(iSlow) = ((Bt(iSlow) - At(iSlow)) - (Bs - As))/((Bt(iSlow)+B(iSlow))/2);
                        
                    end
                    
                    speedDiff = fullSlowIntervalChange;
                    
                    
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
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_midspeed');
                    
                    speedDiff = [0 12.3 24.8 37.3 49.6 62.1 74.5];
                    
                    %slow accelerating conditions
                elseif strcmp(currCondition, 'MoveLine_accelerating_depth_slow')...
                        || strcmp(currCondition,'MoveLine_accelerating_lateral_slow');
                    
                    speedDiff = [0 5.6 11.3 16.9 22.6 28.2 33.9];
                    
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
           
            end
            %% Psychometric function fitting adapted from PAL_PFML_Demo
            %Fits cumulative normal psychometric functions to the data from
            %each condition for each participant
            
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
            
            figToPrint = subplot(2,4,iCond);
            hold on
            plot(StimLevelsFineGrain,ProportionCorrectModel,'-','Color', [0.2, 0.2, 0.2],'linewidth',3);
            plot(speedDiff,ProportionCorrectObserved,'k.','markersize',20);
            set(gca, 'fontsize',8);
            set(gca, 'FontName', 'Arial');
            set(gca, 'Xtick', 0:0.2:1);
            set(gca, 'YTick', 0.4:0.1:1);
            set(gca, 'XTickLabel', str2mat('0', '', '', '', '', '1'));
            set(gca, 'YTickLabel', str2mat('0.4','', '', '', '','','1'));
            axis([0 1 .4 1]);
            xlabel('Proportion speed change');
            ylabel('Proportion correct');
            

            
            %% Collating the data to then be saved
            
            stimAt75PercentCorrect = PAL_CumulativeNormal(paramsValues, 0.75, 'Inverse');
            slopeAt75PercentThreshold = PAL_CumulativeNormal(paramsValues, stimAt75PercentCorrect, 'Derivative');
            %Here the beta value is the inverse of the standard deviation, 
            %which is related/proportional to the slope but is not actually the slope.
            
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
