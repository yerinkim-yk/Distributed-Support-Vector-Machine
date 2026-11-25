%data
[x,y] = generate_data(20);

%%
%Blended Dynamics - Data 하나씩을 가지는 경우
trajectory = 0;
verbose = 1;

%Problem Setting
time = 20;
dt = 0.0001;
k1 = 1000;
k2 = 1000;
N = size(x,1); %Agent 수
n = 2; %feature 수

%Make agents
agents = [];
for i = 1:N
    agents = [agents; Agent(x(i,:), y(i))];
end

%Adjacency matrix
A = make_adjacency_matrix(N);

%%
%Calculation
if trajectory
    t_w = [];
    t_b = [];
    t_z = [];
    t_alpha = [];
end
for t = 0:dt:time-dt
   agents = blended_dynamics_of_w(agents, A, N, k2, dt);
   agents = blended_dynamics_of_b(agents, A, N, k2, dt);
   agents = blended_dynamics_of_alpha(agents, A, N, k1, dt);
   if trajectory && mod(t,0.1) == 0
       [t_w, t_b, t_z, t_alpha] = add_trajectory(agents, t_w, t_b, t_z, t_alpha);
   end
   if verbose && mod(t,10)==0
       t
   end
end

%Plot trajectory
if trajectory
    f3 = figure;
    plot_blended_dynamics(N,t_z, time);
    title('z');
    f4 = figure;
    plot_blended_dynamics(N,t_alpha, time);
    title('alpha');
end

%Plot 2d svm result
f5 = figure;
subplot(1,2,2);
plot_2d_svm_result(agents, x, y, N);
title("k = "+k1);

k1=300;
k2=300;
for t = 0:dt:time-dt
   agents = blended_dynamics_of_w(agents, A, N, k2, dt);
   agents = blended_dynamics_of_b(agents, A, N, k2, dt);
   agents = blended_dynamics_of_alpha(agents, A, N, k1, dt);
   if trajectory && mod(t,0.1) == 0
       [t_w, t_b, t_z, t_alpha] = add_trajectory(agents, t_w, t_b, t_z, t_alpha);
   end
   if verbose && mod(t,10)==0
       t
   end
end

subplot(1,2,1);
plot_2d_svm_result(agents, x, y, N);
title("k = "+k1);


%%
%functions
function [cvx_optval, a] = dual_opt_val(x,y)
    K = x*x';
    cvx_begin
        variables a(size(x,1)) t(size(x,1),size(x,1))
        minimize -sum(a)+0.5*quad_form(y.*a,K)
        subject to
            a >= 0;
            y'*a == 0;
    cvx_end
end

function plot_2d_svm_result(agents, x, y, N)
    %data plot
    for i = 1:size(x,1)
        if y(i) == 1
            p = plot(x(i,1),x(i,2),'o');
            p.MarkerFaceColor = [1 0.5 0];
            p.MarkerEdgeColor = [1 0.5 0];
        else
            p = plot(x(i,1),x(i,2),'^');
            p.MarkerFaceColor = [0 0.5 1];
            p.MarkerEdgeColor = [0 0.5 1];
        end
        hold on;
    end
    %result of blended dynamics
    x1 = -5:5;
    for i = 1:N
        x2 = -agents(i).w(1)/agents(i).w(2)*x1 - agents(i).b/agents(i).w(2);
        p=plot(x1,x2,'-');
        p.LineWidth = 1.7;
        hold on;
    end

    %result of cvx
    [~, a] = dual_opt_val(x,y);
    w_ans = zeros(size(x,2),1);
    for i = 1:N
        w_ans = w_ans + (a(i)*y(i)*x(i,:))';
    end
    [~, i] = max(a);
    b_ans = y(i) - w_ans'*x(i,:)';
    x2_ans = -w_ans(1)/w_ans(2)*x1-b_ans/w_ans(2);
    p = plot(x1,x2_ans,'k--');
    p.LineWidth = 3;
    hold on;

    x2_pos = (-w_ans(1)*x1-b_ans+1)/w_ans(2);
    p=plot(x1,x2_pos,'k--');
    p.LineWidth=1;

    x2_neg = (-w_ans(1)*x1-b_ans-1)/w_ans(2);
    p=plot(x1,x2_neg,'k--');
    p.LineWidth=1;

    xlabel('x_1');
    ylabel('x_2');
    axis([-5,5,-5,5]);
end

function plot_blended_dynamics(N,trajectory, time)
    dt= 0.1;
    t = 0:dt:time-dt;
    m = size(trajectory,1)/N;
    for i = 1:m
        subplot(m,1,i);
        for j = 1:N
            plot(t, trajectory(m*(j-1)+i,:));
            hold on;
        end
    end
end

%Blended dynamics of w
function agents = blended_dynamics_of_w(agents, A, N, k, dt)
    for i = 1:N
        w_dot = agents(i).calculate_w_dot(N);
        for j = 1:N
            w_dot = w_dot + k*A(i,j)*(agents(j).w-agents(i).w);
        end
        agents(i).w = agents(i).w + dt*w_dot;
    end
end

%Blended dynamics of b
function agents = blended_dynamics_of_b(agents, A, N, k, dt)
    for i = 1:N
        b_dot = agents(i).calculate_b_dot();
        for j = 1:N
            b_dot = b_dot + k*A(i,j)*(agents(j).b-agents(i).b);
        end
        agents(i).b = agents(i).b + dt*b_dot;
    end
end

%Blended_dynamics_of_alpha
function agents = blended_dynamics_of_alpha(agents, A, N, k, dt)
    for i = 1:N
        z_dot = agents(i).calculate_z_dot(N);
        for j = 1:N
            z_dot = z_dot + k*A(i,j)*(agents(j).z-agents(i).z);
        end
        agents(i).z = agents(i).z + dt*z_dot;
        agents(i).alpha = agents(i).update_alpha();
    end
end

%Make Adjacency Matrix
function A = make_adjacency_matrix(N)
    A = zeros(N,N);
    for i = 1:N
        for t = 1:2
            j = randi(N);
            while j == i
                j = randi(N);
            end
            A(i,j) = 1;
            A(j,i) = 1;
        end
    end
end

%Generate data
function [x,y] = generate_data(n)
   w = random('Uniform',-1,1,2,1);
   b = random('Uniform',-0.5,0.5);
   x = random('Uniform',-5,5,n,2);
   y = zeros(n,1);
   for i = 1:n
       while abs(w'*x(i,:)'+b)<0.5
           x(i,:) = random('Uniform',-5,5,1,2);
       end
       if w'*x(i,:)'+b > 0
           y(i) = 1;
       else
           y(i) = -1;
       end
   end
end

function [t_w, t_b, t_z, t_alpha] = add_trajectory(agents, t_w, t_b, t_z, t_alpha)
       w = [];
       b = [];
       z = [];
       alpha = [];
       N = size(agents,1);
       for i = 1:N
           w = [w; agents(i).w];
           b = [b; agents(i).b];
           z = [z; agents(i).z];
           alpha = [alpha; agents(i).alpha];
       end
       t_w = [t_w, w];
       t_b = [t_b, b];
       t_z = [t_z, z];
       t_alpha = [t_alpha, alpha];
end
