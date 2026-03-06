`timescale 1ns/1ps

module tb_fifo_16x9_router;

reg clk;
reg reset;
reg write_enb;
reg read_enb;
reg soft_reset;
reg lfd_state;
reg [7:0] data_in;

wire full;
wire empty;
wire [7:0] data_out;

integer i;

// DUT
fifo_16x9_router dut(
    .clk(clk),
    .reset(reset),
    .write_enb(write_enb),
    .read_enb(read_enb),
    .soft_reset(soft_reset),
    .lfd_state(lfd_state),
    .data_in(data_in),
    .full(full),
    .empty(empty),
    .data_out(data_out)
);

// clock generation
always #5 clk = ~clk;

initial begin
    $dumpfile("fifo_router.vcd");
    $dumpvars(0,tb_fifo_16x9_router);
end

//--------------------------------------------------
// TEST SEQUENCE
//--------------------------------------------------

initial begin

$display("=====================================");
$display("Starting FIFO Router Testbench");
$display("=====================================");

clk = 0;
reset = 0;
write_enb = 0;
read_enb = 0;
soft_reset = 0;
lfd_state = 0;
data_in = 0;

#20
reset = 1;

$display("RESET RELEASED");

//------------------------------------
// TEST 1 : SIMPLE PACKET WRITE
//------------------------------------

$display("TEST1 : Write packet");

lfd_state = 1;
write_enb = 1;
data_in = 8'b00010100; // header
#10

lfd_state = 0;
data_in = 8'h11;
#10

data_in = 8'h22;
#10

data_in = 8'h33;
#10

data_in = 8'h44; // parity
#10

write_enb = 0;


//------------------------------------
// TEST 2 : READ PACKET
//------------------------------------

$display("TEST2 : Read packet");

#20
read_enb = 1;

repeat(5) #10;

read_enb = 0;


//------------------------------------
// TEST 3 : FIFO FULL CONDITION
//------------------------------------

$display("TEST3 : Fill FIFO to FULL");

write_enb = 1;

for(i=0;i<16;i=i+1) begin
    data_in = i;
    #10;
end

write_enb = 0;

if(full)
    $display("FIFO FULL detected correctly");
else
    $display("ERROR : FULL not detected");


//------------------------------------
// TEST 4 : FIFO EMPTY CONDITION
//------------------------------------

$display("TEST4 : Empty FIFO");

read_enb = 1;

for(i=0;i<16;i=i+1)
    #10;

read_enb = 0;

if(empty)
    $display("FIFO EMPTY detected correctly");
else
    $display("ERROR : EMPTY not detected");


//------------------------------------
// TEST 5 : WRITE WHEN FULL
//------------------------------------

$display("TEST5 : Write when FIFO FULL");

write_enb = 1;
data_in = 8'hAA;
#10
write_enb = 0;


//------------------------------------
// TEST 6 : READ WHEN EMPTY
//------------------------------------

$display("TEST6 : Read when FIFO EMPTY");

read_enb = 1;
#10
read_enb = 0;


//------------------------------------
// TEST 7 : SOFT RESET
//------------------------------------

$display("TEST7 : Soft Reset");

write_enb = 1;
data_in = 8'h55;
#10

soft_reset = 1;
#10

soft_reset = 0;
write_enb = 0;


//------------------------------------
// TEST COMPLETE
//------------------------------------

#50

$display("=====================================");
$display("TESTBENCH COMPLETE");
$display("=====================================");

$finish;

end

endmodule