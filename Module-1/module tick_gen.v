module tick_gen #(
    parameter integer CLK_FREQ_HZ = 50000000
)(
    input wire clk,
    input wire rst_n,
    output reg tick_1s
);

reg [31:0] count;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        count <= 0;
        tick_1s <= 0;
    end
    else begin
        if (count == CLK_FREQ_HZ - 1) begin
            count <= 0;
            tick_1s <= 1;
        end
        else begin
            count <= count + 1;
            tick_1s <= 0;
        end
    end
end

endmodule

module tb_tick_gen;

reg clk;
reg rst_n;
wire tick_1s;

// Override frequency to 10 Hz
tick_gen #(
    .CLK_FREQ_HZ(10)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .tick_1s(tick_1s)
);

// Generate clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_tick_gen);

    rst_n = 0;
    #12;
    rst_n = 1;

    // Observe for 35 clock cycles
    repeat (35) begin
        @(posedge clk);
        #1;
        $display("Time=%0t Count=%0d Tick_1s=%b",
                 $time, uut.count, tick_1s);
    end

    $finish;
end

endmodule