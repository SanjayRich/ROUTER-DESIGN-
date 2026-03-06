`timescale 1ns/1ps

module tb_register_router;

reg clk;
reg reset;
reg pkt_valid;
reg fifo_full;
reg rst_int_reg;
reg detect_add;
reg ld_state;
reg laf_state;
reg full_state;
reg lfd_state;

reg [7:0] data_in;

wire parity_done;
wire low_pkt_valid;
wire error;
wire [7:0] dout;


// DUT

register_router DUT(
clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,
ld_state,laf_state,full_state,lfd_state,
parity_done,low_pkt_valid,error,dout
);


// clock generation

always #5 clk = ~clk;


// dump file for GTKWave

initial
begin
$dumpfile("router_register.vcd");
$dumpvars(0,tb_register_router);
end


initial
begin

$display("==== Router Register Testbench Started ====");

clk = 0;
reset = 0;
pkt_valid = 0;
fifo_full = 0;
rst_int_reg = 0;
detect_add = 0;
ld_state = 0;
laf_state = 0;
full_state = 0;
lfd_state = 0;
data_in = 0;


//------------------------------------------------
// TEST 1 : RESET
//------------------------------------------------

#10
reset = 1;
$display("RESET RELEASED");


//------------------------------------------------
// TEST 2 : HEADER WRITE
//------------------------------------------------

#10
pkt_valid = 1;
detect_add = 1;
lfd_state = 1;

data_in = 8'h14;   // header

#10
detect_add = 0;
lfd_state = 0;


//------------------------------------------------
// TEST 3 : PAYLOAD DATA
//------------------------------------------------

ld_state = 1;

data_in = 8'h11;
#10

data_in = 8'h22;
#10

data_in = 8'h33;
#10

//------------------------------------------------
// TEST 4 : PARITY BYTE
//------------------------------------------------

pkt_valid = 0;
data_in = 8'h44;

#10


//------------------------------------------------
// TEST 5 : FIFO FULL CONDITION
//------------------------------------------------

pkt_valid = 1;
fifo_full = 1;
ld_state = 1;

data_in = 8'hAA;

#10

fifo_full = 0;


//------------------------------------------------
// TEST 6 : LAF STATE
//------------------------------------------------

laf_state = 1;

#10

laf_state = 0;


//------------------------------------------------
// TEST 7 : ERROR CHECK
//------------------------------------------------

pkt_valid = 1;
detect_add = 1;

data_in = 8'h23;

#10

detect_add = 0;

ld_state = 1;

data_in = 8'h45;
#10

pkt_valid = 0;
data_in = 8'h99; // wrong parity

#20


//------------------------------------------------

$display("==== TESTBENCH FINISHED ====");

#20
$finish;

end

endmodule