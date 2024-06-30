clear;
clc;

Relaxometryfile = xlsread('BLSA_GESTALT_MWF_VO2.xlsx',1);

% Associates data with specific variables

    % MWF Data
    MWF = Relaxometryfile(:,7); %Whole brain ROI

    % Parameters
    age = Relaxometryfile(:,1);
    sex = Relaxometryfile(:,2);
    race = Relaxometryfile(:,3);
    SBP = Relaxometryfile(:,4);
    VO2 = Relaxometryfile(:,5);

    %% Multiple Linear Regression       
    T = table(age,VO2,SBP,MWF); %Add variables to table
    age=T.age;
    age=(age-nanmean(age))./nanstd(age); %Z-score age
    SBP=T.SBP;
    SBP=(SBP-nanmean(SBP))./nanstd(SBP); %Z-score SBP
    MWF=T.MWF;
    MWF=(MWF-nanmean(MWF))./nanstd(MWF); %Z-score MWF
    VO2=T.VO2;
    VO2=(VO2-nanmean(VO2))./nanstd(VO2); %Z-score VO2
    T = table(age,VO2,SBP,MWF); % Add back variables
    T.sex = categorical(sex); %Add categorical sex variable
    T=rmmissing(T); %Remove missing data

    model1='MWF~age+sex+SBP+VO2+age:VO2'; %Linear regression Model 1
    mdl1 = fitlm(T,model1);

    model2='MWF~age+age^2+sex+SBP+VO2+age:VO2+age^2:VO2'; %Linear regression Model 2
    mdl2 = fitlm(T,model2);
        
    %% MWF vs. Adjusted VO2 (Model 1)
    % Plotting
    figure;
    hold on;
    
    hMDL = plotAdded(mdl1, 3); %Plot model with adjusted VO2

    %Everything below (lines 47-92) were done for cosmetic purposes to
    %change look of plot:
    set(hMDL(1), 'Color', 'k', 'Marker', '.', 'MarkerSize', 14) % Customize data points
    delete(hMDL(2)); % Delete automatically generated fitted curve
    delete(hMDL(3)); % Delete automatically generated confidence bounds
    
    % Prepare data for prediction
    X = linspace(min(T.VO2), max(T.VO2), 100)';
    meanAge = mean(T.age, 'omitnan');  % Calculate mean, omitting NaN values
    meanSBP = mean(T.SBP, 'omitnan');  % Calculate mean, omitting NaN values
    
    % Create X_table with a constant age and SBP, but varying VO2
    X_table = table(X, repmat(meanAge, length(X), 1), repmat(meanSBP, length(X), 1), 'VariableNames', {'VO2', 'age', 'SBP'});
    
    % Include sex (categorical variable)
    modeSex = mode(T.sex);  % Use the mode of sex or another representative value
    X_table.sex = repmat(modeSex, size(X_table, 1), 1);
    
    % Recalculate predictions with pointwise intervals
    [Y_pred, Y_pred_CI] = predict(mdl1, X_table, 'Prediction', 'curve', 'Alpha', 0.05, 'Simultaneous', false);
    
    % Plot prediction line and confidence bounds
    plot(X, Y_pred, 'b', 'LineWidth', 3);  % Prediction line
    fill([X; flipud(X)], [Y_pred_CI(:,1); flipud(Y_pred_CI(:,2))], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');  % Confidence bounds
    xlabel('');
    ylabel('');
    title('');
    xlim([-2 1.8])
    %ylim([-2 2.6])

    % Set x and y tick positions
    xticks(linspace(min(X), max(X), 6));
    yticks(linspace(min(MWF), max(MWF), 5));
        
    % Turn off axis data points
    set(gca, 'xticklabel', [], 'yticklabel', [])
    
    % Bold x and y axes lines
    ax = gca;
    ax.XAxis.LineWidth = 3.5;
    ax.YAxis.LineWidth = 3.5;
    
    % Bold x and y tick lines
    ax.XAxis.TickLength = [0.03 0.05];
    ax.YAxis.TickLength = [0.03 0.05];

    hold off;

    %% MWF vs. Adjusted VO2 (Model 2)
    % Plotting
    figure;
    hold on;
    
    hMDL = plotAdded(mdl2, 3); %Plot model with adjusted VO2

    % Everything below (lines 102-147) were done for cosmetic purposes to
    %change look of plot:
    set(hMDL(1), 'Color', 'k', 'Marker', '.', 'MarkerSize', 14) % Customize data points
    delete(hMDL(2)); % Delete automatically generated fitted curve
    delete(hMDL(3)); % Delete automatically generated confidence bounds
    
    % Prepare data for prediction
    X = linspace(min(T.VO2), max(T.VO2), 100)';
    meanAge = mean(T.age, 'omitnan');  % Calculate mean, omitting NaN values
    meanSBP = mean(T.SBP, 'omitnan');  % Calculate mean, omitting NaN values
    
    % Create X_table with a constant age and SBP, but varying VO2
    X_table = table(X, repmat(meanAge, length(X), 1), repmat(meanSBP, length(X), 1), 'VariableNames', {'VO2', 'age', 'SBP'});
    
    % Include sex (categorical variable)
    modeSex = mode(T.sex);  % Use the mode of sex or another representative value
    X_table.sex = repmat(modeSex, size(X_table, 1), 1);
 
    % Recalculate predictions with pointwise intervals
    [Y_pred, Y_pred_CI] = predict(mdl2, X_table, 'Prediction', 'curve', 'Alpha', 0.05, 'Simultaneous', false);
    
    % Plot prediction line and confidence bounds
    plot(X, Y_pred, 'b', 'LineWidth', 3);  % Prediction line
    fill([X; flipud(X)], [Y_pred_CI(:,1); flipud(Y_pred_CI(:,2))], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');  % Confidence bounds
    xlabel('');
    ylabel('');
    title('');
    xlim([-1.6 1.8])
    %ylim([-2.2 2.4])

    % Set x and y tick positions
    xticks(linspace(min(X), max(X), 6));
    yticks(linspace(min(MWF), max(MWF), 5));
        
    % Turn off axis data points
    set(gca, 'xticklabel', [], 'yticklabel', [])
    
    % Bold x and y axes lines
    ax = gca;
    ax.XAxis.LineWidth = 3.5;
    ax.YAxis.LineWidth = 3.5;
    
    % Bold x and y tick lines
    ax.XAxis.TickLength = [0.03 0.05];
    ax.YAxis.TickLength = [0.03 0.05];

    hold off;
