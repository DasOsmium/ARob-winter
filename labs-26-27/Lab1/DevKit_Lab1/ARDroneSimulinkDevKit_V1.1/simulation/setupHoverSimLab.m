%% =======================================================================
%  ARDrone Simulation Example: Hovering and Position Control
%  =======================================================================
%  
%  The simulation is used to validate the controller and guidance logic of
%  the ARDRone before flight testing. Control blocks are
%  exactly the same for both simulation and real-time Wi-Fi control.
%  
%  Authors:
%       David Escobar Sanabria -> descobar@aem.umn.edu
%       Pieter J. Mosterman -> pieter.mosterman@mathworks.com
%  =======================================================================

%%
%  Cleaning workspace
bdclose all;
clear all;
clc

%%
% Adding ARDrone library path 
addpath ../lib; 
%% Simulation parameters

% Flight management system sample time. This is the sample time at which
% the control law is executed. 
FMS.Ts = 0.03;%0.065; 

% Time delay due to communication between drone and host computer
timeDelay = FMS.Ts*4; 


%% Vehicle model based on linear dynamics

% Loading state space representation of vehicle dynamics
setupARModel; 

%%
% Loading list of waypoints
waypoints = getWaypoints() ;


%% 
% Simulation time
simDT = 0.005 ;
%%
% Loading Simulink model of ARDrone
%ARDroneHoverSimLab;
simu = simulation('ARDroneHoverSimLab') ;
CHeight = 1;
GainHeight = 0.5;
start(simu);
% Wait for simulation to finish without using wait (use poll on Status)
while strcmp(simu.Status,'running')
    pause(1);
end
pause(1);
logsout = simu.SimulationOutput.logsout;
Height1 = logsout{1}.Values;
%second entry
CHeight = 0.8;
GainHeight = 1;
start(simu);
% Wait for simulation to finish without using wait (use poll on Status)
while strcmp(simu.Status,'running')
    pause(1);
end
pause(1);
logsout = simu.SimulationOutput.logsout;
Height2 = logsout{1}.Values;
%third entry
CHeight = 0.3;
GainHeight = 2;
start(simu);
% Wait for simulation to finish without using wait (use poll on Status)
while strcmp(simu.Status,'running')
    pause(1);
end
pause(1);
logsout = simu.SimulationOutput.logsout;
Height3 = logsout{1}.Values;
%forth entry
CHeight = 0.2;
GainHeight = 3;
start(simu);
% Wait for simulation to finish without using wait (use poll on Status)
while strcmp(simu.Status,'running')
    pause(1);
end
pause(1);
logsout = simu.SimulationOutput.logsout;
Height4 = logsout{1}.Values;

save('.output.mat','Height1','Height2','Height3','Height4')