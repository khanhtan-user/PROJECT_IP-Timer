# PROJECT_IP-Timer ( Standard)
- Đây là IP Core Timer tiêu chuẩn, hỗ trợ giao tiếp cấu hình qua bus APB (APB Slave Interface), có khả năng tạo ngắt (interrupt) và đếm xung với độ phân giải cao

<img width="504" height="291" alt="image" src="https://github.com/user-attachments/assets/5abafbbc-a18c-438f-9b9a-28b390003729" />

### 1.Cấu trúc phân cấp thiết kế (Design Hierarchy)

Lõi IP được tổ chức phân cấp mạch lạc từ module TOP xuống các module con tương ứng trong thư mục `rtl/`:

```text
timer_top.v (Top-level Module)
├── apb_slave.v          (Khối giao tiếp APB Slave)
├── register.v           (Khối tập thanh ghi cấu hình)
├── counter_control.v    (Khối điều khiển & chia tần Prescaler)
├── counter.v            (Lõi bộ đếm tiến 64-bit)
└── interrupt.v          (Khối quản lý & tạo tín hiệu ngắt)
```
### 2. Khối chức năng chính (Functional Blocks)

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
    
## 3. Signal Descriptions

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
<summary><b> Interrupt (interrupt.v)</b></summary>

```text
+---------------+--------+--------+---------------------------------------------------------------+
| Tên tín hiệu  | Hướng  | Độ rộng| Mô tả chức năng                                               |
+---------------+--------+--------+---------------------------------------------------------------+
| cnt_en        | Input  | 1-bit  | Tín hiệu cho phép bộ đếm hoạt động                            |
| tdr0_wr_sel   | Input  | 1-bit  | Chọn ghi 32-bit thấp của bộ đếm (TDR0)                        |
| tdr1_wr_sel   | Input  | 1-bit  | Chọn ghi 32-bit cao của bộ đếm (TDR1)                         |
| sys_rst_n     | Input  | 1-bit  | Reset bất đồng bộ, tích cực mức thấp                          |
| sys_clk       | Input  | 1-bit  | Xung clock hệ thống                                           |
| wdata         | Input  | 32-bit | Dữ liệu ghi vào bộ đếm                                        |
| cnt           | Output | 64-bit | Giá trị hiện tại của bộ đếm 64-bit                            |
+---------------+--------+--------+---------------------------------------------------------------+
```

</details>

