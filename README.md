# Description

Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip.

The Gossip algorithm: 

• Starting: A participant(actor) it told/sent a roumor(fact) by the main process

• Step: Each actor selects a random neighboor and tells it the roumor

• Termination: Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, you can select other values).

Push-Sum algorithm

• State: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if you so desire) and w = 1

• Starting: Ask one of the actors to start from the main process.

• Receive: Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding values. Upon receive, each actor selects a random neighbour and sends it a message.

• Send: When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message. 

• Sum estimate: At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.

• Termination: If an actors ratio s/w did not change more than 10^-10 in 3 consecutive rounds the actor terminates.

The actual network topology plays a critical role in the dissemination speed of Gossip protocols. As part of this project you have to experiment with various topologies. The topology determines who is considered a neighboor in the above algorithms.

• Full Network Every actor is a neighboor of all other actors. That is, every actor can talk directly to any other actor.

• 2D Grid Actors form a 2D grid. The actors can only talk to the grid neigboors.

• Line: Actors are arranged in a line. Each actor has only 2 neighboors (one left and one right, unless you are the first or last actor).

• Imperfect 2D Grid Grid arrangement but one random other neighboor is selected from the list of all actors (4+1 neighboors).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `project2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:project2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/project2](https://hexdocs.pm/project2).

