====================
Telemetry Management
====================

The flight software needs to be able to both send its data to the ground and
have the capacity to accept commands from the ground. These tasks are handled
by the ``DownlinkProducer`` and ``UplinkConsumer`` control task, respectively,
which are described in more detail below.

Downlink Producer
=================
The downlink producer has the responsibility of managing the selection of state fields that
are downlinked to the ground. This is important since the downlink bandwidth is extremely limited,
down to a size of at most 70 bytes per downlink packet, with low probability of communication in general.

Here are some definitions we lay down to begin with:

- A ``downlink snapshot`` represents a snapshot of all of the data we would ever want from the spacecraft
  at a particular time.
- A ``downlink frame`` is a collection of 70-byte ``downlink packets`` which contain the data of a snapshot.

To downlink fields in a manageable way, the state fields are partitioned into groups called `flows`.
The fields in a flow are all transmitted together. This allows telemetry design to be thought in
terms of "which flows do I want to send down?", as opposed to "which fields do I want to send down?",
which makes management much easier.

Each flow has the following priorities: a `flow ID` that's unique to each flow, and a `flow priority`,
ranging from -1 to the total number of flows. A flow priority of -1 means that the flow is inactive
and not downlinked to the ground; a flow priority of 0 is the highest priority, and a flow priority of
``number of flows - 1`` is a flow with the lowest priority.

When downlinking, the downlink producer arranges the active flows by priority in-place, and then
writes each flow to the downlink frame in order. Writing a flow to the packet means writing the flow's ID,
and then writing each of the serialized fields in the flow.

Since the set of flows might require more than 1 downlink packet, we mark each packet with a header bit 
(1 or 0) that indicates if the packet is the first packet in the downlink frame. This header bit is inserted 
while the flows are being written to the downlink frame; if a flow is going to cause the data to overflow
into a new downlink packet, a header bit is written first, and then the remainder of the flow is written.
The effect of this scheme is that if the header bits are removed from the downlink frame, the resulting data
is a continuous stream of flows.

Uplink Consumer
===============
In our system design, the ground is only allowed to send commands in the form of state
field updates: behavior that the ground wants to modify has to be attached to a state field
that can control that behavior. For example, one common ground task is to change
the :doc:`../mission_manager` state, which it can easily do by just setting the
value of the mission state.

TODO
