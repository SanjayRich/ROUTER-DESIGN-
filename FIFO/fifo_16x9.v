module fifo_16x9_router(
    input clk,
    input reset,
    input write_enb,
    input read_enb,
    input soft_reset,
    input lfd_state,
    input [7:0] data_in,
    output full,
    output empty,
    output reg [7:0] data_out
);

// internal signals
reg [4:0] write_addr, read_addr;
reg [8:0] mem [0:15];
reg [6:0] fifo_down_counter;
reg lfd_state_temp;

integer i;

// delay lfd_state by one clock
always @(posedge clk)
begin
    if(!reset)
        lfd_state_temp <= 0;
    else
        lfd_state_temp <= lfd_state;
end

//----------------------------------
// WRITE OPERATION
//----------------------------------

always @(posedge clk)
begin
    if(!reset)
    begin
        for(i=0;i<16;i=i+1)
            mem[i] <= 0;
        write_addr <= 0;
    end

    else if(soft_reset)
    begin
        for(i=0;i<16;i=i+1)
            mem[i] <= 0;
        write_addr <= 0;
    end

    else if(write_enb && !full)
    begin
        mem[write_addr[3:0]] <= {lfd_state_temp,data_in};
        write_addr <= write_addr + 1;
    end
end

//----------------------------------
// READ OPERATION
//----------------------------------

always @(posedge clk)
begin
    if(!reset)
    begin
        data_out <= 0;
        read_addr <= 0;
    end

    else if(soft_reset)
    begin
        data_out <= 8'bz;
        read_addr <= 0;
    end

    else if(fifo_down_counter == 0 && data_out != 8'b0)
    begin
        data_out <= 8'bz;
    end

    else if(read_enb && !empty)
    begin
        data_out <= mem[read_addr[3:0]][7:0];
        read_addr <= read_addr + 1;
    end
end

//----------------------------------
// FIFO DOWN COUNTER LOGIC
//----------------------------------

always @(posedge clk)
begin
    if(!reset)
        fifo_down_counter <= 0;

    else if(soft_reset)
        fifo_down_counter <= 0;

    else if(read_enb && !empty)
    begin
        if(mem[read_addr[3:0]][8] == 1'b1)
            fifo_down_counter <= mem[read_addr[3:0]][7:2] + 1;

        else if(fifo_down_counter != 0)
            fifo_down_counter <= fifo_down_counter - 1;
    end
end

//----------------------------------
// FIFO FULL LOGIC
//----------------------------------

assign full = ((write_addr[3:0] == read_addr[3:0]) &&
              (write_addr[4] != read_addr[4])) ? 1'b1 : 1'b0;

//----------------------------------
// FIFO EMPTY LOGIC
//----------------------------------

assign empty = ((write_addr[3:0] == read_addr[3:0]) &&
               (write_addr[4] == read_addr[4])) ? 1'b1 : 1'b0;

endmodule