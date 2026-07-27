%
% File: cartPendulumSFunction.m
% https://blogs.mathworks.com/graphics/2014/10/21/double_pendulum/
%
function cartPendulumSFunction(block)
% Level-2 MATLAB file S-function for visualizing a double pendulum.
  setup(block)
end
%
% Called when the block is added to a model.
function setup(block)
  %
  % 1 input port, no output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 0;
  %
  % Setup functional port properties
  block.SetPreCompInpPortInfoToDynamic;
  %
  % The first input is an angle
  block.InputPort(1).Dimensions = 1;
  % The second input is a position
  block.InputPort(2).Dimensions = 1;
  %
  % Register block methods
  block.RegBlockMethod('Start',   @Start);
  block.RegBlockMethod('Outputs', @Output);
  %
  % To work in external mode
  block.SetSimViewingDevice(true);
end
%
% Called when the simulation starts.
function Start(block)
  %
  % Check to see if we already have an instance of CartPendulum
  ud = get_param(block.BlockHandle,'UserData');
  if isempty(ud)
    vis = [];
  else
    vis = ud.vis;
  end
  %
  % If not, create one
  if isempty(vis) || ~isa(vis,'CartPendulum') || ~vis.isAlive
    vis = CartPendulum();
  else
    %vis.clearPoints();
  end
  ud.vis = vis;
  %
  % Save it in UserData
  set_param(block.BlockHandle,'UserData',ud);
end
%
% Called when the simulation time changes.
function Output(block)
  if block.IsMajorTimeStep
    % Every time step, call setAngles
    ud = get_param(block.BlockHandle,'UserData');
    vis = ud.vis;
    if isempty(vis) || ~isa(vis,'CartPendulum') || ~vis.isAlive
      return;
    end
    vis.setAnglePosition(block.InputPort(1).Data(1), ...
                  block.InputPort(2).Data(1));
  end
end