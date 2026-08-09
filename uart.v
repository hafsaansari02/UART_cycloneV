module uart_tx #
(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 115200
)
(
    input clk,
    input reset,

    input tx_start,
    input [7:0] tx_data,

    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [15:0] baud_counter;
reg [2:0] bit_counter;
reg [7:0] data_reg;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        state        <= IDLE;
        tx           <= 1'b1;
        tx_busy      <= 1'b0;
        tx_done      <= 1'b0;
        baud_counter <= 16'd0;
        bit_counter  <= 3'd0;
        data_reg     <= 8'd0;
    end

    else
    begin
        tx_done <= 1'b0;

        case(state)

        //---------------------------------------------------------
        // IDLE
        //---------------------------------------------------------
        IDLE:
        begin
            tx <= 1'b1;
            tx_busy <= 1'b0;
            baud_counter <= 0;
            bit_counter <= 0;

            if(tx_start)
            begin
                tx_busy <= 1'b1;
                data_reg <= tx_data;
                state <= START;
            end
        end

        //---------------------------------------------------------
        // START BIT
        //---------------------------------------------------------
        START:
        begin
            tx <= 1'b0;

            if(baud_counter < CLKS_PER_BIT-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;
                state <= DATA;
            end
        end

        //---------------------------------------------------------
        // DATA BITS
        //---------------------------------------------------------
        DATA:
        begin
            tx <= data_reg[bit_counter];

            if(baud_counter < CLKS_PER_BIT-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;

                if(bit_counter < 7)
                    bit_counter <= bit_counter + 1;
                else
                begin
                    bit_counter <= 0;
                    state <= STOP;
                end
            end
        end

        //---------------------------------------------------------
        // STOP BIT
        //---------------------------------------------------------
        STOP:
        begin
            tx <= 1'b1;

            if(baud_counter < CLKS_PER_BIT-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;
                tx_busy <= 1'b0;
                tx_done <= 1'b1;
                state <= IDLE;
            end
        end

        default:
            state <= IDLE;

        endcase
    end
end

endmodule

module uart_rx #
(
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 115200
)
(
    input clk,
    input reset,

    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [15:0] baud_counter;
reg [2:0] bit_counter;
reg [7:0] data_reg;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state        <= IDLE;
        baud_counter <= 0;
        bit_counter  <= 0;
        data_reg     <= 0;
        rx_data      <= 0;
        rx_done      <= 0;
    end

    else
    begin
        rx_done <= 1'b0;

        case(state)

        //-------------------------------------------------
        // IDLE
        //-------------------------------------------------
        IDLE:
        begin
            baud_counter <= 0;
            bit_counter  <= 0;

            if(rx == 1'b0)
                state <= START;
        end

        //-------------------------------------------------
        // START BIT
        //-------------------------------------------------
        START:
        begin
            if(baud_counter < (CLKS_PER_BIT/2)-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;

                if(rx == 1'b0)
                    state <= DATA;
                else
                    state <= IDLE;
            end
        end

        //-------------------------------------------------
        // DATA BITS
        //-------------------------------------------------
        DATA:
        begin
            if(baud_counter < CLKS_PER_BIT-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;

                data_reg[bit_counter] <= rx;

                if(bit_counter < 7)
                    bit_counter <= bit_counter + 1;
                else
                begin
                    bit_counter <= 0;
                    state <= STOP;
                end
            end
        end

        //-------------------------------------------------
        // STOP BIT
        //-------------------------------------------------
        STOP:
        begin
            if(baud_counter < CLKS_PER_BIT-1)
                baud_counter <= baud_counter + 1;
            else
            begin
                baud_counter <= 0;

                if(rx == 1'b1)
                begin
                    rx_data <= data_reg;
                    rx_done <= 1'b1;
                end

                state <= IDLE;
            end
        end

        default:
            state <= IDLE;

        endcase
    end
end

endmodule

module hex_decoder(
    input  [3:0] hex,
    output reg [6:0] seg
);

always @(*)
begin
    case(hex)

        4'h0: seg = 7'b1000000;
        4'h1: seg = 7'b1111001;
        4'h2: seg = 7'b0100100;
        4'h3: seg = 7'b0110000;
        4'h4: seg = 7'b0011001;
        4'h5: seg = 7'b0010010;
        4'h6: seg = 7'b0000010;
        4'h7: seg = 7'b1111000;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0010000;
        4'hA: seg = 7'b0001000;
        4'hB: seg = 7'b0000011;
        4'hC: seg = 7'b1000110;
        4'hD: seg = 7'b0100001;
        4'hE: seg = 7'b0000110;
        4'hF: seg = 7'b0001110;

        default: seg = 7'b1111111;

    endcase
end

endmodule


module uart
(
    input wire CLOCK_50_B6A,
    input [7:0] SW,
    input KEY0,
    input UART_RX,

    output UART_TX,
    output [6:0] HEX0,
    output [6:0] HEX1
);

wire [7:0] rx_data;
wire rx_done;

reg [7:0] display_data;

reg tx_start;
wire tx_busy;
wire tx_done;

reg key_d;

always @(posedge CLOCK_50_B6A)
begin
    key_d <= KEY0;

    tx_start <= 1'b0;

    // Send once when KEY0 is pressed
    if(key_d == 1'b1 && KEY0 == 1'b0 && !tx_busy)
        tx_start <= 1'b1;

    // Save received byte for display
    if(rx_done)
        display_data <= rx_data;
end

//---------------------------------------------------------
// UART Transmitter
//---------------------------------------------------------
uart_tx
#(
    .CLOCK_FREQ(50000000),
    .BAUD_RATE(115200)
)
TX
(
    .clk(CLOCK_50_B6A),
    .reset(1'b0),

    .tx_start(tx_start),
    .tx_data(SW),

    .tx(UART_TX),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

//---------------------------------------------------------
// UART Receiver
//---------------------------------------------------------
uart_rx
#(
    .CLOCK_FREQ(50000000),
    .BAUD_RATE(115200)
)
RX
(
    .clk(CLOCK_50_B6A),
    .reset(1'b0),

    .rx(UART_RX),

    .rx_data(rx_data),
    .rx_done(rx_done)
);

//---------------------------------------------------------
// Seven Segment
//---------------------------------------------------------
hex_decoder H0
(
    .hex(display_data[3:0]),
    .seg(HEX0)
);

hex_decoder H1
(
    .hex(display_data[7:4]),
    .seg(HEX1)
);

endmodule