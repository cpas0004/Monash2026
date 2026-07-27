%
% File: CartPendulum.m
%
% https://blogs.mathworks.com/graphics/2014/10/21/double_pendulum/

classdef CartPendulum < handle
  % A class for implementing a MATLAB Graphics visualization of the
  % Simulink model of the cart-pendulum system.
  %
  properties (SetAccess=private)
    Arm    = gobjects(1,1);
    Cart    = gobjects(1,1);
    Length = 1;
    Angle  = 0;
    Position = 0;
    BallWidth = .25;
    ArmWidth = .125;
    CartWidth = 1;
    CartHeight = 0.25;
  end
  %
  % Public methods
  methods
    function obj = CartPendulum()
      obj.createGeometry();
      obj.updateTransforms();
    end
    function setAnglePosition(obj, a, p)
    % Call this to change the angles and position
      obj.Angle = a;
      obj.Position = p;
      obj.updateTransforms();
    end
    function r = isAlive(obj)
    % Call this to check whether the figure window is still alive.
      r = isvalid(obj) && isvalid(obj.Arm) && isvalid(obj.Cart);
    end
  end
  %
  % Private methods
  methods (Access=private)
    function createArm(obj, p, len, col)
    % Creates the geometry for one pendulum. This is basically a copy
    % of the function we created earlier.
      w = obj.ArmWidth;
      l = rectangle('Parent',p);
      l.Position = [-w/2, -len, w, len];
      l.FaceColor = col;
      l.EdgeColor = 'none';
      c = rectangle('Parent',p);
      r = obj.BallWidth;
      c.Position = [-r/2, -(len+r/2), r, r];
      c.Curvature = [1 1];
      c.EdgeColor = 'none';
      c.FaceColor = col;
    end
    function createCart(obj, p, col)
        w = obj.CartWidth;
        h = obj.CartHeight;
        l = rectangle('Parent',p);
        l.Position = [-w/2,-h/2,w,h];
        l.FaceColor = col;
        l.EdgeColor = 'none';
    end
%     function addTracePoints(obj)
%     % Adds the current end points of the two pendulums to the traces.
%       a1 = obj.Angles(1);
%       a2 = obj.Angles(2);
%       l1 = obj.Lengths(1);
%       l2 = obj.Lengths(2);
%       x1 =  l1*sin(a1);
%       y1 = -l1*cos(a1);
%       x2 = x1 + l2*sin(a1+a2);
%       y2 = y1 - l2*cos(a1+a2);
%       obj.Traces(1).addpoints(x1,y1);
%       obj.Traces(2).addpoints(x2,y2);
%     end
    function createGeometry(obj)
    % Creates all of the graphics objects for the visualization.
      col1 = 'red';
      col2 = 'green';
      %col3 = 'blue';
      fig = figure;
      ax = axes('Parent',fig);
      % Create the traces
      %obj.Traces(1) = animatedline('Parent', ax, 'Color', col1);
      %obj.Traces(2) = animatedline('Parent', ax, 'Color', col2);
      % Create the transforms
      obj.Arm = hgtransform('Parent', ax);
      obj.Cart = hgtransform('Parent', ax);
      % Create the arm
      createArm(obj, obj.Arm, obj.Length, col1);
      createCart(obj, obj.Cart, col2);
      %createArm(obj, obj.Arms(2), obj.Lengths(2), col2);
      % Create a blue circle at the origin.
      %c = rectangle('Parent',ax);
      %r = obj.BallWidth;
      %c.Position = [-r/2, -r/2, r, r];
      %c.Curvature = [1 1];
      %c.EdgeColor = 'none';
      %c.FaceColor = col3;
      % Initialize the axes.
      maxr = (obj.Length)+0.1;
      maxp = 2; % maximum xrange
      ax.DataAspectRatio = [1 1 1];
      ax.XLim = [-(maxp) maxp];
      ax.YLim = [-maxr maxr];
      grid(ax,'on');
      ax.SortMethod = 'childorder';
    end
    function updateTransforms(obj)
    % Updates the transform matrices.
      a = obj.Angle;
      p = obj.Position;
      %a2 = obj.Angles(2);
      offset = [p 0 0];
      obj.Arm.Matrix = makehgtform('translate',offset,'zrotate', a);
      obj.Cart.Matrix = makehgtform('translate',offset);
      drawnow;
      %obj.Arms(2).Matrix = makehgtform('translate', offset, ...
       %                                'zrotate', a2);
    end
  end
end