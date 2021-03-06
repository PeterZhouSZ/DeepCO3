classdef AffinityLoss < dagnn.Loss
    properties
        Alpha = 1;
    end
    
    methods
        function outputs = forward(obj, inputs, params)
            BatchSize = size(inputs{1}, 4);
            outputs{1} = mean(inputs{1}(:) .* (1-inputs{2}(:))) + obj.Alpha * mean(inputs{3}(:) .* inputs{2}(:));
            n = obj.numAveraged;
            m = n + BatchSize;
            obj.average = (n * obj.average + double(gather(outputs{1} * BatchSize))) / m ;
            obj.numAveraged = m;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            [W,H,C,~] = size(inputs{1});
            NumSamples = W * H * C;
            derInputs{1} = derOutputs{1} * (1-inputs{2}) / NumSamples;
            derInputs{2} = derOutputs{1} * (-inputs{1} + obj.Alpha * inputs{3})/ NumSamples;
            derInputs{3} = derOutputs{1} * obj.Alpha * inputs{2} / NumSamples;
            derParams = {};
        end
        
        
        function reset(obj)
            obj.average = 0 ;
            obj.numAveraged = 0 ;
        end
        function obj = AffinityLoss(varargin)
            obj.load(varargin) ;
        end
    end
end
                           