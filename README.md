# Pipelined RISC-V CPU

This is a project to implement a pipelined RISC-V CPU core.

## Implementation Checklist

- [x] Register File
- [x] Instruction Fetch (IF)
- [x] Static Branch Predictor
- [x] Instruction Buffer (Might need to rewrite so its In order, and just have reservation stations)
- [ ] Instruction Decoder/Dispatcher
- [ ] Scoreboard
- [ ] Static Branch Predictor
- [ ] ROB

## Directory Structure

```
/
├── Makefile
├── src/
└── tb/
```


Future me notes. The decoder/dispatcher only send the pop signal when it already issued the instruction. So expect that the entry is already popped next right when the pop instruction is sent. But still, WIP