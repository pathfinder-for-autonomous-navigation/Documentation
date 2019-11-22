Serializers
===========

Serializers are the workhorse unit of telemetry processing. Each state field
that's readable or writable from the ground houses an instance of a serializer,
which can be used to convert the value of the state field to/from a bitstream
representation.

You read that right: I said `bitstream` representation. Due to the limited 70-byte
downlink packet size, PAN serializers take compression to an extreme degree and
squeeze every available bit out of the bandwidth. This is achieved by realizing that
fields on the spacecraft have a limited range of values, or have a limited range of
resolution that we care about on the ground. Using this realization, we can specify
a fixed-point scheme for compressing state fields at compile time.

As an example, suppose we have an unsigned integer ``x`` representing the state of a state machine that
has 11 total states. Since 11 is less than 16, note that we only need four bits to actually represent
the value of the state field. So a serializer for ``x`` would compress `x` down to 4 bits, rather than
the 32 bits that it would usually take, or the 8 bits that it would take if we naively reduced `x` 
down to an unsigned character. Using schemes like this all across our spacecraft, we've found that
compressing at the bit level reduces our telemetry size by up to 60%.

- ``serialize``
- ``deserialize``
- ``get_bit_array``
- ``set_bit_array``
- ``print``

