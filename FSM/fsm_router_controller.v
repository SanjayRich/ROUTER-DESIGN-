// fsmm

module fsm_router_controller(clk,reset,pkt_valid,busy,parity_done,data_in,
soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,
fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,
rst_int_reg,lfd_state);

// declaring the input and output ports

input clk,reset,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,
fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;

input [1:0] data_in;

output detect_add,ld_state,laf_state,full_state,rst_int_reg,lfd_state;
output busy,write_enb_reg;


// creating internal register for present state,next state regs declarations

parameter DECODE_ADDRESS=3'b000,LOAD_FIRST_DATA=3'b001,WAIT_TILL_EMPTY=3'b010,
LOAD_DATA=3'b011,FIFO_FULL_STATE=3'b100,LOAD_AFTER_FULL=3'b101,
LOAD_PARITY=3'b110,CHECK_PARITY_ERROR=3'b111;

reg [1:0] addr_data;
reg [2:0] present,next;


// storing detecting the destination_address_signal

always@(*)
begin
    if(!reset)
        addr_data<=0;
    else
    begin
        if(detect_add)
            addr_data <= data_in;
    end
end


// sequential logic for present state

always@(posedge clk)
begin
    if(!reset)
        present<=DECODE_ADDRESS;
    else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
        present<=DECODE_ADDRESS;
    else
        present<=next;
end


// combinational logic for next state

always@(*)
begin
    case(present)

    DECODE_ADDRESS:
    begin
        if((pkt_valid && addr_data == 2'd0 && fifo_empty_0) ||
           (pkt_valid && addr_data == 2'd1 && fifo_empty_1) ||
           (pkt_valid && addr_data == 2'd2 && fifo_empty_2))
            next=LOAD_FIRST_DATA;

        else if((pkt_valid && addr_data == 2'd0 && (!fifo_empty_0)) ||
                (pkt_valid && addr_data == 2'd1 && (!fifo_empty_1)) ||
                (pkt_valid && addr_data == 2'd2 && (!fifo_empty_2)))
            next=WAIT_TILL_EMPTY;

        else
            next=DECODE_ADDRESS;
    end


    WAIT_TILL_EMPTY:
    begin
        if((addr_data == 2'd0 && fifo_empty_0) ||
           (addr_data == 2'd1 && fifo_empty_1) ||
           (addr_data == 2'd2 && fifo_empty_2))
            next=LOAD_FIRST_DATA;
        else
            next=WAIT_TILL_EMPTY;
    end


    LOAD_FIRST_DATA:
        next=LOAD_DATA;


    LOAD_DATA:
    begin
        if(fifo_full)
            next=FIFO_FULL_STATE;

        else if(!fifo_full && !pkt_valid)
            next=LOAD_PARITY;

        else
            next=LOAD_DATA;
    end


    FIFO_FULL_STATE:
    begin
        if(!fifo_full)
            next=LOAD_AFTER_FULL;
        else
            next=FIFO_FULL_STATE;
    end


    LOAD_AFTER_FULL:
    begin
        if(!parity_done && !low_pkt_valid)
            next=LOAD_DATA;

        else if(!parity_done && low_pkt_valid)
            next=LOAD_PARITY;

        else if(parity_done)
            next=DECODE_ADDRESS;
    end


    LOAD_PARITY:
        next=CHECK_PARITY_ERROR;


    CHECK_PARITY_ERROR:
    begin
        if(fifo_full)
            next=FIFO_FULL_STATE;
        else
            next=DECODE_ADDRESS;
    end


    default:
        next=DECODE_ADDRESS;

    endcase
end



// combinational logic for output
// busy is going to low at decode state and load state other states it was
// high bcaz it is not allowing new data from the source

assign busy = ((present == DECODE_ADDRESS) || (present == LOAD_DATA)) ? 1'b0 : 1'b1;

assign detect_add = (present == DECODE_ADDRESS) ? 1'b1 : 1'b0;
assign ld_state = (present == LOAD_DATA) ? 1'b1 : 1'b0;
assign laf_state = (present == LOAD_AFTER_FULL) ? 1'b1 : 1'b0;
assign full_state = (present == FIFO_FULL_STATE) ? 1'b1 : 1'b0;
assign lfd_state = (present == LOAD_FIRST_DATA) ? 1'b1 : 1'b0;
assign rst_int_reg = (present == CHECK_PARITY_ERROR) ? 1'b1 : 1'b0;


// write enb reg going tp high only in these state bcaz these stae have
// capable for sending payload and parity data to fifo when write enb reg is
// high then only we know which fifo desination.neccessary to send the data
// at he particular stae

assign write_enb_reg = ((present == LOAD_DATA) ||
                        (present == LOAD_PARITY) ||
                        (present == LOAD_AFTER_FULL)) ? 1'b1 : 1'b0;

endmodule