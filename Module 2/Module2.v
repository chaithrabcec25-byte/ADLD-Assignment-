// Code your design here
module seconds_counter (
    input wire clk,
    input wire rst_n,
    input wire tick_1s,
    output reg [5:0] sec_count,
    output reg min_tick
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sec_count <= 6'd0;
        min_tick <= 1'b0;
    end
    else begin
        // Default: keep min_tick low unless rollover happens on this cycle
        min_tick <= 1'b0;

        if (tick_1s) begin
            if (sec_count == 6'd59) begin
                sec_count <= 6'd0;
                min_tick <= 1'b1; // Asserted for 1 clock cycle on 59 -> 00
            end
            else begin
                sec_count <= sec_count + 6'd1;
            end
        end
    end
end

endmodule

// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb_seconds_counter;

reg clk;
reg rst_n;
reg tick_1s;
wire [5:0] sec_count;
wire min_tick;

// Instantiate the Unit Under Test (UUT)
seconds_counter uut (
    .clk (clk),
    .rst_n (rst_n),
    .tick_1s (tick_1s),
    .sec_count (sec_count),
    .min_tick (min_tick)
);

// 10ns period clock (100 MHz)
always #5 clk = ~clk;

initial begin
    // Required for EDA Playground waveform viewer (EPWave)
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_seconds_counter);

    // Initialize signals
    clk = 0;
    rst_n = 0;
    tick_1s = 0;

    // Release active-low reset after 20ns
    #20 rst_n = 1;

    // Test 1: Hold tick_1s low for a few cycles (count should stay 0)
    repeat (3) @(posedge clk);

    // Test 2: Run through 65 ticks to observe 58 -> 59 -> 00 rollover
    repeat (65) begin
        @(posedge clk);
        tick_1s <= 1'b1;
        @(posedge clk);
        tick_1s <= 1'b0; // Single-cycle tick pulse
    end

    // Test 3: Continuous tick_1s = 1 for 62 cycles to verify back-to-back rollover
    @(posedge clk);
    tick_1s <= 1'b1;
    repeat (62) @(posedge clk);
    tick_1s <= 1'b0;

    // Test 4: Assert reset mid-count
    #15 rst_n = 0;
    #20 rst_n = 1;

    #30 $finish;
end

// Monitor key transitions in the console log
initial begin
    $monitor("Time=%0t | rst_n=%b | tick_1s=%b | sec_count=%02d | min_tick=%b",
             $time, rst_n, tick_1s, sec_count, min_tick);
end

endmodule