# PROJECT_IP-Timer ( Standard)
- Đây là IP Core Timer tiêu chuẩn, hỗ trợ giao tiếp cấu hình qua bus APB (APB Slave Interface), có khả năng tạo ngắt (interrupt) và đếm xung với độ phân giải cao

<img width="504" height="291" alt="image" src="https://github.com/user-attachments/assets/5abafbbc-a18c-438f-9b9a-28b390003729" />


## 1. Project Overview & Status
* **Design Specification:** Kiến trúc hệ thống và đặc tả chi tiết tại:  `docs/Design_Spec/Design_Spec.docx/`.
* **Project Timeline:** Được lưu trữ chi tiết tại : ` report/time_line/time_line.xlsx/`.
  ### Repository Structure

```text
PROJECT_IP-Timer/
├── src/
│   ├── rtl/                  (timer_top.v và 5 module con)
│   │   ├── timer_top.v
│   │   ├── apb_slave.v
│   │   ├── register.v
│   │   ├── counter_control.v
│   │   ├── counter.v
│   │   └── interrupt.v
│   ├── tb/                   (Testbench top-level)
│   │   └── test_bench.v
│   ├── sim/                  (Makefile và script chạy simulation)
│   │   ├── Makefile
│   │   ├── compile.f
│   │   ├── pat.list
│   │   └── report.csh
│   └── testcases/            (5 file testcase, tổng cộng 30 test items)
│       ├── apb_basic_chk.v
│       ├── counter_control.v
│       ├── interrupt_chk.v
│       ├── no_stimulus_chk.v
│       └── reg_chk_all.v
|──docx/
|    |──Design_Spec/            ( Design_Spec.docx)
|    |──Verification_Plan/      ( Verification_Plan.docx)
├── report/
|   |──time_line/             (time_line.xlsx)
│   ├── Coverage/             (Coverage Summary & Detail Report .html)
│   └── Justification/        (Coverage Exclusion Justification Table .docx)
├── refs/                     (Tài liệu tham khảo)
└── README.md
```

### 2.Cấu trúc phân cấp thiết kế  (Design Hierarchy)

Lõi IP được tổ chức phân cấp mạch lạc từ module TOP xuống các module con tương ứng trong thư mục `rtl/`:

```text
timer_top.v (Top-level Module)
├── apb_slave.v          (Khối giao tiếp APB Slave)
├── register.v           (Khối tập thanh ghi cấu hình)
├── counter_control.v    (Khối điều khiển & chia tần Prescaler)
├── counter.v            (Lõi bộ đếm tiến 64-bit)
└── interrupt.v          (Khối quản lý & tạo tín hiệu ngắt)
```
### 3. Khối chức năng chính (Functional Blocks)

Hệ thống được thiết kế theo cấu trúc mô-đun hóa phân cấp (Hierarchical Design), bao gồm 5 khối chức năng lõi tương tác chặt chẽ với nhau:

* **APB Slave Interface (`apb_slave.v`):** 
  * Đóng vai trò là khối giao tiếp ngoại vi.
  * Thực hiện giải mã địa chỉ (`paddr`), bắt các tín hiệu điều khiển (`psel`, `penable`, `pwrite`) từ APB Bus để tạo ra các xung điều khiển đọc/ghi nội bộ (`wr_en`, `rd_en`).
  * Phản hồi trạng thái sẵn sàng (`pready`) và báo lỗi (`pslverr`) về hệ thống.

* **Register Block (`register.v`):**
  * Nơi lưu trữ hệ thống các thanh ghi cấu hình, điều khiển và trạng thái của IP.
  * Cập nhật dữ liệu ghi (`wdata`) từ bus hoặc dữ liệu nội bộ từ bộ đếm/khối ngắt, đồng thời đẩy dữ liệu đọc (`rdata`) ra APB Bus khi có yêu cầu.
  * Cung cấp các thông số cấu hình (`div_val`, `timer_en`) cho khối điều khiển đếm.

* **Counter Control (`counter_control.v`):**
  * Bộ não điều khiển trung gian của mạch đếm.
  * Tiếp nhận giá trị cấu hình bộ chia xung (`div_val`) và trạng thái cho phép chạy (`timer_en`) từ khối thanh ghi để tính toán thời điểm kích hoạt bộ đếm (`cnt_en`).
  * Đảm bảo bộ đếm hoạt động đồng bộ với hệ thống hoặc tạm dừng chính xác theo đúng cấu hình.

* **Counter Core (`counter.v`):**
  * Lõi thực thi đếm thời gian dựa trên tín hiệu cho phép (`cnt_en`).
  * Thực hiện logic đếm tích lũy và phát hiện trạng thái tràn bộ đếm (`overflow`) khi đạt tới giá trị đặt trước hoặc giới hạn bit.
  * Phản hồi liên tục giá trị đếm hiện tại về khối thanh ghi để người dùng có thể đọc được.

* **Interrupt Block (`interrupt.v`):**
  * Quản lý toàn bộ cơ chế báo ngắt của IP Core.
  * Tiếp nhận tín hiệu tràn (`overflow`) từ khối Counter, kết hợp với bit cho phép ngắt để kích hoạt tín hiệu ngắt vật lý `tim_int` ra ngoài hệ thống.
  * Duy trì cờ trạng thái ngắt trong thanh ghi cho đến khi được xóa một cách hợp lệ bởi W1C (Write 1 To Clear).
    
## 4. Signal Descriptions

Dưới đây là đặc tả chi tiết các tín hiệu ngõ vào/ra (I/O Signals) theo từng khối chức năng ( module) con trong hệ thống. Bấm chọn vào từng module để xem chi tiết bảng chân chân tín hiệu:

<details>
<summary><b> APB Slave Interface (apb_slave.v)</b></summary>

```text
+----------------+--------+--------+-------------------------------------------------------------+
| Tên tín hiệu   | Hướng  | Độ rộng| Mô tả chức năng                                             |
+----------------+--------+--------+-------------------------------------------------------------+
| tim_psel       | Input  | 1-bit  | Tín hiệu chọn APB Slave từ APB Master                       |
| tim_pwrite     | Input  | 1-bit  | Điều khiển chu kỳ (0: Đọc, 1: Ghi)                          |
| tim_penable    | Input  | 1-bit  | Kích hoạt pha Access của bus APB                            |
| tim_paddr      | Input  | 12-bit | Địa chỉ thanh ghi APB                                       |
| rdata          | Input  | 32-bit | Dữ liệu đọc từ khối Register gửi về APB Slave               |
| tim_pwdata     | Input  | 32-bit | Dữ liệu ghi từ APB Master                                   |
| wdata          | Output | 32-bit | Dữ liệu ghi chuyển sang khối Register                       |
| tim_prdata     | Output | 32-bit | Dữ liệu đọc trả về APB Master                               |
| addr           | Output | 12-bit | Địa chỉ nội bộ chuyển sang khối Register                    |
| wr_en          | Output | 1-bit  | Xung cho phép ghi thanh ghi                                 |
| rd_en          | Output | 1-bit  | Xung cho phép đọc thanh ghi                                 |
| tim_pslverr    | Output | 1-bit  | Báo lỗi APB (luôn giữ mức 0 trong thiết kế này)             |
| pready         | Output | 1-bit  | Báo Slave sẵn sàng (luôn giữ mức 1 trong thiết kế này)      |
+----------------+--------+--------+-------------------------------------------------------------+
```

</details>

<details>
<summary><b> Register Block (register.v)</b></summary>
  
```text
+---------------+--------+--------+------------------------------------------------------------------+
| Tên tín hiệu  | Hướng  | Độ rộng| Mô tả chức năng                                                  |
+---------------+--------+--------+------------------------------------------------------------------+
| sys_clk       | Input  | 1-bit  | Xung clock hệ thống                                              |
| sys_rst_n     | Input  | 1-bit  | Reset bất đồng bộ, tích cực mức thấp                             |
| rd_en         | Input  | 1-bit  | Tín hiệu cho phép đọc thanh ghi                                  |
| wr_en         | Input  | 1-bit  | Tín hiệu cho phép ghi thanh ghi                                  |
| cnt           | Input  | 64-bit | Giá trị hiện tại của bộ đếm                                      |
| addr          | Input  | 12-bit | Địa chỉ thanh ghi cần truy cập                                   |
| wdata         | Input  | 32-bit | Dữ liệu ghi vào thanh ghi                                        |
| int_st        | Input  | 1-bit  | Trạng thái ngắt từ khối Interrupt                                |
| div_en        | Output | 1-bit  | Cho phép khối Prescaler hoạt động                                |
| div_val       | Output | 4-bit  | Giá trị chia tần Prescaler                                       |
| timer_en      | Output | 1-bit  | Cho phép bộ đếm Timer hoạt động                                  |
| int_en        | Output | 1-bit  | Cho phép tạo tín hiệu ngắt                                       |
| tdr0_wr_sel   | Output | 1-bit  | Chọn ghi thanh ghi Timer Data Register 0 (TDR0)                  |
| tdr1_wr_sel   | Output | 1-bit  | Chọn ghi thanh ghi Timer Data Register 1 (TDR1)                  |
| tcmp          | Output | 64-bit | Giá trị so sánh (Compare Value) gửi tới Counter                  |
| clear         | Output | 1-bit  | Yêu cầu xóa (clear) bộ đếm                                       |
| rdata         | Output | 32-bit | Dữ liệu đọc từ thanh ghi trả về APB Slave                        |
+---------------+--------+--------+------------------------------------------------------------------+
```

</details>

<details>
<summary><b> Counter Control (counter_control.v)</b></summary>

```text
+---------------+--------+--------+---------------------------------------------------------------+
| Tên tín hiệu  | Hướng  | Độ rộng| Mô tả chức năng                                               |
+---------------+--------+--------+---------------------------------------------------------------+
| sys_clk       | Input  | 1-bit  | Xung clock hệ thống                                           |
| sys_rst_n     | Input  | 1-bit  | Reset bất đồng bộ, tích cực mức thấp                          |
| timer_en      | Input  | 1-bit  | Cho phép Timer hoạt động                                      |
| div_val       | Input  | 4-bit  | Giá trị chia tần Prescaler                                    |
| div_en        | Input  | 1-bit  | Cho phép khối Prescaler hoạt động                             |
| cnt_en        | Output | 1-bit  | Tín hiệu kích hoạt bộ đếm (Counter Enable)                    |
+---------------+--------+--------+---------------------------------------------------------------+
```

</details>
<details>
<summary><b> Counter (counter.v)</b></summary>

```text
+---------------+--------+--------+---------------------------------------------------------------+
| Tên tín hiệu  | Hướng  | Độ rộng| Mô tả chức năng                                               |
+---------------+--------+--------+---------------------------------------------------------------+
| tdr0_wr_sel   | Input  | 1-bit  | Chọn ghi 32-bit thấp của bộ đếm (TDR0)                        |
| tdr1_wr_sel   | Input  | 1-bit  | Chọn ghi 32-bit cao của bộ đếm (TDR1)                         |
| sys_rst_n     | Input  | 1-bit  | Reset bất đồng bộ, tích cực mức thấp                          |
| sys_clk       | Input  | 1-bit  | Xung clock hệ thống                                           |
| wdata         | Input  | 32-bit | Dữ liệu ghi vào bộ đếm                                        |
| cnt           | Output | 64-bit | Giá trị hiện tại của bộ đếm 64-bit                            |
+---------------+--------+--------+---------------------------------------------------------------+
```

</details>
<details>
<summary><b> Interrupt Block (interrupt.v)</b></summary>

```text
+---------------------+-------+--------+---------------------------------------------------------+
| Tên tín hiệu        | Hướng | Độ rộng| Mô tả chức năng                                         |
+---------------------+-------+--------+---------------------------------------------------------+
| sys_clk             | Input | 1-bit  | Xung clock chính của hệ thống                           |
| sys_rst_n           | Input | 1-bit  | Reset hệ thống, bất đồng bộ, tích cực mức thấp (0)      |
| cnt[63:0]           | Input | 64-bit | Giá trị bộ đếm hiện tại nhận từ khối Counter Core       |
| tcmp[63:0]          | Input | 64-bit | Giá trị so sánh đặt trước (Ghép từ TCMP0 và TCMP1)      |
| int_en              | Input | 1-bit  | Bit cho phép xuất ngắt nhận từ khối Register            |
| int_clr             | Input | 1-bit  | Tín hiệu xóa cờ ngắt (W1C) nhận từ khối Register        |
| set                 | Output| 1-bit  | Tín hiệu kích khóa cờ ngắt (Match) gửi về khối Register |
| tim_int             | Output| 1-bit  | Chân tín hiệu ngắt vật lý ngõ ra gửi tới CPU            |
+---------------------+-------+--------+---------------------------------------------------------+

```

</details>

## 5. Register Map

Hệ thống thanh ghi cấu hình có độ rộng mặc định 32-bit. Các vùng địa chỉ không được định nghĩa hoạt động theo quy tắc **RAZ/WI** (Read As Zero / Write Ignored).

<details>
<summary><b>  Bảng tổng hợp thanh ghi (Register Summary)</b></summary>

```text
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
| Tên thanh ghi | Địa chỉ (Offset)| Loại (Type) | Giá trị Reset   | Mô tả tóm tắt chức năng                                 |
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
| TCR           | 0x00            | RO/RW       | 32'h0000_0000   | Thanh ghi điều khiển Timer (Bật/tắt,cấu hình Prescaler) |
| TDR0          | 0x04            | RW          | 32'h0000_0000   | 32-bit thấp của bộ đếm tiến 64-bit                      |
| TDR1          | 0x08            | RW          | 32'h0000_0000   | 32-bit cao của bộ đếm tiến 64-bit                       |
| TCMP0         | 0x0C            | RW          | 32'hFFFF_FFFF   | 32-bit thấp của giá trị so sánh ngắt                    |
| TCMP1         | 0x10            | RW          | 32'hFFFF_FFFF   | 32-bit cao của giá trị so sánh ngắt                     |
| TIER          | 0x14            | RO/RW       | 32'h0000_0000   | Thanh ghi cho phép xuất tín hiệu ngắt ra chân tim_int   |
| TISR          | 0x18            | RW1C        | 32'h0000_0000   | Thanh ghi trạng thái ngắt (Pending bit), ghi 1 để xóa   |
| THCSR         | 0x1C            | RO/RW       | 32'h0000_0000   | Thanh ghi gỡ lỗi (Chỉ kích hoạt ở Advanced Level)       |
+---------------+-----------------+-------------+-----------------+---------------------------------------------------------+
```

</details>

## 6. Verification Strategy

Hệ thống được kiểm thử dựa trên môi trường mô phỏng (Testbench) , tập trung vào khả năng vận hành chính xác của các khối chức năng và sự tuân thủ giao thức APB.

### 6.1. Mục tiêu kiểm thử
* **Độ bao phủ chức năng:** Đạt 80-100% các yêu cầu chức năng (Functional Coverage).
* **Tính toàn vẹn dữ liệu:** Đảm bảo không có xung đột giữa việc ghi từ APB và việc cập nhật nội bộ bộ đếm.
* **Độ trễ tín hiệu:** Kiểm chứng thời điểm phát tín hiệu ngắt `tim_int` so với chu kỳ clock hệ thống.

### 6.2. Nhóm các kịch bản kiểm thử (Test Case Suites)
 > * Lưu ý: Danh sách chi tiết các kịch bản kiểm thử (Test Case Plan) và kết quả chạy các test cases được lưu trữ chi tiết tại: /docx/Verification_Plan/Verification_Plan.docx
</details>

### 6.3. Môi trường mô phỏng
* **Simulator:** ModelSim / QuestaSim.
* **Phương pháp:** Direct Test (viết file Testbench riêng cho từng module).
* **Kết quả:** Tất cả 30 testcases(trong 5 file testcase) đều đạt kết quả PASS với log mô phỏng sạch (Clean Log).

  ## 7. Verification Metrics & Coverage

Để đảm bảo IP Timer vận hành đúng thiết kế, quá trình kiểm thử được đánh giá dựa trên các chỉ số (metrics) sau đây:

### 7.1. Code Coverage (Độ bao phủ mã nguồn)
Đo lường mức độ bao phủ của bộ Testbench đối với mã RTL:
* **Statement Coverage:** Đảm bảo mọi dòng code trong `src/` đều đã được thực thi.
* **Branch Coverage:** Kiểm tra tất cả các nhánh rẽ (if-else, case) đã được kích hoạt.

### 7.2. Functional Coverage (Độ bao phủ chức năng)
Đo lường mức độ bao phủ đối với các đặc tả chức năng (tạo bởi các Covergroup):
* **Register Access:** Đảm bảo tất cả các thanh ghi đã được truy cập (đọc/ghi) ít nhất một lần.
* **Prescaler Values:** Kiểm tra đầy đủ các tổ hợp giá trị chia tần (tương ứng với `div_val`).
* **Interrupt Triggers:** Bao phủ các trường hợp ngắt xảy ra khi Timer đạt giá trị so sánh và trường hợp xóa ngắt (W1C).

### 7.3. Kết quả báo cáo
Mọi số liệu về Coverage được tổng hợp tự động sau mỗi lần chạy Simulation:
> *Chi tiết báo cáo độ bao phủ (Coverage Report) xem tại: `/report/Coverage/Coverage_Detail_Report.html`.*

### 7.4. Code Coverage Summary
Bảng tổng hợp độ bao phủ của toàn bộ hệ thống :
> *Chi tiết báo cáo độ bao phủ (Coverage Report) xem tại: `/report/Coverage/Coverage_Summary_Report.html`.*
### 7.5. Code Coverage Exclusion Justification
- Một số trường hợp một số nhánh code không thể đạt 100%, chúng tôi thực hiện loại trừ (exclude) dựa trên lý do logic phần cứng và các lý do logic khác.
> *Chi tiết báo cáo xem tại: `/report/Justification/Justification_Table.docx`.*


---
## 8. How to Run

### Yêu cầu
* **Simulator:** ModelSim / QuestaSim
* **OS:** Linux / Unix 

### Các bước chạy simulation

**8.1. Di chuyển vào thư mục sim:**
```bash
cd src/sim
```

**8.2. Chạy toàn bộ testcase:**
```bash
./report.csh cov
sau đó
./report.csh
( kiểm tra kết quả Passed/Fail của các cases)
```

**8.3. Chạy từng testcase riêng lẻ:**
```bash
make all TESTNAME=apb_basic_chk
make all TESTNAME=reg_chk_all
make all TESTNAME=counter_control
make all TESTNAME=interrupt_chk
make all TESTNAME=no_stimulus_chk
```

**8.4. Xuất báo cáo coverage:**
```bash
make gen_cov
vi coverage/Summary_report.txt
hoặc
vi coverage/Detail_report.txt
```

> **Lưu ý:** Kết quả log sau mỗi lần chạy được lưu tự động vào `src/sim/log/`. 
## 9. Author

| Thông tin | Chi tiết                                             |
|-----------|------------------------------------------------------|
| **Họ và tên** | Trần Hồ Khánh Tân                                |
| **Trường**    | Đại Học FPT                                      |
| **Chuyên ngành** |                                               |
| **Khóa** | 2024 – 2028                                           |
| **Hình thức** | Cá nhân (Individual Project)                     |
| **Hướng dẫn** | Instructor — Phạm Thiều Khang - From ICTC Center |
