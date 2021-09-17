# try to code snevo in jl

using Agents, Random
using InteractiveDynamics
using CairoMakie

mutable struct AgentFood <: AbstractAgent
    id::Int
    pos::NTuple{2,Float64}
    vel::NTuple{2,Float64}
    type::Symbol # :food or :agent
    energy::Float64
end

# define different agent class
Food(id, pos, vel) = AgentFood(id, pos, vel, :food, 0.0)
Agent(id, pos, vel) = AgentFood(id, pos, vel, :agent, 0.0)

# define model
function basic_model(; 
    popsize = 500,
    nfood = 500,
    delta_energy = 4,
    speed = 0.02,
    dt = 1.0
)   
    # make landscape
    landscape = ContinuousSpace((10, 10), 0.02, periodic=true)
    
    # define model
    model = ABM(AgentFood, landscape, properties = Dict(:dt => 1.0), 
        rng = MersenneTwister(42))
    
    # add agents
    ind = 0
    for _ in 1:popsize
        ind += 1
        pos = Tuple(rand(model.rng, 2))
        vel = sincos(2π * rand(model.rng)) .* speed
        agent_ = Agent(ind, pos, vel)
        add_agent!(agent_, model)
    end
    # add foods
    for ind in 1:nfood
        ind += 1
        pos = Tuple(rand(model.rng, 2))
        vel = (0.0, 0.0)
        food_ = Food(ind, pos, vel)
        add_agent!(food_, model)
    end
    return model
end

# function to move individuals
function agent_step!(agent, model)
    move_agent!(agent, model, model.dt)
end

# function to forage
function agent_forage!(model, distance = 0.01)
    for (a1, a2) in interacting_pairs(model, distance, :nearest)
        # check if one is a food item
        count(a.type == :food for a in (a1, a2)) != 1 && return
        consumer, resource = a1.type == :agent ? (a1, a2) : (a2, a1)
        consumer.energy += 1.0
    end
end

# colour by type
model_colors(a) = a.type == :food ? "green" : a.type == :agent && a.energy > 0.0 ? "blue" : "red"

model = basic_model(nfood = 150, popsize = 400)

fig, abmstepper = abm_plot(model; ac = model_colors)
fig # display figure

abm_video(
    "pathomove.mp4",
    model,
    agent_step!, 
    agent_forage!;
    ac = model_colors,
    title = "basic pathomove",
    frames = 150,
    spf = 1,
    framerate = 20,
)
