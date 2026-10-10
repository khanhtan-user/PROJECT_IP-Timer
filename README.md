# PROJECT_IP-Timer (Standard)
- This is a standard Timer IP Core that supports configuration through the APB bus (APB Slave Interface), can generate interrupts, and counts clock pulses with high resolution.

<img width="504" height="291" alt="image" src="https://github.com/user-attachments/assets/5abafbbc-a18c-438f-9b9a-28b390003729" />


## 1. Project Overview & Status
* **Design Specification:** System architecture and detailed specification are available at: `docs/Design_Spec/Design_Spec.docx/`.
* **Project Timeline:** Stored in detail at: `report/time_line/time_line.xlsx/`.
* **Debugging process:** Stored in detail at: `docx/Debug_log.md/`.
  ### Repository Structure

```text
PROJECT_IP-Timer/
├── src/
│   ├── rtl/                  (timer_top.v and 5 submodules)
│   │   ├── timer_top.v
│   │   ├── apb_slave.v
│   │   ├── register.v
│   │   ├── counter_control.v
│   │   ├── counter.v
│   │   └── interrupt.v
│   ├── tb/                   (Top-level testbench)
│   │   ├── test_bench.v
│   │   ├── waveform.md
│   ├── sim/                  (Makefile and simulation run scripts)
│   │   ├── Makefile
|   |   ├── tb.f
|   |   ├── rtl.f
|   |   ├── run.csh
|   |   ├── run_test.v
│   │   ├── compile.f
│   │   ├── pat.list
│   │   └── report.csh
|   |  
│   └── testcases/            (5 testcase files, 30 test items in total)
│       ├── apb_basic_chk.v
│       ├── counter_control.v
│       ├── interrupt_chk.v
│       ├── no_stimulus_chk.v
│       └── reg_chk_all.v
|──docx/
|    |──Design_Spec/            ( Design_Spec.docx)
|    |──Verification_Plan/    ( Verification_Plan.docx)
│    └── Debug_log.md
├── report/
|   |──time_line/             (time_line.xlsx)
│   ├── Coverage/             ( Summary_Report.txt & Detail Report.txt)
│   └── Justification/        (Coverage Exclusion Justification Table .docx)
└── README.md
```

### 2. Design Hierarchy

The IP core is organized in a clean hierarchy, from the TOP module down to the corresponding submodules in the `rtl/` directory:

```text
timer_top.v (Top-level Module)
├── apb_slave.v          (APB Slave interface block)
├── register.v           (Configuration register set)
├── counter_control.v    (Control block & Prescaler clock divider)
├── counter.v            (64-bit up-counter core)
└── interrupt.v          (Interrupt management & generation block)
```
### 3. Functional Blocks

The system is designed with a hierarchical, modular architecture consisting of 5 core functional blocks that interact closely with one another:

* **APB Slave Interface (`apb_slave.v`):** 
  * Acts as the peripheral interface block.
  * Decodes the address (`paddr`) and captures the control signals (`psel`, `penable`, `pwrite`) from the APB Bus to generate internal read/write strobes (`wr_en`, `rd_en`).
  * Responds with the ready status (`pready`) and reports errors (`pslverr`) back to the system.

* **Register Block (`register.v`):**
  * Stores the IP's configuration, control, and status registers.
  * Updates register contents with write data (`wdata`) from the bus or with internal data from the counter/interrupt blocks, and drives read data (`rdata`) onto the APB Bus on request.
  * Provides configuration parameters (`div_val`, `timer_en`) to the counter control block.

* **Counter Control (`counter_control.v`):**
  * Serves as the intermediate control unit of the counting circuit.
  * Receives the clock divider configuration (`div_val`) and the run-enable status (`timer_en`) from the register block to determine when to activate the counter (`cnt_en`).
  * Ensures the counter runs in sync with the system clock or halts precisely according to the configuration.

* **Counter Core (`counter.v`):**
  * The core that performs time counting based on the enable signal (`cnt_en`).
  * Implements the accumulating count logic and detects counter overflow (`overflow`) when reaching a preset value or the bit-width limit.
  * Continuously feeds the current count value back to the register block so the user can read it.

* **Interrupt Block (`interrupt.v`):**
  * Manages the entire interrupt mechanism of the IP Core.
  * Receives the overflow signal (`overflow`) from the Counter block and combines it with the interrupt enable bit to drive the physical interrupt signal `tim_int` out to the system.
  * Holds the interrupt status flag in the register until it is validly cleared by W1C (Write 1 To Clear).
    
## 4. Signal Descriptions

Below are the detailed descriptions of the input/output signals (I/O Signals) for each functional submodule in the system. Click each module to view its signal table:

<details>
<summary><b> APB Slave Interface (apb_slave.v)</b></summary>

```text
+----------------+--------+--------+-------------------------------------------------------------+
| Signal name    | Dir.   | Width  | Description                                                 |
+----------------+--------+--------+-------------------------------------------------------------+
| tim_psel       | Input  | 1-bit  | APB Slave select signal from the APB Master                 |
| tim_pwrite     | Input  | 1-bit  | Transfer direction control (0: Read, 1: Write)              |
| tim_penable    | Input  | 1-bit  | Enables the Access phase of the APB bus                     |
| tim_paddr      | Input  | 12-bit | APB register address                                        |
| rdata          | Input  | 32-bit | Read data sent from the Register block to the APB Slave     |
| tim_pwdata     | Input  | 32-bit | Write data from the APB Master                              |
| wdata          | Output | 32-bit | Write data forwarded to the Register block                  |
| tim_prdata     | Output | 32-bit | Read data returned to the APB Master                        |
| addr           | Output | 12-bit | Internal address forwarded to the Register block            |
| wr_en          | Output | 1-bit  | Register write enable strobe                                |
| rd_en          | Output | 1-bit  | Register read enable strobe                                 |
| tim_pslverr    | Output | 1-bit  | APB error indication (always held at 0 in this design)      |
| pready         | Output | 1-bit  | Slave ready indication (always held at 1 in this design)    |
+----------------+--------+--------+-------------------------------------------------------------+
```

</details>

<details>
<summary><b> Register Block (register.v)</b></summary>
  
```text
+---------------+--------+--------+------------------------------------------------------------------+
| Signal name   | Dir.   | Width  | Description                                                      |
+---------------+--------+--------+------------------------------------------------------------------+
| sys_clk       | Input  | 1-bit  | System clock                                                     |
| sys_rst_n     | Input  | 1-bit  | Asynchronous reset, active low                                   |
| rd_en         | Input  | 1-bit  | Register read enable                                             |
| wr_en         | Input  | 1-bit  | Register write enable                                            |
| cnt           | Input  | 64-bit | Current counter value                                            |
| addr          | Input  | 12-bit | Address of the register to access                                |
| wdata         | Input  | 32-bit | Data to write into the register                                  |
| int_st        | Input  | 1-bit  | Interrupt status from the Interrupt block                        |
| div_en        | Output | 1-bit  | Enables the Prescaler block                                      |
| div_val       | Output | 4-bit  | Prescaler divide value                                           |
| timer_en      | Output | 1-bit  | Enables the Timer counter                                        |
| int_en        | Output | 1-bit  | Enables interrupt signal generation                              |
| tdr0_wr_sel   | Output | 1-bit  | Write select for Timer Data Register 0 (TDR0)                    |
| tdr1_wr_sel   | Output | 1-bit  | Write select for Timer Data Register 1 (TDR1)                    |
| tcmp          | Output | 64-bit | Compare value sent to the Counter                                |
| clear         | Output | 1-bit  | Request to clear the counter                                     |
| rdata         | Output | 32-bit | Register read data returned to the APB Slave                     |
+---------------+--------+--------+------------------------------------------------------------------+
```

</details>

<details>
<summary><b> Counter Control (counter_control.v)</b></summary>

```text
+---------------+--------+--------+---------------------------------------------------------------+
| Signal name   | Dir.   | Width  | Description                                                   |
+---------------+--------+--------+---------------------------------------------------------------+
| sys_clk       | Input  | 1-bit  | System clock                                                  |
| sys_rst_n     | Input  | 1-bit  | Asynchronous reset, active low                                |
| timer_en      | Input  | 1-bit  | Enables Timer operation                                       |
| div_val       | Input  | 4-bit  | Prescaler divide value                                        |
| div_en        | Input  | 1-bit  | Enables the Prescaler block                                   |
| cnt_en        | Output | 1-bit  | Counter enable signal                                         |
+---------------+--------+--------+---------------------------------------------------------------+
```

</details>
<details>
<summary><b> Counter (counter.v)</b></summary>

```text
+---------------+--------+--------+---------------------------------------------------------------+
| Signal name   | Dir.   | Width  | Description                                                   |
+---------------+--------+--------+---------------------------------------------------------------+
| tdr0_wr_sel   | Input  | 1-bit  | Selects write to the lower 32 bits of the counter (TDR0)      |
| tdr1_wr_sel   | Input  | 1-bit  | Selects write to the upper 32 bits of the counter (TDR1)      |
| sys_rst_n     | Input  | 1-bit  | Asynchronous reset, active low                                |
| sys_clk       | Input  | 1-bit  | System clock                                                  |
| wdata         | Input  | 32-bit | Data to write into the counter                                |
| cnt           | Output | 64-bit | Current value of the 64-bit counter                           |
+---------------+--------+--------+---------------------------------------------------------------+
```

</details>
<details>
<summary><b> Interrupt Block (interrupt.v)</b></summary>

```text
+---------------------+-------+--------+---------------------------------------------------------+
| Signal name         | Dir.  | Width  | Description                                             |
+---------------------+-------+--------+---------------------------------------------------------+
| sys_clk             | Input | 1-bit  | Main system clock                                       |
| sys_rst_n           | Input | 1-bit  | System reset, asynchronous, active low (0)              |
| cnt[63:0]           | Input | 64-bit | Current counter value received from the Counter Core    |
| tcmp[63:0]          | Input | 64-bit | Preset compare value (concatenated from TCMP0 and TCMP1)|
| int_en              | Input | 1-bit  | Interrupt output enable bit from the Register block    |
| int_clr             | Input | 1-bit  | Interrupt flag clear signal (W1C) from the Register block |
| set                 | Output| 1-bit  | Signal that latches the interrupt flag (Match), sent to the Register block |
| tim_int             | Output| 1-bit  | Physical interrupt output pin sent to the CPU           |
+---------------------+-------+--------+---------------------------------------------------------+

```

</details>

## 5. Register Map

The configuration registers are 32 bits wide by default. Undefined address regions follow the **RAZ/WI** rule (Read As Zero / Write Ignored).

<details>
<summary><b>  Register Summary</b></summary>

```text
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
| Register name | Address (Offset)| Type        | Reset value     | Brief description                                       |
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
| TCR           | 0x00            | RO/RW       | 32'h0000_0100   | Timer control register (enable/disable, Prescaler cfg)  |
| TDR0          | 0x04            | RW          | 32'h0000_0000   | Lower 32 bits of the 64-bit up-counter                  |
| TDR1          | 0x08            | RW          | 32'h0000_0000   | Upper 32 bits of the 64-bit up-counter                  |
| TCMP0         | 0x0C            | RW          | 32'hFFFF_FFFF   | Lower 32 bits of the interrupt compare value            |
| TCMP1         | 0x10            | RW          | 32'hFFFF_FFFF   | Upper 32 bits of the interrupt compare value            |
| TIER          | 0x14            | RO/RW       | 32'h0000_0000   | Interrupt enable register for the tim_int pin           |
| TISR          | 0x18            | RW1C        | 32'h0000_0000   | Interrupt status register (pending bit), write 1 to clear |
| THCSR         | 0x1C            | RO/RW       | 32'h0000_0000   | Debug register (only active at Advanced Level)          |
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
```

</details>

## 6. Verification Strategy

The system is verified in a simulation environment (Testbench), focusing on the correct operation of the functional blocks and compliance with the APB protocol.

### 6.1. Verification Goals
* **Functional coverage:** Achieve 100% of the functional requirements (Functional Coverage).
* **Data integrity:** Ensure there are no conflicts between writes from APB and internal counter updates.
* **Signal latency:** Verify the timing of the `tim_int` interrupt signal relative to the system clock cycle.

### 6.2. Test Case Suites
 > * Note: The detailed list of test scenarios (Test Case Plan) and the test run results are stored at: /docx/Verification_Plan/Verification_Plan.docx
</details>

### 6.3. Simulation Environment
* **Simulator:** ModelSim / QuestaSim.
* **Methodology:** Direct Test (a separate testbench file for each module).
* **Result:** All 30 testcases (in 5 testcase files) PASS with a clean simulation log.

  ## 7. Verification Metrics & Coverage

To ensure the Timer IP operates as designed, verification is evaluated using the following metrics:

### 7.1. Code Coverage
Measures how much of the RTL code is covered by the testbench:
* **Statement Coverage:** Ensures every line of code in `src/` has been executed.
* **Branch Coverage:** Checks that all branches (if-else, case) have been exercised.

### 7.2. Functional Coverage
Measures coverage of the functional specification (generated by Covergroups):
* **Register Access:** Ensures every register has been accessed (read/write) at least once.
* **Prescaler Values:** Thoroughly checks all divider value combinations (corresponding to `div_val`).
* **Interrupt Triggers:** Covers the cases where an interrupt occurs when the Timer reaches the compare value, as well as interrupt clearing (W1C).

### 7.3. Coverage Reports
All coverage data is automatically compiled after each simulation run:
> *For the detailed coverage report, see: `/report/Coverage/detail_report.txt`.*

### 7.4. Coverage Summary
Summary table of coverage for the entire system:
> *For the coverage summary report, see: `/report/Coverage/summary_report.txt`.*
### 7.5. Coverage Exclusion Justification
- In some cases certain code branches cannot reach 100% coverage; I excluded them based on hardware logic and other justified reasons.
> *For the detailed report, see: `/report/Justification/Justification_Table.docx`.*


---
## 8. How to Run

### Requirements
* **Simulator:** ModelSim / QuestaSim
* **OS:** Linux / Unix 

### Simulation Steps

**8.1. Change into the sim directory:**
```bash
cd src/sim
```

**8.2. Run all testcases:**
```bash
Step 1: Run everything
./run.csh 
Step 2: Check the Passed/Fail results of the cases
./report.csh
```

**8.3. Run individual testcases:**
```bash
make all TESTNAME=apb_basic_chk
make all TESTNAME=reg_chk_all
make all TESTNAME=counter_control
make all TESTNAME=interrupt_chk
make all TESTNAME=no_stimulus_chk
```

**8.4. Generate the coverage report:**
```bash
./run.csh cov
make gen_cov
vi coverage/summary_report.txt
or
vi coverage/detail_report.txt
```

> **Note:** The log from each run is saved automatically to `src/sim/log/`. 
## 9. Author

| Information | Details                                              |
|-------------|------------------------------------------------------|
| **Full name**  | Trần Hồ Khánh Tân                                 |
| **University** | FPT University                                    |
| **Major**      | Semiconductor IC Design                           |
| **Cohort**     | 2024 – 2028                                       |
| **Type**       | Individual Project                                |
| **Supervisor** | Instructor — Phạm Thiều Khang - From ICTC Center  |
