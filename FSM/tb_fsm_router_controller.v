`timescale 1ns/1ps

module tb_fsm_router_controller;

reg clk;
reg reset;
reg pkt_valid;
reg parity_done;
reg fifo_full;
reg low_pkt_valid;
reg soft_reset_0, soft_reset_1, soft_reset_2;
reg fifo_empty_0, fifo_empty_1, fifo_empty_2;
reg [1:0] data_in;

wire detect_add, ld_state, laf_state, full_state, rst_int_reg, lfd_state;
wire busy, write_enb_reg;

// DUT
fsm_router_controller dut(
    .clk(clk),
    .reset(reset),
    .pkt_valid(pkt_valid),
    .busy(busy),
    .parity_done(parity_done),
    .data_in(data_in),
    .soft_reset_0(soft_reset_0),
    .soft_reset_1(soft_reset_1),
    .soft_reset_2(soft_reset_2),
    .fifo_full(fifo_full),
    .low_pkt_valid(low_pkt_valid),
    .fifo_empty_0(fifo_empty_0),
    .fifo_empty_1(fifo_empty_1),
    .fifo_empty_2(fifo_empty_2),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .full_state(full_state),
    .write_enb_reg(write_enb_reg),
    .rst_int_reg(rst_int_reg),
    .lfd_state(lfd_state)
);

// clock
always #5 clk = ~clk;

// waveform dump
initial begin
    $dumpfile("fsm_router.vcd");
    $dumpvars(0, tb_fsm_router_controller);
end

// helper task: idle
task idle;
begin
    pkt_valid = 0;
    parity_done = 0;
    fifo_full = 0;
    low_pkt_valid = 0;
    soft_reset_0 = 0;
    soft_reset_1 = 0;
    soft_reset_2 = 0;
    fifo_empty_0 = 1;
    fifo_empty_1 = 1;
    fifo_empty_2 = 1;
    data_in = 2'd0;
end
endtask

initial begin
    clk = 0;
    reset = 0;
    idle;

    // -----------------------------------------
    // TEST 1: RESET
    // -----------------------------------------
    #12;
    reset = 1;
    $display("TEST1: Reset released");

    // -----------------------------------------
    // TEST 2: Normal packet flow (FIFO empty)
    // DECODE -> LOAD_FIRST_DATA -> LOAD_DATA
    // -----------------------------------------
    data_in = 2'd0;     // destination FIFO0
    pkt_valid = 1;
    fifo_empty_0 = 1;

    #20; // should go to LOAD_FIRST_DATA
    #20; // should go to LOAD_DATA

    // payload cycles
    #20;
    #20;

    // -----------------------------------------
    // TEST 3: Parity arrival
    // LOAD_DATA -> LOAD_PARITY
    // -----------------------------------------
    pkt_valid = 0;  // parity byte phase
    #20;

    // -----------------------------------------
    // TEST 4: Parity check
    // LOAD_PARITY -> CHECK_PARITY_ERROR
    // -----------------------------------------
    parity_done = 1;
    #20;
    parity_done = 0;

    // -----------------------------------------
    // TEST 5: WAIT_TILL_EMPTY path
    // DECODE_ADDRESS -> WAIT_TILL_EMPTY
    // -----------------------------------------
    pkt_valid = 1;
    data_in = 2'd1;     // FIFO1
    fifo_empty_1 = 0;   // FIFO busy
    #20;

    // FIFO becomes empty
    fifo_empty_1 = 1;
    #20;

    // -----------------------------------------
    // TEST 6: FIFO FULL state
    // LOAD_DATA -> FIFO_FULL_STATE
    // -----------------------------------------
    data_in = 2'd2;
    pkt_valid = 1;
    fifo_empty_2 = 1;

    #20;
    fifo_full = 1;  // force full
    #20;

    // -----------------------------------------
    // TEST 7: LOAD_AFTER_FULL
    // -----------------------------------------
    fifo_full = 0;
    #20;

    // continue payload
    pkt_valid = 1;
    #20;

    // -----------------------------------------
    // TEST 8: LOAD_AFTER_FULL -> LOAD_PARITY
    // -----------------------------------------
    pkt_valid = 0;
    low_pkt_valid = 1;
    #20;

    // -----------------------------------------
    // TEST 9: Soft reset
    // -----------------------------------------
    soft_reset_0 = 1;
    #20;
    soft_reset_0 = 0;

    // -----------------------------------------
    // finish
    // -----------------------------------------
    #40;
    $display("All FSM edge cases simulated.");
    $finish;
end

endmodule