%% SECTION 1: Title
%  Project: Recursive Model for Decoupled Aquaponics System
%  Author: Evan Gibbs egibbs2@ycp.edu
%  Last Updated Date: 11/1/2024

%% SECTION 2: Initial Conditions of Model Dynamic Variables to be Plotted

Nitrate_Fish = 72.6;  % Nitrogen Concentration of Fish Tank
Nitrate_Plants = 0;  % Nitrogen Concentration of Plant Container

%% SECTION 3: Reading of Matrix Data

% Add data and own fits here. All data was sourced from York College of Pennsylvania Biology Department. Contact egibbs2@ycp.edu for data and fitting process.

%P_D_W=readmatrix('SIMULINK_FINAL_Protein.xlsx'); % Reads data for multivariable function determining fish weight
%P_W_D=readmatrix('SIMULINK_FINAL_Protein_INVERTED.xlsx'); % Reads data for multivariable function determining theorectical fish age
%K_UR=readmatrix('KALE_CURVEFIT_DATA.xlsx'); % Reads data for function determining kale uptake rate

%% SECTION 4: Calling Createfit to Generate Model based on Experimental Data

[fitresult, gof] = createFit3(P_D_W(:,1), P_D_W(:,2), P_D_W(:,3));  % Linearly interpolated fit for multivariate weight fish function
[fitresult2, gof2] = createFit1(P_W_D(:,1), P_W_D(:,2), P_W_D(:,3));  % Linearly interpolated fit for multivariate age fish function
[fitresult3, gof3] = createFit2(K_UR(:,1), K_UR(:,2));  % Polynomial Regression fit for kale uptake rate function

%% SECTION 5: Model Constants and Variables from User Input 

Number_Fish = 18;  % Number of Fish in an individual tank
Number_Plant = 6;  % Number of Plants in  an individual tank
Volume_Fish = 76;  % Volume of fish aquarium
Volume_Plant = 9;  % Volume of plant tub
Protein_Percent = 25; % Protein percent of feed given to tilapia
Starting_Weight = 0.690740740740741; % Starting Average individual weight of tilapia (grams)
Water_Transfer_Rate = 7; % Water transfer rate (days) from aquarium to kale tub
Plant_Start_Date = 28; % Date that plants are started in system
Length_Exp = 64; % Length allowing systems to run inclusive

% Determination of Starting Age of Fish
fixed_day_start = fitresult2(Protein_Percent, Starting_Weight);

% Model Additional Variables 
t = 0; % Time t
Feed_Percentage = 0.05; % Initial Bodyweight Percentage of Feed Given
Protein_Transfer_Rate = .3525; % Protein Transferred to Nitrate Content
anoxic_denitrification = 1; % Effecting Rate of Anoxic Dentrification
avg_weight_exp_2 = 44.84; % Starting Weight for Experiment 2
avg_weight_exp_3 = 95.66; % Starting Weight for Experiment 3
avg_weight_exp_4 = 264.34; % Starting Weight for Experiment 4

%% SECTION 6: Populate Arrays to Store Time, Weight, and Nitrate Concentrations

time_F = zeros(1, Length_Exp*2-1); % Array to store time values for nitrate concentrations of fish tank (length x 2)
time_P = zeros(1,Length_Exp*2-1);  % Array to store time values for nitrate concentrations of kale tub (length x 2)
time_W = zeros(1,Length_Exp-1); % Array to store time values for fish weights (length) 
nitrate_fish = zeros(1, Length_Exp*2-1); % Array to store nitrate concentrations of fish tank (length x 2)
nitrate_plants = zeros(1, Length_Exp*2-1); % Array to store nitrate concentrations of kale tub (length x 2)
weight_fish = zeros(1, Length_Exp-1); % Array to store fish weights (length) 

%% SECTION 7: Indexing Variable for Specific Arrays

J=1; %Indexing variable for time_F and nitrate_fish
P=1; %Indexing variable for time_P and nitrate_plants


%% SECTION 8: Calculation of Nitrate Concentration of Plant and Fish Aquarium

for i=1:Length_Exp

% Updating Weight_Fish Function Prior to Nitrate Concentrations
Weight_Fish = fitresult(Protein_Percent, fixed_day_start - 1 + i);
    
% Updating Change_Nitrate_Fish based on Weight_Fish
Change_Nitrate_Fish = (anoxic_denitrification) * (Protein_Transfer_Rate) * (1000 / Volume_Fish) * (Number_Fish) * (Feed_Percentage) * 0.01 * (Protein_Percent) * Weight_Fish;

% Nitrate_Fish Calculation on Start of Experiment
if i==1
    Feed_Percentage = 0.05;
    Nitrate_Fish = Nitrate_Fish;
end

% Updating and Calculation of Nitrate_Fish based on Weight of Tilapia 
if i>1
if Starting_Weight < avg_weight_exp_2
            Feed_Percentage = 0.05;
            Nitrate_Fish = Nitrate_Fish + Change_Nitrate_Fish;

        elseif Starting_Weight >= avg_weight_exp_2 && Starting_Weight < avg_weight_exp_3
            Feed_Percentage = 0.03;
            Nitrate_Fish = Nitrate_Fish + Change_Nitrate_Fish;

        elseif Starting_Weight >= avg_weight_exp_3 && Starting_Weight < avg_weight_exp_4
            Feed_Percentage = 0.025;
            Nitrate_Fish = Nitrate_Fish + Change_Nitrate_Fish;

        elseif Starting_Weight > avg_weight_exp_4
            Feed_Percentage = 0.015;
            Nitrate_Fish = Nitrate_Fish + Change_Nitrate_Fish;
 
end
end

% Updating Arrays with the Nitrate_fish and Time with Respect to Indexing Variables
nitrate_fish(J) = Nitrate_Fish;
time_F(J)= t;
J=J+1;

% Calculation and Storing for Nitrate_Plants Prior to Plant Start Date
if i-1 < Plant_Start_Date 
        Nitrate_Plants = 0;
        nitrate_plants(P)= Nitrate_Plants;
        time_P(P)=t;
        P=P+1;

% Calculation and Storing for Nitrate_Plants on Plant Start Date
    elseif i-1 == Plant_Start_Date
        nitrate_plants(P)= Nitrate_Plants;
        time_P(P)=t;
        P=P+1;
        Nitrate_Plants = Nitrate_Fish;

% Calculation and Storing for Nitrate_Plants After Plant Start Date
    elseif i-1 > Plant_Start_Date

% Calculation and Storing After Plant Start Date AND Not on Transfer Day
if mod(i-1-Plant_Start_Date, Water_Transfer_Rate) ~= 0
            % Calculate the amount of nitrate removed by plants
            Nitrate_Plants_Uptake = (Number_Plant) * fitresult3(i-Plant_Start_Date);

            % Update Nitrate_Plants, ensuring it doesn't go below 0
            Nitrate_Plants = max(0, Nitrate_Plants - Nitrate_Plants_Uptake);
            nitrate_plants(P)= Nitrate_Plants;
            time_P(P)=t;
            P=P+1;

% Calculation and Storing After Plant Start Date AND Not on Transfer Day           
    elseif mod(i-1-Plant_Start_Date, Water_Transfer_Rate) == 0
          
            % Calculate the amount of nitrate removed by plants
            Nitrate_Plants_Uptake = (Number_Plant) * fitresult3(i-Plant_Start_Date);

            % Update Nitrate_Plants, ensuring it doesn't go below 0
            Nitrate_Plants = max(0, Nitrate_Plants - Nitrate_Plants_Uptake);
            nitrate_plants(P)= Nitrate_Plants;
            time_P(P)=t;
            P=P+1;
            Nitrate_Plants = Nitrate_Fish;
    end
    end

% Updating Arrays with the Nitrate_Plants and Time with Respect to Indexing Variables
nitrate_plants(P)= Nitrate_Plants;
time_P(P)=t;
P=P+1;
 
% Calculation of Nitrate_Fish After Start of Experiment AND On Transfer Day
if mod(i-1, Water_Transfer_Rate) == 0 && i ~= 1
if Starting_Weight < avg_weight_exp_2
            Feed_Percentage = 0.05;
            Nitrate_Fish = (Nitrate_Fish) * (Volume_Fish - Volume_Plant-9) / Volume_Fish;

        elseif Starting_Weight >= avg_weight_exp_2 && Starting_Weight < avg_weight_exp_3
            Feed_Percentage = 0.03;
            Nitrate_Fish = (Nitrate_Fish) * (Volume_Fish - Volume_Plant-9) / Volume_Fish;

        elseif Starting_Weight >= avg_weight_exp_3 && Starting_Weight < avg_weight_exp_4
            Feed_Percentage = 0.025;
            Nitrate_Fish = (Nitrate_Fish) * (Volume_Fish - Volume_Plant-9) / Volume_Fish;

        elseif Starting_Weight > avg_weight_exp_4
            Feed_Percentage = 0.015;
            Nitrate_Fish = (Nitrate_Fish) * (Volume_Fish - Volume_Plant-9) / Volume_Fish;

        end
end
    
% Updating Arrays with the Nitrate_fish and Time with Respect to Indexing Variables
time_F(J) = t;
nitrate_fish(J) = Nitrate_Fish;
J=J+1;

% Updating Arrays with the Weight_fish and Time with Respect to Indexing Variables
weight_fish(i)=Weight_Fish;
time_W(i) =t;

% Update Day of Experiment
t = t + 1;

% Print Weight of Average, Individual Tilapia on a Given Day
fprintf('Fish weight at time step %d: %.5f grams\n', i-1, Weight_Fish);

end


%% SECTION 9: Plotting Desired Variables 

% Plot nitrate_fish vs. time vs. experimental scatter vs. experimental avg.
figure;
plot(time_F,nitrate_fish,'LineWidth',2);
hold on;
tbl1 = readmatrix('25%_PRIOR_DATA_TILAPIA.xlsx');
scatter(tbl1(:,1), tbl1(:,2),"*");
hold on;
tbl2 = readmatrix('25%_AFTER_DATA_TILAPIA.xlsx');
scatter(tbl2(:,1), tbl2(:,2),"k","*");
hold on;
tbl3 = readmatrix('25%_AVG_DATA_TILAPIA.xlsx');
plot(tbl3(:,1), tbl3(:,2),'LineWidth',2);
title('Nitrate Concentration in Fish Tank (PPM)');
xlabel('Time (days)');
ylabel('Nitrate Concentration (PPM)');
grid on;

% Plot nitrate_plants vs. time vs. experimental scatter vs. experimental avg.
figure;
plot(time_P, nitrate_plants);
plot(time_P, nitrate_plants,'LineWidth',2);
hold on;
tbl3 = readmatrix('25%_ALL_DATA_Kale.xlsx');
scatter(tbl3(:,1), tbl3(:,2), "*");
hold on;
tbl4 = readmatrix('25%_AVG_DATA_Kale.xlsx');
plot(tbl4(:,1), tbl4(:,2), 'r');
plot(tbl4(:,1), tbl4(:,2), 'LineWidth',2);
title('Nitrate Concentration in Plant Container (PPM)');
xlabel('Time (days)');
ylabel('Nitrate Concentration (PPM)');
grid on;

%  Plot nitrate_plants vs. time vs. experimental scatter vs. experimental avg.
figure;
plot(time_W, weight_fish);
plot(time_W, weight_fish,'LineWidth',2);
hold on;
tbl3 = readmatrix('25%_ALL_DATA_WEIGHT.xlsx');
scatter(tbl3(:,1), tbl3(:,2), "*");
hold on;
tbl4 = readmatrix('25%_AVG_DATA_WEIGHT.xlsx');
plot(tbl4(:,1), tbl4(:,2), 'r');
plot(tbl4(:,1), tbl4(:,2), 'LineWidth',2);
title('Tilapia Weight Over Time');
xlabel('Time (days)');
ylabel('Weight (grams)');
grid on;

%Plot of the Range of  Approximations
figure;
plot(time_F,nitrate_fish,'LineWidth',2);
hold on;
tbl5 = readmatrix('25%_MAX_DATA_TILAPIA.xlsx');
tbl6 = readmatrix('25%_MIN_DATA_TILAPIA.xlsx');
plot(tbl5(:,1), tbl5(:,2), 'LineWidth', 2);
hold on;
plot(tbl6(:,1), tbl6(:,2), 'LineWidth', 2);
x = [tbl5(:,1)', fliplr(tbl6(:,1)')]; 
y = [tbl5(:,2)', fliplr(tbl6(:,2)')]; 
fill(x, y, 'g', 'FaceAlpha', 0.3); % 'g' for green, adjust 'FaceAlpha' for transparency
xlabel('X Axis Label');
ylabel('Y Axis Label');
legend('tbl5', 'tbl6', 'Shaded Area')
xlim([min(tbl5(:,1)), max(tbl5(:,1))]); 
title('Nitrate Concentration in Fish Tank (PPM)');
xlabel('Time (days)');
ylabel('Nitrate Concentration (PPM)');
grid on;


