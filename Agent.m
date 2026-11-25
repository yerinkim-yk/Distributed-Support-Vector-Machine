classdef Agent

    properties
        num_of_feature
        num_of_data
        w
        b
        alpha
        z
        x
        y
    end

    methods
        function agent = Agent(x,y)
            agent.num_of_feature = size(x,2);
            agent.num_of_data = size(x,1);
            agent.w = random('Uniform', -1,1, agent.num_of_feature,1);
            agent.b = random('Uniform', -1,1);
            agent.z = random('Uniform', -1,1);
            agent.alpha = random('Uniform', -1,1, agent.num_of_data,1);
            agent.x = x';
            agent.y = y;
        end

        function w_dot = calculate_w_dot(agent, N)
            w_dot = -agent.w + N * agent.alpha * agent.y * agent.x;
        end

        function b_dot = calculate_b_dot(agent)
            b_dot = agent.alpha*(-agent.b + agent.y - agent.w'*agent.x);
        end

        function z_dot = calculate_z_dot(agent, N)
            z_dot = N* agent.y* agent.calculate_theta(agent.z);
        end

        function alpha = update_alpha(agent)
            alpha = agent.calculate_theta(agent.z);
        end

        function value = calculate_theta(agent, z)
            temp = (-z*agent.y+1-agent.y*agent.x'*(agent.w-agent.alpha*agent.y*agent.x))/(agent.x'*agent.x);
            value = max(0, temp);
        end
    end
end
