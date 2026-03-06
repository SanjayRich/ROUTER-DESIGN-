module register_router(clk,reset,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,
                       ld_state,laf_state,full_state,lfd_state,
                       parity_done,low_pkt_valid,error,dout);

// declaring the regs and wires

input clk,reset,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,
      full_state,lfd_state;

input [7:0] data_in;

output reg error,low_pkt_valid,parity_done;
output reg [7:0] dout;


// creating 4 internal register for header byte storing,internal parity
// byte,packet parity byte,fifo full state byte each are 8 bits bcz all are bytes

reg [7:0] header_byte,internal_parity_byte,packet_parity_byte,fifo_full_state_byte;


// writing logic for header byte storing
// header store add detect address and present state at load first data and
// pkt valid is high and correct address destination

always@(posedge clk)
begin
    if(!reset)
        header_byte<=0;
    else if(pkt_valid && detect_add && (data_in[1:0] != 2'd3))
        header_byte<=data_in;
end



// logic for fifo full state byte
// storing the data in after full state

always@(posedge clk)
begin
    if(!reset)
        fifo_full_state_byte <= 0;
    else if(ld_state && fifo_full)
        fifo_full_state_byte <= data_in;
    else if(detect_add)
        fifo_full_state_byte <= 0;
    else
        fifo_full_state_byte <= fifo_full_state_byte ;
end



// writing logic for dout
// data out is works only at play load data in header data without error

always@(posedge clk)
begin
    if(!reset)
        dout<=0;

    else if(detect_add && pkt_valid && (data_in[1:0] != 2'd3))
        dout <= dout;

    else if(lfd_state)
        dout<=header_byte;

    else if(ld_state &&(!fifo_full))
        dout<=data_in;

    else if(full_state)
        dout<=dout;

    else if(laf_state)
        dout<=fifo_full_state_byte;

    else
        dout<=dout;
end



// writing logic for internal parity
// first it is ex or operation with header byte and then after continous ex or
// with each payload data stored into internal parity

always@(posedge clk)
begin
    if(!reset)
        internal_parity_byte<=0;

    else if(detect_add)
        internal_parity_byte<=0;

    else if(lfd_state)
        internal_parity_byte <= internal_parity_byte ^ header_byte;

    else if(ld_state && (!fifo_full))
        internal_parity_byte <= internal_parity_byte ^ data_in;

    else
        internal_parity_byte <= internal_parity_byte;
end



// writing logic for packet parity
// packet parity check weather state is parity_data only in this state
// only we getting parity of packets

always@(posedge clk)
begin
    if(!reset)
        packet_parity_byte <= 0;

    else if(detect_add)
        packet_parity_byte <= 0;

    else if((ld_state && (!pkt_valid)) && (!fifo_full))
        packet_parity_byte <= data_in;

    else if(!pkt_valid && rst_int_reg)
        packet_parity_byte<=0;

    else
        packet_parity_byte <= packet_parity_byte;
end



// parity done logic

always@(posedge clk)
begin
    if(!reset)
        parity_done <= 1'b0;

    else if(ld_state && (!pkt_valid) && (!fifo_full))
        parity_done <= 1'b1;

    else if(laf_state && (!parity_done) && low_pkt_valid)
        parity_done <= 1'b1;

    else
        parity_done <= 1'b0;
end



// error logic

always@(posedge clk)
begin
    if(!reset)
        error <=1'b0;

    else if((packet_parity_byte != internal_parity_byte) && parity_done)
        error <=1'b1;

    else if((packet_parity_byte == internal_parity_byte) && parity_done)
        error <=1'b0;

    else
        error <= 0;
end



// low_packet_valid logic this means if ther is no packets packet goes low so
// this is negation of pkt valid

always@(*)
begin
    if(!reset)
        low_pkt_valid <=0;

    else if(parity_done)
        low_pkt_valid <=1'b1;

    else if(pkt_valid)
        low_pkt_valid <=1'b0;

    else
        low_pkt_valid <=1'b1;
end

endmodule