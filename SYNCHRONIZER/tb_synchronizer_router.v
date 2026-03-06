`timescale 1ns/1ps

module tb_synchronizer_router;

reg clk;
reg reset;

reg detect_add;
reg write_enb_reg;
reg [1:0] data_in;

reg read_enb_0, read_enb_1, read_enb_2;
reg empty_0, empty_1, empty_2;
reg full_0, full_1, full_2;

wire vld_out_0, vld_out_1, vld_out_2;
wire [2:0] write_enb;
wire fifo_full;
wire soft_reset_0, soft_reset_1, soft_reset_2;

// DUT
synchronizer_router dut(
    .detect_add(detect_add),
    .data_in(data_in),
    .write_enb_reg(write_enb_reg),
    .clk(clk),
    .reset(reset),
    .vld_out_0(vld_out_0),
    .vld_out_1(vld_out_1),
    .vld_out_2(vld_out_2),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .write_enb(write_enb),
    .fifo_full(fifo_full),
    .empty_0(empty_0),
    .empty_1(empty_1),
    .empty_2(empty_2),
    .soft_reset_0(soft_reset_0),
    .soft_reset_1(soft_reset_1),
    .soft_reset_2(soft_reset_2),
    .full_0(full_0),
    .full_1(full_1),
    .full_2(full_2)
);

// clock
always #5 clk = ~clk;

// waveform
initial begin
    $dumpfile("sync_router.vcd");
    $dumpvars(0,tb_synchronizer_router);
end


initial begin
    clk = 0;
    reset = 0;

    detect_add = 0;
    write_enb_reg = 0;
    data_in = 2'b00;

    read_enb_0 = 0;
    read_enb_1 = 0;
    read_enb_2 = 0;

    empty_0 = 1;
    empty_1 = 1;
    empty_2 = 1;

    full_0 = 0;
    full_1 = 0;
    full_2 = 0;

    // -------------------------------------------------
    // TEST 1 : RESET
    // -------------------------------------------------
    #15 reset = 1;
    $display("Reset released");

    // -------------------------------------------------
    // TEST 2 : Address capture FIFO0
    // -------------------------------------------------
    #10 detect_add = 1;
    data_in = 2'b00;
    #10 detect_add = 0;

    write_enb_reg = 1;
    #20;

    // -------------------------------------------------
    // TEST 3 : Address capture FIFO1
    // -------------------------------------------------
    write_enb_reg = 0;
    #10 detect_add = 1;
    data_in = 2'b01;
    #10 detect_add = 0;

    write_enb_reg = 1;
    #20;

    // -------------------------------------------------
    // TEST 4 : Address capture FIFO2
    // -------------------------------------------------
    write_enb_reg = 0;
    #10 detect_add = 1;
    data_in = 2'b10;
    #10 detect_add = 0;

    write_enb_reg = 1;
    #20;

    // -------------------------------------------------
    // TEST 5 : FIFO FULL detection
    // -------------------------------------------------
    full_2 = 1;
    #20;
    full_2 = 0;

    // -------------------------------------------------
    // TEST 6 : VALID OUTPUT generation
    // -------------------------------------------------
    empty_0 = 0;
    empty_1 = 0;
    empty_2 = 0;
    #20;

    empty_0 = 1;
    empty_1 = 1;
    empty_2 = 1;

    // -------------------------------------------------
    // TEST 7 : SOFT RESET generation
    // no read enable for ~30 cycles
    // -------------------------------------------------
    data_in = 2'b00;
    detect_add = 1;
    #10 detect_add = 0;

    repeat(35) #10;

    // -------------------------------------------------
    // TEST 8 : Read enable clears counter
    // -------------------------------------------------
    read_enb_0 = 1;
    #20;
    read_enb_0 = 0;

    repeat(10) #10;

    // -------------------------------------------------
    $display("Simulation finished");
    #20 $finish;
end

endmodule