# Debug Log — PROJECT_IP-Timer (Standard Level)

- This document records how real issues were found and resolved during the RTL design and verification of the Timer IP.
- Author: Trần Hồ Khánh Tân.
- Period: 15/06/2026 - 23/06/2026
---

## Bug #1 — Wire width mismatch in `apb_slave.v`

**Phase:** RTL bring-up, before running the first testcase.

**Symptom:** RTL compilation reported errors/warnings about a width mismatch between a declared signal and the signal assigned to it in `apb_slave.v`.

**Cause:** A wire was declared with a width that did not match the signal assigned to it. Here, `rdata` was declared as [31:0] while `tim_prdata` was declared as only [30:0], so the assignment was invalid and caused a compile error.

**Fix:** Corrected the wire width declarations to match the corresponding interface signals.

**Verification:** Recompiled the entire RTL and confirmed there were no more width mismatch warnings/errors before running testcases.

---

## Bug #2 — Orphan wires in `timer_top.v`

**Phase:** RTL bring-up, while connecting the submodules in `timer_top`.

**Symptom:** Some wires were declared in `timer_top.v` but never connected (port-mapped) to any submodule instance, a sign of leftover declarations from repeated code edits.

**Cause:** While restructuring the connections between the submodules (`apb_slave`, `register`, `counter_control`, `counter`, `interrupt`), some temporary wires were left behind after the wiring changed, and others were declared twice by mistake. For example, `set`/`int_st` and `clear`/`int_clear` were each declared twice because the signals coming from `interrupt` were confused, leaving redundant wires.

**Fix:** Reviewed the full wire list in `timer_top.v` and removed unused declarations, making sure every wire has at least one driver and one load.

**Verification:** Recompiled and checked the compile warnings to confirm no redundant or unconnected wires remained.

---

## Bug #3 — RTL logic error found by testcase `reg_chk_all.v`

**Phase:** After a clean compile with no warnings, testcases were run one by one to look for logic errors. The run stopped at `reg_chk_all.v`.

**Symptom:** The testcase wrote suitable values to the TCR register (12'h00) to start the counter, but the count came out in the wrong order: instead of 64'h0000_0000_0000_0001, it produced 64'h0000_0001_0000_0000. This is a classic bit-ordering bug in concatenation. It is easy to make when joining several registers into a wider vector, and hard to spot by skimming the code because the compile passes without any warning.

**Cause:** The counter value `cnt` is stored in two registers, TDR0 (lower 32 bits) and TDR1 (upper 32 bits), and should be assigned as `cnt = {TDR1, TDR0}`. The two registers were swapped, so `cnt` was assigned as `{TDR0, TDR1}`.

**Fix:** Checked the register order in the `cnt` assignment and swapped the two registers back.

**Verification:** Re-ran the testcase. The counter now works correctly, and `cnt` holds the right value in the right order.

---

## Bug #4 — RTL logic error found by testcase `interrupt_chk.v`

**Phase:** After a clean compile with no warnings, testcases were run one by one to look for logic errors. The run stopped at `interrupt_chk.v`.

**Symptom:** The testcase wrote suitable values to the TCR register (12'h00) so the counter ran for 3 clock cycles and then stopped (`cnt` = 3). It then set the compare value (registers TCMP0 and TCMP1) equal to `cnt` to trigger the interrupt signal `tim_int`. However, `tim_int` was never generated.

**Cause:** The compare value `tcmp` is stored in two registers, TCMP0 (lower 32 bits) and TCMP1 (upper 32 bits), and should be assigned as `tcmp = {tcmp1, tcmp0}`. It was assigned as `{tcmp0, tcmp1}` instead, so the comparison was wrong and `tim_int` was not generated.

**Fix:** Swapped the register positions in `tcmp` back to the correct order.

**Verification:** Re-ran the testcase and `tim_int` is now generated.

---

## Bug #5 — RTL logic error found by testcase `counter_control.v`

**Phase:** After a clean compile with no warnings, testcases were run one by one to look for logic errors. The run stopped at `counter_control.v`.

**Symptom:** The testcase wrote different `div_val` values into the TCR register (12'h00) to check the counter speed. The counter speed depends on `div_val`: for example, with `div_val` = 4'b0010, the internal counter `cnt_int` counts 4 clock cycles before the main counter increments by 1 (using `limit = ((8'h1 << div_val) - 1)`), then `cnt_int` resets to 0. The returned `cnt` value was wrong and did not match the design spec, so the checkers reported FAILED.

**Cause:** The `limit` formula was wrong. It was written as `limit = (8'h1 << div_val)`, missing the "- 1", which caused an off-by-one error.

**Fix:** Corrected the formula by adding "- 1".

**Verification:** Re-ran the testcase and tried many different `div_val` values to confirm the counter no longer has any counting error.

---

## Bug #6 — FEC miss in `apb_slave.v`: combination `psel=0 & penable=1` not hit

**Phase:** Coverage closure, after all functional testcases had passed.

**Symptom:** Expression Coverage of `apb_slave.v` reached only 93.75% (15/16 bins). The QuestaSim FEC (Focused Expression Coverage) report showed that at line 30 (`valid_access = tim_psel & tim_penable`), the input term `tim_psel` never hit the value `_0` in the required combination.

**Cause:** Instead of blindly writing more tests to force this combination, I analyzed it against the APB protocol. PENABLE may only be asserted for exactly one cycle after PSEL has gone high in the previous cycle, so `psel=0 & penable=1` is a protocol-violating state. It cannot occur as long as the driver (the `apb_write`/`apb_read` tasks in the testbench) follows the standard APB sequence. Conclusion: this is not a missing test, but a coverage bin that is structurally unreachable.

**Resolution:** Excluded this FEC row in the Coverage GUI (`Exclude Selection FEC`) with a comment explaining the protocol reason, to be included in the Coverage Exclusion Justification Table.

---

## Bug #7 — Branch miss in `register.v`: default case in `case(addr)` not hit

**Phase:** Coverage closure.

**Symptom:** Branch Coverage of `register.v` reached 96.15% (25/26) and Statement Coverage 97.43% (38/39). The miss is at line 55: `default: rdata = 32'h0;`.

**Cause:** Tracing back to the upper level (`apb_slave.v`) confirmed that `addr_valid` (line 31) treats `tim_paddr` as valid only when it matches exactly one of the 8 offsets (TCR/TDR0/TDR1/TCMP0/TCMP1/TIER/TISR/THCSR), and `rd_en` is asserted only when `addr_valid=1`. The case statement in `register.v` lists exactly these 8 values, so the `default` branch could only run if the upper-level address decode were wrong, which cannot happen in a correct design.

**Resolution:** Excluded both Branch and Statement coverage at line 55, noting that the address is already validated in `apb_slave` before it reaches `register`.

---
