% NanoRad-STEM
% 
% Author: Giuseppe De Salvo
% 
% This simulation works with the COMSOL® package under COMSOL® Livelink™ for MATLAB®.
% The code has been written under a CC license.

%% Import the COMSOL model .mph file 

model = mphopen('STEM_100');

% Uncomment the line below if you want to see the structure of the imported model
%mphnavigator  

%% Configure the loop for domain activation

numIters=100;
domInd = [2:101];

%% Activation of scanning beam domains 
% Define the physics for applying changes 

tds = model.physics('tds');

% Initialize storage for results 

table_app   = cell(numIters,1);
table_left   = cell(numIters,1);

% Main loop
for i = 1:numIters
    
    k =  i;

    tds.feature('reac2').selection.set(domInd(k));
    
    % Solve the model
    model.study('std1').run;
 
    %% Results Extraction
    
    if i==1
       % point evaluation #1
       model.result.numerical.create('pev1', 'EvalPoint');
       model.result.numerical('pev1').selection.set([6]); % set the domain (e.g. surface,line,point etc.) where data will be extracted
       model.result.numerical('pev1').set('expr', {'cH' 'cH2' 'cEh_1m' 'cOH' 'cH_1p' 'cO2' 'cHO2_1m' 'cO2_1m' 'cO2' 'cH2O2'  ...
       'cO_1m' 'cOH_1m'});
       model.result.numerical('pev1').set('descr', {'H' 'H2' 'e-' 'OH' 'H+' 'O2' 'HO2-' 'O2-' 'O2' 'H2O2'  ...
       'O-' 'OH-'});
       % line evaluation
       model.result.dataset.create('cpt1', 'CutPoint2D');
       model.result.dataset('cpt1').set('pointy', 0);
       model.result.dataset('cpt1').set('pointx', 'range(-2[nm],0.1[nm],18[nm])');
       model.result.numerical.create('pev1', 'EvalPoint');
       model.result.numerical('pev1').set('data', 'cpt1');
       model.result.numerical('pev1').set('expr', {'cH' 'cH2' 'cEh_1m' 'cO2'});
       model.result.numerical('pev1').set('descr', {'H' 'H2' 'e-' 'O2'});
       
       %surface plot example
       %pg12=model.result.create('pg12', 'PlotGroup2D');
       %model.result('pg12').label('Concentration, OH- (tds)');
       %model.result('pg12').set('titletype', 'custom');
       %model.result('pg12').set('prefixintitle', 'Species OH-:');
       %model.result('pg12').set('expressionintitle', false);
       %model.result('pg12').set('typeintitle', true);
       %model.result('pg12').create('surf1', 'Surface');
       
       %model.result('pg12').feature('surf1').set('expr', 'cOH_1m');
       %model.result('pg12').feature('surf1').set('colortable', 'WaveLight');
       %model.result('pg12').run; 
       
       %Initialise solution 
       
       %tds.feature('init1').set('c',1 , 'c');
       v1 = model.sol('sol1').feature('v1');
       v1.set('initsol', 'sol1');

    end
   
    %create table
    model.result.table.create('tbl2', 'Table');
    model.result.table('tbl2').comments('Point Evaluation 1');
    model.result.numerical('pev1').set('table', 'tbl2');
    model.result.numerical('pev1').setResult;
   
    %save results
    table_app{i}= mphtable(model,'tbl2');
    %table_left{i}= mphtable(model,'tbl3');
    
    % remove results for the next iteration
    model.result.table.remove('tbl2');
    %model.result.table.remove('tbl3'); 
    
    %Plot the surface
      %figure(1)
      %subplot(2,1,i)
      %model.result('pg12').setIndex('looplevel', 6, 0);
      %pg12.setIndex('looplevel', '25', 0);
      %mphplot(model,'pg12');
      
    % Update initial time for the next iteration.
    time = mphglobal(model,'t','solnum','end');
    model.param.set('t0',time);

    % End of the iteration.
    disp(sprintf('End of iteration No.%d',i));
end