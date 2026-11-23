module minutes_counter(
    input wire clk,
    input wire rst_n,
    input wire min_tick,
    output reg [5:0] min_count,
    output reg hour_tick
);

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        min_count <= 0;
        hour_tick <= 0;
    end
    else begin
        hour_tick <= 0;

        if (min_tick) begin
            if (min_count == 59) begin
                min_count <= 0;
                hour_tick <= 1;
            end
            else begin
                min_count <= min_count + 1;
            end
        end
    end
end

endmodule

module tb_minutes_counter;

reg clk;
reg rst_n;
reg min_tick;

wire [5:0] min_count;
wire hour_tick;

minutes_counter uut (
    .clk(clk),
    .rst_n(rst_n),
    .min_tick(min_tick),
    .min_count(min_count),
    .hour_tick(hour_tick)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

task apply_tick;
begin
    @(negedge clk);
    min_tick = 1;

    @(posedge clk);
    #1;
    $display("Time=%0t Minutes=%0d Hour_tick=%b",
             $time, min_count, hour_tick);

    @(negedge clk);
    min_tick = 0;
end
endtask

initial begin
    rst_n = 0;
    min_tick = 0;

    #12;
    rst_n = 1;

    // Count from 0 to 58
    repeat (58)
        apply_tick();

    $display("Before rollover: %0d", min_count);

    // 58 to 59
    apply_tick();

    // 59 to 00
    apply_tick();

    // Check hour_tick clears
    @(posedge clk);
    #1;
    $display("Next cycle: Minutes=%0d Hour_tick=%b",
             min_count, hour_tick);

    $finish;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_minutes_counter);
end

endmodule