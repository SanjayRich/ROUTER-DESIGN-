`timescale 1ns/1ps

module router_top_tb;

reg clk;
reg reset;

reg pkt_valid;
reg read_enb_0;
reg read_enb_1;
reg read_enb_2;

reg [7:0] data_in;

wire [7:0] data_out_0;
wire [7:0] data_out_1;
wire [7:0] data_out_2;

wire valid_out_0;
wire valid_out_1;
wire valid_out_2;

wire error;
wire busy;


// DUT

router_top DUT(
clk,
reset,
read_enb_0,
read_enb_1,
read_enb_2,
data_in,
pkt_valid,
data_out_0,
data_out_1,
data_out_2,
valid_out_0,
valid_out_1,
valid_out_2,
error,
busy
);


// clock generation

always #5 clk = ~clk;


// dump waveform

initial
begin
$dumpfile("router_top.vcd");
$dumpvars(0,router_top_tb);
end



// packet sending task

task send_packet;

input [7:0] header;
input [7:0] payload0;
input [7:0] payload1;
input [7:0] payload2;

reg [7:0] parity;

begin

parity = header ^ payload0 ^ payload1 ^ payload2;

@(negedge clk)
pkt_valid = 1;
data_in = header;

@(negedge clk)
data_in = payload0;

@(negedge clk)
data_in = payload1;

@(negedge clk)
data_in = payload2;

@(negedge clk)
pkt_valid = 0;
data_in = parity;

end

endtask




initial
begin

clk = 0;
reset = 0;

pkt_valid = 0;

read_enb_0 = 0;
read_enb_1 = 0;
read_enb_2 = 0;

data_in = 0;


// reset

#20
reset = 1;


// ==============================
// TEST1 : PACKET TO FIFO0
// ==============================

send_packet(8'b00000100,8'h11,8'h22,8'h33);

#100

read_enb_0 = 1;

#100

read_enb_0 = 0;


// ==============================
// TEST2 : PACKET TO FIFO1
// ==============================

#50

send_packet(8'b00000101,8'h44,8'h55,8'h66);

#100

read_enb_1 = 1;

#100

read_enb_1 = 0;


// ==============================
// TEST3 : PACKET TO FIFO2
// ==============================

#50

send_packet(8'b00000110,8'h77,8'h88,8'h99);

#100

read_enb_2 = 1;

#100

read_enb_2 = 0;


// ==============================
// TEST4 : PARITY ERROR
// ==============================

@(negedge clk)
pkt_valid = 1;
data_in = 8'b00000100;

@(negedge clk)
data_in = 8'hAA;

@(negedge clk)
data_in = 8'hBB;

@(negedge clk)
data_in = 8'hCC;

@(negedge clk)
pkt_valid = 0;
data_in = 8'h00;   // wrong parity


#200

$finish;

end

endmodule