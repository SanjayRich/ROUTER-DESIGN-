module router_top(clk,reset,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,
                  data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,
                  valid_out_2,error,busy);

// input and output declarations

input clk,reset,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
input [7:0] data_in;

output [7:0] data_out_0,data_out_1,data_out_2;
output valid_out_0,valid_out_1,valid_out_2,error,busy;


// declaring the internal wire for sub block connections
// fifo output wires

wire empty_0,full_0,empty_1,full_1,empty_2,full_2;


// synchronizer output wires

wire soft_reset_0,soft_reset_1,soft_reset_2;
wire write_enb_0,write_enb_1,write_enb_2;


// fsm output wires

wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;


// register output internal connections

wire parity_done,low_pkt_valid;
wire [7:0] data_out;


// fsm router controller

fsm_router_controller FSM(clk,reset,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,empty_0,empty_1,empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

// synchronizer router

synchronizer_router SYNCHRONIZER(detect_add,data_in[1:0],write_enb_reg,clk,reset,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

// register router

register_router REGISTER(clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,data_out);


// FIFO instances

fifo_16x9_router FIFO1(clk,reset,data_out,write_enb_0,read_enb_0,soft_reset_0,lfd_state,full_0,empty_0,data_out_0);

fifo_16x9_router FIFO2(clk,reset,data_out,write_enb_0,read_enb_1,soft_reset_1,lfd_state,full_1,empty_1,data_out_1);

fifo_16x9_router FIFO3(clk,reset,data_out,write_enb_2,read_enb_2,soft_reset_2,lfd_state,full_2,empty_2,data_out_2);

endmodule