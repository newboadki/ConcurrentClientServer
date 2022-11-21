#  Concurrent Client-Server Queues

## Overview
- This projects uses a simple load-balancing problem to implement the solution using Swift Concurrency, GCD and OperationQueues. The user interface is implemented with SwiftUI.

## Technical Description
- There are several types of requests that can be processed by different services. 
- A _LoadBalancer_ protocol and its concrete implementations _CurrentMinLoadBalancer_ and _AsyncCurrentLoadBalancerProxy_ receive the requests and distribute them among the services. 
- GCD and OperationQueue based solutions can share the same load balancers. The async implementation needs to be separate because of the async requirements which can't be met by the synchronous counter parts.
- Cancellation is supported by all solutions: Swift Concurrency, GCD and OperationQueues.
- Global actors are used to synchronize access between services and the load balancer, so that decisions about which service to use are based on the latest data available.




 
## User Interface:
In order to animate views in and out of the queue we need three sets of views:
- Dequeued Items
- Enqueued items (the queue itself)
- Items that have never been enqueued

The presenter class listens to updates from a load publisher. When a service's load changes, the presenter computes the new states of the items, which can be _dequeued_, _enqueued_, or _none_. These helps SwiftUI move and animate the views appropriately. 

