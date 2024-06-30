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
    age_z=(age-nanmean(age))./nanstd(age); %Z-score age
    SBP=T.SBP;
    SBP=(SBP-nanmean(SBP))./nanstd(SBP); %Z-score SBP
    MWF=T.MWF;
    MWF_z=(MWF-nanmean(MWF))./nanstd(MWF); %Z-score MWF
    VO2=T.VO2;
    VO2=(VO2-nanmean(VO2))./nanstd(VO2); %Z-score VO2
    T = table(age_z,VO2,SBP,MWF_z); % Add back variables
    T.sex = categorical(sex); %Add categorical sex variable
    T=rmmissing(T); %Remove missing data

    model1='MWF_z~age_z+sex+SBP+VO2+age_z:VO2'; %Linear regression Model 1
    mdl1 = fitlm(T,model1);

    model2='MWF_z~age_z+age_z^2+sex+SBP+VO2+age_z:VO2+age_z^2:VO2'; %Linear regression Model 2
    mdl2 = fitlm(T,model2);
        
    %% MWF vs. Age (Model 1)
    %Extract coefficients and standard errors
    b1 = mdl1.Coefficients.Estimate(1) * nanstd(MWF) + nanmean(MWF); %Extract intercept coefficient (non-Z-scored) (b)
    a1 = mdl1.Coefficients.Estimate(2) * nanstd(MWF); %Extract age coefficient (non-Z-scored) (a)
    b2 = mdl1.Coefficients.SE(1) * nanstd(MWF); %Extract intercept standard error (non-Z-scored)
    a2 = mdl1.Coefficients.SE(2) * nanstd(MWF); %Extract age standard error (non-Z-scored)

    % Degrees of freedom (number of observations minus number of coefficients)
    df = mdl1.DFE;
    
    % Critical t-value for 95% confidence interval
    t_critical = tinv(0.975, df); % Two-tailed, alpha = 0.05
    
    % Generate x values for fitting curve
    x_fit = linspace(min(age), max(age), 136);
    x_fit_z = (x_fit - nanmean(age)) ./ nanstd(age); % Z-scored x values for fitting curve
 
    % Compute fitted curve and confidence bounds
    y = a1 .* x_fit_z + b1; %Calculate fitted curve (y=ax + b)
    y2 = t_critical * sqrt((a2 .* x_fit_z).^2 + b2.^2); %Calculate confidence bounds
    lci = y - y2; %Lower confidence interval
    uci = y + y2; %Upper confidence interval

    % Plot fitted curve
    hold on
    plot(x_fit,y,'-b','LineWidth',3)

    % Plot data points with non-z-scored age and MWF
    plot(age,MWF,'k.','MarkerSize',14)

    % Plot confidence bounds
    fill([x_fit, fliplr(x_fit)], [uci, fliplr(lci)], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none')

    % Set axes limits
    xlim([15 100])
    %ylim([0.11 0.29])

    % Set x and y tick positions
    xticks(linspace(min(age), max(age), 4));
    yticks(linspace(min(MWF), max(MWF), 4));
        
    % Turn off axis data points
    set(gca, 'xticklabel', [], 'yticklabel', [])
    
    % Bold x and y axes lines
    ax = gca;
    ax.XAxis.LineWidth = 3.5;
    ax.YAxis.LineWidth = 3.5;
    
    % Bold x and y tick lines
    ax.XAxis.TickLength = [0.03 0.05];
    ax.YAxis.TickLength = [0.03 0.05];

    hold off

    %% MWF vs. Age (Model 2)
    % Extract coefficients and standard errors
    c1 = mdl2.Coefficients.Estimate(1) * nanstd(MWF) + nanmean(MWF); %Extract intercept coefficient (non-Z-scored) (c)
    b1 = mdl2.Coefficients.Estimate(2) * nanstd(MWF); %Extract age coefficient (non-Z-scored) (b)
    a1 = mdl2.Coefficients.Estimate(7) * nanstd(MWF); %Extract age^2 coefficient (non-Z-scored) (a)
    c2 = mdl2.Coefficients.SE(1) * nanstd(MWF); %Extract intercept standard error (non-Z-scored)
    b2 = mdl2.Coefficients.SE(2) * nanstd(MWF); %Extract age standard error (non-Z-scored)
    a2 = mdl2.Coefficients.SE(7) * nanstd(MWF); %Extract age^2 standard error (non-Z-scored)
   
    % Degrees of freedom (number of observations minus number of coefficients)
    df = mdl2.DFE;
    
    % Critical t-value for 95% confidence interval
    t_critical = tinv(0.975, df); % Two-tailed, alpha = 0.05
    
    % Generate x values for fitting curve
    x_fit = linspace(min(age), max(age), 136);
    x_fit_z = (x_fit - nanmean(age)) ./ nanstd(age); % Z-scored x values for fitting curve
    
    % Compute fitted curve and confidence bounds
    y = a1 .* (x_fit_z.^2) + b1 .* x_fit_z + c1; %Calculate quadratic fitted curve using age^2 (y=ax^2+bx+c)
    y2 = t_critical * sqrt((a2 .* x_fit_z.^2).^2 + (b2 .* x_fit_z).^2 + c2.^2); %Calculate quadratic confidence bounds
    lci = y - y2; %Lower confidence interval
    uci = y + y2; %Upper confidence interval
    
    % Plot fitted curve
    hold on
    plot(x_fit, y, '-b', 'LineWidth', 3)
    
    % Plot data points with non-z-scored age and MWF
    plot(age, MWF, 'k.', 'MarkerSize', 14)
    
    % Plot confidence bounds
    fill([x_fit, fliplr(x_fit)], [uci, fliplr(lci)], 'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    % Set axes limits
    xlim([15 100])
    %ylim([0.11 0.29])

    % Set x and y tick positions
    xticks(linspace(min(age), max(age), 4));
    yticks(linspace(min(MWF), max(MWF), 4));
    
    % Turn off axis data points
    set(gca, 'xticklabel', [], 'yticklabel', [])
    
    % Bold x and y axes lines
    ax = gca;
    ax.XAxis.LineWidth = 3.5;
    ax.YAxis.LineWidth = 3.5;
    
    % Bold x and y tick lines
    ax.XAxis.TickLength = [0.03 0.05];
    ax.YAxis.TickLength = [0.03 0.05];
    
    hold off
