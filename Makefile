# --- Configuration ---
YOSYS      = yosys
SRC_DIR    = src/core
synth_DIR  = synthesis
BUILD_DIR  = build

TB_DIR     = tb/core
# Default module to synthesize if none is provided via command line
MODULE    ?= RegisterFile

IVERILOG   = iverilog
VVP        = vvp
GTKWAVE    = gtkwave

NEXTPNR    = nextpnr-ice40
PCF        = pins.pcf
DEVICE     = up5k
PACKAGE    = sg48

# --- Synthesis Target ---
synth:
	@mkdir -p $(synth_DIR)
	@echo "--- Synthesizing Module: $(MODULE) ---"
	@echo "read_verilog -sv $(SRC_DIR)/$(MODULE).sv" > $(synth_DIR)/$(MODULE).ys
	@echo "hierarchy -top $(MODULE)" >> $(synth_DIR)/$(MODULE).ys
	@echo "proc; opt; fsm; opt" >> $(synth_DIR)/$(MODULE).ys
	@echo "memory_dff; memory_collect" >> $(synth_DIR)/$(MODULE).ys
	@echo "memory_bram -rules +/ice40/brams.txt; memory_map" >> $(synth_DIR)/$(MODULE).ys
	@echo "synth_ice40 -top $(MODULE) -json $(synth_DIR)/$(MODULE).json" >> $(synth_DIR)/$(MODULE).ys
	@echo "stat" >> $(synth_DIR)/$(MODULE).ys
	$(YOSYS) -s $(synth_DIR)/$(MODULE).ys

# --- Testbench Target ---
test:
	@mkdir -p $(BUILD_DIR)
	@echo "--- Simulating Module: $(MODULE) ---"
	$(IVERILOG) -g2012 -o $(BUILD_DIR)/$(MODULE)_sim.out $(SRC_DIR)/$(MODULE).sv $(TB_DIR)/tb_$(MODULE).sv $(SRC_DIR)/BranchPredictor.sv
	$(VVP) $(BUILD_DIR)/$(MODULE)_sim.out
	@echo "To view waves: $(GTKWAVE) dump.vcd"

pnr:
	@mkdir -p $(synth_DIR)
	@echo "--- Synth + PnR Module: $(MODULE) ---"

	@echo "read_verilog -sv src/core/*.sv" > $(synth_DIR)/$(MODULE)_pnr.ys
	@echo "hierarchy -top $(MODULE)" >> $(synth_DIR)/$(MODULE)_pnr.ys
	@echo "proc; opt; fsm; opt" >> $(synth_DIR)/$(MODULE)_pnr.ys
	@echo "memory_dff; memory_collect" >> $(synth_DIR)/$(MODULE)_pnr.ys
	@echo "memory_bram -rules +/ice40/brams.txt; memory_map" >> $(synth_DIR)/$(MODULE)_pnr.ys
	@echo "synth_ice40 -top $(MODULE) -json $(synth_DIR)/$(MODULE).json" >> $(synth_DIR)/$(MODULE)_pnr.ys

	$(YOSYS) -s $(synth_DIR)/$(MODULE)_pnr.ys

	@echo "--- Running nextpnr ---"
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) \
		--json $(synth_DIR)/$(MODULE).json \
		--report $(synth_DIR)/$(MODULE)_util.txt

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(synth_DIR)

.PHONY: synth test clean