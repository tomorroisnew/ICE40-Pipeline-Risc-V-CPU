# Pipelined RISC-V CPU

This is a project to implement a pipelined RISC-V CPU core.

## Implementation Checklist

- [x] Register File
- [x] Instruction Fetch (IF)
- [x] Static Branch Predictor
- [x] Instruction Buffer (Might need to rewrite so its In order, and just have reservation stations)
- [ ] Reserve statations
- [ ] Execution Units
  - [ ] SIU0
  - [ ] SIU1
  - [ ] Branch Unit
  - [ ] Control Unit
  - [ ] FPU
  - [ ] LSU
- [ ] Instruction Decoder/Dispatcher
- [ ] Scoreboard
- [ ] ROB
- [ ] CACHE
  - [ ] I-CACHE
  - [ ] D-CACHE
- [ ] Memory Mapper  

## Directory Structure

```
/
├── Makefile
├── src/
└── tb/
```


Future me notes. The decoder/dispatcher only send the pop signal when it already issued the instruction. So expect that the entry is already popped next right when the pop instruction is sent. But still, WIP
