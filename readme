# UART Verilog Implementation for Cyclone V GX Starter Kit

This repository contains a fully verified, ready-to-run UART (Universal Asynchronous Receiver-Transmitter) core implemented in Verilog. 

This project is **100% runnable without any modifications or pin reassignments** on the following target hardware:
* **FPGA Device:** `5CGXFC5C6F27C7`
* **Development Board:** Intel Cyclone V GX Starter Kit

---

## 📁 Repository Files

* **`uart.qpf` / `uart.qsf`:** Intel Quartus Prime project and settings files (includes all pre-configured pin assignments).
* **`uart.v` / `baseline_c5gx.v`:** Source Verilog code for the UART controller and top-level routing.
* **`c5_pin_model_dump.txt` / `uart_assignment_defaults.qdf`:** Exported pin configuration data and defaults.

---

## 🚀 How to Run It Immediately

Because the full Quartus project structure is included, you do not need to set up anything from scratch:

1. **Download or Clone** this entire repository to your computer.
2. Open **Intel Quartus Prime**.
3. Go to `File -> Open Project` and select the **`uart.v`** file.
4. Click **Start Compilation** (Ctrl+L) to generate the programming file.
5. Open the **Programmer** tool and flash the compiled configuration directly onto your `5CGXFC5C6F27C7` FPGA board.

---

## 🛠️ How to Test & Interface

Once the project is running on your board, you can interact with it using a serial terminal like **PuTTY**:

### PuTTY Serial Configuration
* **Connection Type:** Serial
* **Serial Line:** (Your board's COM Port, e.g., COM3)
* **Speed (Baud Rate):** `115200`
* **Data bits:** 8 | **Stop bits:** 1 | **Parity:** None

### 1. Computer to FPGA (Receiving Data)
* Connect your FPGA board to your PC via its USB-UART port.
* Open the configured PuTTY terminal session.
* Type any character into the PuTTY window.
* **Result:** The FPGA receives the character, and the onboard **7-Segment Display** instantly shows its corresponding **Hexadecimal ASCII code**.

### 2. FPGA to Computer (Transmitting Data)
* Set your desired data byte using the physical **onboard slide switches**.
* Press the **`KEY0`** pushbutton on the board to trigger the transmission.
* **Result:** The character represented by your switch configurations will transmit back to your PC and print directly on your **PuTTY terminal screen**.
