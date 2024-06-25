module fsmDelayCntr(
    input clk,
    input reset,
    input [31:0] len,
    output reg dn
    );
    
    reg [31:0] count;
    
    always@(posedge clk)
    begin
        if(reset)
        begin
            count <= 0;
            dn <= 0;
        end
        else
        begin
            if(count == len)
            begin
                dn <= 1;
                count <= 0;
            end
            else
            begin
                dn <= 0;
                count <= count + 1;
            end
        end
    end
endmodule
