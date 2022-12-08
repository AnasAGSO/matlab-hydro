%% Two Cylinder Model with Load Constraints
%
% This example shows how to model a rigid rod supporting a large mass 
% interconnecting two hydraulic actuators. The model eliminates the 
% springs as it applies the piston forces directly to the load. These 
% forces balance the gravitational force and result in both linear and 
% rotational displacement.
%
% See two related examples that use the same basic components:
% <matlab:cd(setupExample('simulink_general/sldemo_hydrodExample'));open_system('sldemo_hydcyl4')
% four cylinder model> and
% <matlab:cd(setupExample('simulink_general/sldemo_hydrodExample'));open_system('sldemo_hydcyl')
% single cylinder model>.
%
% * Note: This is a basic hydraulics example. You can more easily build hydraulic
% and automotive models using Simscape(TM) Driveline(TM) and Simscape Fluids(TM).
%
% * *Simscape Fluids* provides component libraries for modeling and simulating
% fluid systems. It includes models of pumps, valves, actuators, pipelines, and
% heat exchangers. You can use these components to develop fluid power systems
% such as front-loader, power steering, and landing gear actuation systems. Engine
% cooling and fuel supply systems can also be developed with Simscape Fluids. You
% can integrate mechanical, electrical, thermal, and other systems using
% components available within the Simscape product family.
%
% * *Simscape Driveline* provides component libraries for modeling and simulating
% one-dimensional mechanical systems. It includes models of rotational and
% translational components, such as worm gears, planetary gears, lead screws, and
% clutches. You can use these components to model the transmission of mechanical
% power in helicopter drivetrains, industrial machinery, vehicle powertrains, and
% other applications. Automotive components, such as engines, tires,
% transmissions, and torque converters, are also included.

%   Copyright 2006-2020 The MathWorks, Inc.

%% Analysis and Physics of the Model
%
% We assume the rotation angle of the rod is small. The equations of motion
% for the rod are given below in Equation Block 1. The equations
% describing the cylinder and pump behavior are the same as in the
% single cylinder example.

%%
% *Equation Block 1:*
%
% $$M \frac{d^2 z}{d t^2} = F_b + F_a + F_{ext} $$
%
% $$I \frac{d^2 \theta}{d t^2} = \frac{L}{2}F_b - \frac{L}{2}F_a $$
%
% $$ z        - \mbox{ displacement at the center } $$
%
% $$ M        - \mbox{ total mass } $$
%
% $$ F_a      - \mbox{ piston A force } $$
%
% $$ F_b      - \mbox{ piston B force } $$
%
% $$ F_{ext}  - \mbox{ external force at center } $$
%
% $$ \theta   - \mbox{ clockwise angular displacement } $$
%
% $$ I        - \mbox{ moment of inertia of the rod } $$
%
% $$ L        - \mbox{ rod length } $$

%%
% The positions and velocities of the individual pistons follow directly
% from the geometry. See the corresponding equations below in Equation Block 2.  

%%
% *Equation Block 2:*
% 
% $$ z_a = z - \theta \frac{L}{2} $$ 
%
% $$ z_b = z + \theta \frac{L}{2} $$ 
%
% $$ \frac{d z_a}{dt} = \frac{d z}{dt} - \frac{d \theta}{dt} \frac{L}{2} $$ 
%
% $$ \frac{d z_b}{dt} = \frac{d z}{dt} + \frac{d \theta}{dt} \frac{L}{2} $$
% 
% $$ z_a - \mbox{ piston A displacement } $$
%
% $$ z_b - \mbox{ piston B displacement } $$


%% Opening the Model and Running the Simulation 
%
% To <matlab:openExample('simulink_general/sldemo_hydrodExample') open this
% model>, type |sldemo_hydrod| into the MATLAB(R) Command Window (click the
% hyperlink if you are using MATLAB Help). To run the simulation, on the
% Simulation tab, press *Run*. The model:
%
% * Logs signal data to the MATLAB workspace in the |Simulink.SimulationOutput|
% object |out|. The signal logging data is stored in |out|, in a
% |Simulink.SimulationData.Dataset| object called |sldemo_hydrod_output|.
%
% * Logs continuous states data to MATLAB workspace. The states data is
% also contained in the |out| workspace variable, as a structure called
% |xout|. Each state is assigned a name in the model to facilitate working with logged data. The
% names of the states are available in the |stateName| field of
% |xout.signals|. For more information, see <docid:simulink_ug#bs40i1i-1
% Data Format for Logged Simulation Data>.
%
% * Uses the customizable
% <docid:simulink_ref#mw_0ae488c3-d900-431a-8b61-d6540f7fff74 Circular
% Gauge> and <docid:simulink_ref#mw_aab38d9b-a20c-4ea6-8476-6783d66c29e1
% Vertical Gauge> blocks to visualize the fluid flow, pressure, and linear
% displacement in the cylinders.

%%%%%%% open_system('sldemo_hydrod');   % hidden code, not displayed in HTML example page
evalc('out = sim(''sldemo_hydrod'')');  % run simulation, don't display output

%%
% *Figure 1:* Two cylinder model and simulation results

%% 'Mechanical Load' Subsystem 
%
% This subsystem is shown in Figure 2. It solves the equations of motion,
% which we compute directly using standard Simulink blocks. It is assumed
% that the rotation angle is small. Look under the mask of the 'Mechanical
% Load' subsystem to see its structure (right-click on the subsystem and
% select *Mask* > *Look Under Mask*).

%%%%%%% open_system('sldemo_hydrod/Mechanical Load','force');

%%
% *Figure 2:* 'Mechanical Load' subsystem

%% Simulation Parameters
%
% The parameters used in this simulation are identical to the parameters used in
% the <matlab:cd(setupExample('simulink_general/sldemo_hydrodExample'));open_system('sldemo_hydcyl') single cylinder model>, except
% for the following:

%%
%  L     = 1.5 m
%  M     = 2500 kg
%  I     = 100 kg/m^2
%  Qmax = 0.005 m^3/sec (constant)
%  C2    = 3e-9 m^3/sec/Pa
%  Fext  = -9.81*M Newtons

%% 
%
% Although the pump flow is constant, the model controls the valves
% independently. Initially, at |t = 0|, the cross-section of valve B is zero.
% It grows linearly to |1.2e-5 m^2| at |t = 0.01 sec|, and then linearly
% decreases to zero at |t = 0.02 sec|. The cross-section of valve A is |1.2e-5
% sq.m.| at |t = 0| and it linearly decreases to zero at |t = 0.01 sec|, then it
% linearly increases to |1.2e-5 sq.m.| at |t = 0.02 sec|. Then the behavior of the
% valves A and B repeats periodically with the same pattern. In other words the
% valves A and B are 180 degrees out of phase.

%% Results
%
% Figures 3 and 4 show the linear and angular displacements of the rod. The
% linear displacement response is typical of a type-one integrating system. The
% relative positions and the angular movement of the rod illustrate the response
% of the two pistons to the out-of-phase control signals (the cross-section of
% the valves A and B).
%
% 
% %%%%%%% Plot Linear and Angular Displacements, hidden code
% plot(out.sldemo_hydrod_output.get('LinearDisplacement').Values.za.Time,  ...
%      out.sldemo_hydrod_output.get('LinearDisplacement').Values.za.Data,'g',...
%      out.sldemo_hydrod_output.get('LinearDisplacement').Values.zb.Time,  ...
%      out.sldemo_hydrod_output.get('LinearDisplacement').Values.zb.Data,'r',...
%      out.sldemo_hydrod_output.get('LinearDisplacement').Values.z.Time,  ...
%      out.sldemo_hydrod_output.get('LinearDisplacement').Values.z.Data,'w');
% set(gca,'Color','k','XGrid','On','XColor',[0.3 0.3 0.3],...
%                     'YGrid','On','YColor',[0.3 0.3 0.3]);
% xlabel('Time (sec)');
% ylabel('Linear Displacement (m)');
% title('Simulation Results: Piston Linear Displacement');
% h = legend('Piston A','Piston B','Load','Location','best');
% set(h,'TextColor','w','Color','none'); clear h;

%%
% %%%%%%% *Figure 3:* Linear displacement of the pistons and the load (load is in the middle of the rod)
% 
% plot(out.sldemo_hydrod_output.get('theta').Values.Time,  ...
%      out.sldemo_hydrod_output.get('theta').Values.Data, 'g');
% set(gca,'Color','k','XGrid','On','XColor',[0.3 0.3 0.3],...
%                     'YGrid','On','YColor',[0.3 0.3 0.3]);
% xlabel('Time (sec)');
% ylabel('Angular Displacement (rad)');
% title('Simulation Results: Rod Angular Displacement');

%%
% *Figure 4:* Angular displacement of the rod

%% Close Model
%
% Close the model and clear all generated data.

%%%%%%% close_system('sldemo_hydrod', 0);
save('output.mat','out')
clear sldemo_hydrod_output;

%% Conclusions
%
% Simulink provides a productive environment for simulating hydraulic
% systems, offering enhancements that provide enormous productivity in
% modeling and flexibility in numerical methods. The use of masked
% subsystems and model libraries facilitates structured modeling with
% automatic component updates. As users modify library elements,
% the models that use the elements automatically incorporate the new
% versions. Simulink can use differential-algebraic equations (DAEs) to
% model some fluid elements as incompressible and others as compliant,
% allowing efficient solutions for complex systems of interdependent
% circuits. 
%
% Models such as this one can ultimately be used as part of overall plant
% or vehicle systems. The hierarchical nature of Simulink allows
% independently developed hydraulic actuators to be placed, as appropriate,
% in larger system models (for example adding controls in the form of
% sensors or valves). In cases such as these, tools from the Control System
% Toolbox(TM) can analyze and tune the overall closed-loop system. The
% MATLAB/Simulink environment can thus support the entire design, analysis,
% and modeling cycle.
