function set=pareto_frontier(ascore,tscore)

set=[];
for i = 1:length(ascore)
    if ~dominated(ascore(i,4),tscore(i,4),ascore,tscore)
        set=[set,i];
    end
end
    
end

%% define function
function result=dominated(a,t,ascore,tscore)
result=0;
    for i = 1:length(ascore)
        if a>ascore(i,4) && t>tscore(i,4)
            result=1;
            break;
        end
    end
end