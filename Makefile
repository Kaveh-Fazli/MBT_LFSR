

.PHONY: comp
comp:
	iverilog  -o lfsr.sim ./mbt_lfsr.v ./mbt_lfsr_tb.v


.PHONY: sim
sim:
	vvp ./lfsr.sim


.PHONY: wave
wave:
	gtkwave ./lfsr_wave.vcd


.PHONY: clean
clean:
	rm -f lfsr.sim lfsr_wave.vcd