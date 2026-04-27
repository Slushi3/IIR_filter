## How it works

This project implements a 1st-order IIR (Infinite Impulse Response) low-pass filter
using an exponential moving average algorithm. 
An 11-bit internal accumulator holds the scaled filter state, with the top 8 bits
output as the filtered result. 
The smoothing factor alpha = 1/8 (ALPHA = 3), meaning each output sample moves
1/8th of the remaining distance toward the input. This gives strong low-pass
smoothing, rejecting high-frequency noise and sudden jumps in the input signal.

## How to test

1. Apply an 8-bit unsigned sample to `ui[7:0]` on each rising clock edge.
2. Read the filtered 8-bit output from `uo[7:0]`.
3. Reset the filter at any time by pulling `rst_n` low — this clears the
   accumulator to zero.

**Step response test:** Hold the input at a constant value (e.g. 200) and observe
`uo[7:0]` gradually rising toward that value over approximately 30-40 clock cycles,
confirming the exponential settling behaviour.

**Noise rejection test:** Apply a rapidly alternating input (e.g. toggling between
0 and 255 every cycle) and observe that the output settles to a stable midpoint
value (~127), confirming high-frequency noise is being filtered out.

To tune the cutoff frequency, change `localparam ALPHA` in `project.v`:
- ALPHA = 1 → light smoothing (higher cutoff)
- ALPHA = 3 → strong smoothing (lower cutoff, default)
- ALPHA = 4 → very heavy smoothing

## External hardware

None. The filter is entirely self-contained. 

