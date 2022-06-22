
using Random
using Distributions
using NearestNeighbors

mutable struct agent
    id::Int16
    pos::NTuple{2, Float64} # where the agent is
    sA::Float64 # agent preference for other agents
end

mutable struct resources
    n_food::Int64
    pos::Array{NTuple{2, Float64}, n_food}
end

# a cauchy distribution for sampling movement distances
dist_cauchy = Cauchy(0.0, 0.01)

# some methods for the agent to get info
get_id(a::agent) = a.id
get_pos(a::agent) = a.pos
# combined get infor function
get_info(a::agent) = println("This is agent ", get_id(a), " at ", get_pos(a))

# make ana agent
agent_1 = agent(1, Tuple(rand(Float64, 2)), rand() )

# print info
get_info(agent_1)

# define a move method
function move_agent!(a::agent)
    distances = rand(dist_cauchy, 2)
    angle = (rand(Uniform(), 1))[1]
    new_x = (a.pos[1] + (distances[1] * cospi(angle)))
    new_y = (a.pos[2] + (distances[2] * sinpi(angle)))
    a.pos = (new_x, new_y)
end

move_agent!(agent_1)

for i in 1:100
    # println("t = ", i)
    move_agent!(agent_1)
    println(get_pos(agent_1))
end