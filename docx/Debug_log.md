# Debug Log — PROJECT_IP-Timer (Standard Level)

- Tài liệu này ghi lại quá trình phát hiện và xử lý các vấn đề thực tế trong quá trình thiết kế RTL và verification của Timer IP.
- Tác giả : Trần Hồ Khánh Tân.
- Thực hiện : 15/06/2026 - 23/06/2026
---

## Bug #1 — Chiều rộng dây không khớp trong `apb_slave.v`

**Giai đoạn:** RTL bring-up, trước khi chạy testcase đầu tiên.

**Triệu chứng:** Compile RTL báo lỗi/warning liên quan đến độ rộng wire không khớp giữa signal khai báo và signal được assign trong `apb_slave.v`.

**Lý do:** Một wire được khai báo với độ rộng bit không khớp với độ rộng của tín hiệu thực tế được gán vào nó (ở đây là rdata ban đầu được khai báo với [31:0] nhưng tim_prdata chỉ được khai báo với [30:0] bit, dẫn tới việc assign bị sai và compile error).

**Sửa lỗi:** Sửa lại khai báo độ rộng wire cho khớp đúng với interface signal tương ứng.

**Verification:** Compile lại toàn bộ RTL, xác nhận không còn warning/error về width mismatch trước khi tiếp tục chạy testcase.

---

## Bug #2 — Hiện tượng dây mồ côi trong `timer_top.v`

**Giai đoạn:** RTL bring-up, khi ghép nối các module con vào `timer_top`.

**Triệu chứng:** Có wire được khai báo trong `timer_top.v` nhưng không được kết nối (port-map) vào bất kỳ instance module con nào — dấu hiệu của việc sửa code nhiều lần để lại khai báo thừa.

**Lý do :** Trong quá trình chỉnh sửa cấu trúc kết nối giữa các module con (`apb_slave`, `register`, `counter_control`, `counter`, `interrupt`), một số wire tạm bị bỏ sót sau khi đổi cách nối hoặc các wire bị khai báo lặp lại do nhầm lẫn ( như việc 2 tín hiệu : set và clear được khai báo 2 lần: set, int_st, clear và int_clear do nhầm lẫn tín hiệu từ interrupt dẫn tới việc các wire bị thừa ) .

**Sửa lỗi:** Rà soát lại toàn bộ danh sách wire trong `timer_top.v`, xóa các khai báo không còn được sử dụng, đảm bảo mọi wire đều có ít nhất 1 đầu driver và 1 đầu load.

**Verification:** Compile lại, kiểm tra bằng compile warning để đảm bảo không còn wire bị dư thừa hoặc không được kết nối.

---
## Bug #3 - Phát hiện lỗi logic RTL thông qua test case ở : reg_chk_all.v

**Giai đoạn:** Sau khi chạy compile thành công và không có warning. Tiến hành chạy lần lượt các test case để kiểm tra lỗi logic và dừng lại ở case : `reg_chk_all.v`.

**Triệu chứng:** Trong test case tiến hành gán các giá trị phù hợp cho thanh ghi TCR ( 12'h00) để cho counter chạy nhưng counter chạy bị sai chiều. Có nghĩa là thay vì chạy : 64'h0000_0000_0000_0001 nhưng lại chạy thành 64'h0000_0001_0000_0000. Đây là ví dụ điển hình của bit-ordering bug trong concatenation — lỗi rất dễ mắc khi ghép nhiều thanh ghi thành 1 vector rộng hơn, và rất khó phát hiện chỉ bằng cách nhìn lướt code vì compile vẫn pass bình thường, không có warning gì.

**Lý do :** Giá trị cnt(count) được lưu trữ bởi 2 thanh ghi TDR0 ( 32 bit đầu) và TDR1 (32 bit sau) và giá trị count được gán đúng như sau : cnt = {TDR1,TDR0}.Thế nhưng trong quá trình gán cnt(count) xảy ra nhầm lẫn vị trí giữa 2 thanh ghi và count được gán thành : cnt = {TDR0,TDR1}.

**Sửa lỗi:** Rà soát lại thứ tự các thanh ghi được gán cho cnt(count), hoán đổi lại vị trí thanh ghi bị nhầm lần.

**Verification:** Chạy lại test case và counter hoạt động bình thường, cnt đã lưu trữ đúng giá trị và đúng chiều.

## Bug #4 — Phát hiện lỗi logic RTL thông qua test case ở : reg_chk_all.v

**Giai đoạn:** Sau khi chạy compile thành công và không có warning. Tiến hành chạy lần lượt các test case để kiểm tra lỗi logic và dừng lại ở case : `interrupt_chk.v`.

**Triệu chứng:** Trong test case tiến hành gán các giá trị phù hợp cho thanh ghi TCR (12'h00) để counter chạy 3 clock (clk) sau đó dừng lại thì lúc này giá trị cnt = 3 và set up các giá trị cho tcmp gồm thanh ghi TCMP0 và TCMP1 ( Compare value) bằng với giá trị đếm (cnt) để tiến hành test cho sinh ra tín hiệu interrupt( tim_int). Nhưng kết quả cho ra thì tim_int không được sinh ra. 

**Lý do :** Giá trị tcmp được lưu trữ bởi 2 thanh ghi TCMP0(32 bit đầu) và TCMP1(32 bit sau) và giá trị compare value được gán đúng như sau : tcmp {tcmp1, tcmp0}. Thế nhưng trong quá trình gán tcmp lại thành : tcmp {tcmp0,tcmp1} dẫn tới việc so sánh bị sai và tim_int không được sinh ra.

**Sửa lỗi:** Hoán đổi lại vị trí thanh ghi trong tcmp.

**Verification:** Chạy lại test case và tim_int được sinh ra.

## Bug #5 - Phát hiện lỗi logic RTL thông qua test case ở : counter_control.v

**Giai đoạn:** Sau khi chạy compile thành công và không có warning. Tiến hành chạy lần lượt các test case để kiểm tra lỗi logic và dừng lại ở case : `counter_control.v`.

**Triệu chứng:** Trong quá trình tiến hành gán các giá trị cho thanh ghi TCR ( 12'h00) để kiểm tra tốc độ đếm của counter. Khi lần lượt gán các giá trị cho div_val (với các giá trị tương ứng thì tốc độ counter sẽ chạy phụ thuộc vào đó. Ví dụ với div_val = 4'b0010 thì cnt_int ( count_internal) sẽ đếm 4 chu kì clock thì counter mới đếm lên 1 theo công thức limit = ((8'h1 << div_val) - 1) và cnt_int sẽ reset về 0 ) bên trong thanh ghi TCR thì giá trị cnt(count) trả về bị sai không đúng với design spec dẫn tới việc các checker dùng để kiểm tra các case báo FAILED.

**Lý do :** Giá trị limit bị gán sai công thức. Limit bị gán thành : limit = (8'h1 << div_val) . Thiếu trừ 1 dẫn tới việc bị sai số.

**Sửa lỗi:** Sửa lại công thức limit cho đúng bằng cách thêm - 1.

**Verification:** Chạy lại test case và liên tục thử các trường hợp div_val khác nhau để đảm bảo không còn sai số ở counter.

## Bug #6 — FEC miss ở `apb_slave.v`: tổ hợp `psel=0 & penable=1` không hit

**Giai đoạn:** Coverage closure, sau khi đã pass toàn bộ functional testcase.

**Triệu chứng:** Expression Coverage của `apb_slave.v` chỉ đạt 93.75% (15/16 bins). QuestaSim FEC (Focused Expression Coverage) report chỉ rõ tại line 30 (`valid_access = tim_psel & tim_penable`), input term `tim_psel` chưa từng hit giá trị `_0` trong tổ hợp cần thiết.

**Lý do:** Thay vì viết thêm test một cách mù quáng để "ép" hit tổ hợp này, đã phân tích ngược lại theo giao thức APB: PENABLE chỉ được phép assert đúng 1 chu kỳ sau khi PSEL đã lên 1 ở cycle trước — tổ hợp `psel=0 & penable=1` là trạng thái vi phạm protocol, không thể phát sinh nếu driver (`apb_write`/`apb_read` task trong testbench) tuân thủ đúng thứ tự APB chuẩn. Kết luận: đây không phải bug thiếu test, mà là bin coverage không thể đạt được về mặt cấu trúc.

**Cách Xử Lý:** Exclude row FEC này qua Coverage GUI (`Exclude Selection FEC`), kèm comment giải thích lý do protocol để đưa vào Coverage Exclusion Justification Table.

---

## Bug #7 — Branch miss ở `register.v`: default case trong case(addr) không hit

**Giai đoạn:** Coverage closure.

**Triệu chứng:** Branch Coverage của `register.v` đạt 96.15% (25/26), Statement Coverage 97.43% (38/39). Chỗ miss: line 55, `default: rdata = 32'h0;`.

**Lý do:** Truy ngược lên tầng trên (`apb_slave.v`), xác nhận `addr_valid` (line 31) đã giới hạn `tim_paddr` chỉ được coi hợp lệ khi khớp đúng 1 trong 8 offset (TCR/TDR0/TDR1/TCMP0/TCMP1/TIER/TISR/THCSR), và `rd_en` chỉ được assert khi `addr_valid=1`. Case statement trong `register.v` liệt kê đúng 8 giá trị này — tức nhánh `default` chỉ có thể chạy nếu address decode ở tầng trên bị sai, điều không thể xảy ra trong thiết kế đúng.

**Cách Xử Lý:** Exclude cả Branch + Statement tại dòng 55, ghi rõ lý do address đã được validate ở tầng `apb_slave` trước khi vào `register`.

---


