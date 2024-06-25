module trafficLightTop(
    input init,
    input reset,
    input clk,
    output reg [3:0] state,
    output [7:0] seg,
    output [3:0] an,
    input MainLeftTurnReq,
    input SideLeftTurnReq
    );
    
    reg [3:0] mainFace1, mainFace2, sideFace1, sideFace2;
    
    localparam GRE = 0,
               YEL = 1,
               RED = 2,
               LFTGRE = 3,
               LFTYEL = 4,
               ALLOFF = 5;
               
    localparam sMGSR = 0,
               sMYSR = 1,
               sMRSR1 = 2,
               sMRSG = 3,
               sMRSY = 4,
               sMRSR2 = 5;
               
    wire dn;
    reg [31:0] statesCountVal;
    
    wire [15:0] lightVector = {sideFace2, sideFace1, mainFace2, mainFace1};
    
    dispdHex LED(.indata(lightVector), .clk(clk), .sseg(seg), .latchAN(an));
    fsmDelayCntr counter(.len(statesCountVal), .clk(clk), .dn(dn), .reset(reset));
    
    always@(state)
    begin
        case(state)
            sMGSR: statesCountVal = 500000000;
            sMYSR: statesCountVal = 100000000;
            sMRSR1: statesCountVal = 50000000;
            sMRSG: statesCountVal = 300000000;
            sMRSY: statesCountVal = 100000000;
            sMRSR2: statesCountVal = 50000000;
            default: statesCountVal = 100000000;
        endcase
    end
    
    always@(posedge clk)
    begin
        if(reset)
            state <= sMRSR1;
        else
        begin
            case(state)
            sMGSR:
                begin
                    if(dn)
                        state <= sMYSR;
                end
            sMYSR:
                begin
                    if(dn)
                        state <= sMRSR1;
                end
            sMRSR1:
                begin
                    if(dn)
                        state <= sMRSG;
                end
            sMRSG:
                begin
                    if(dn)
                        state <= sMRSY;
                end
            sMRSY:
                begin
                    if(dn)
                        state <= sMRSR2;
                end
            sMRSR2:
                begin
                    if(dn)
                        state <= sMGSR;
                end
            default: state <= sMRSR2;
            endcase
        end
    end
    
    always@(state)
    begin
        case(state)
            sMRSR1, sMRSR2:
                begin
                    mainFace1 = RED;
                    mainFace2 = RED;
                    sideFace1 = RED;
                    sideFace2 = RED;
                end
            sMGSR:
                begin
                    mainFace1 = GRE;
                    mainFace2 = GRE;
                    sideFace1 = RED;
                    sideFace2 = RED;
                end
            sMYSR:
                begin
                    mainFace1 = YEL;
                    mainFace2 = YEL;
                    sideFace1 = RED;
                    sideFace2 = RED;
                end
            sMRSG:
                begin
                    mainFace1 = RED;
                    mainFace2 = RED;
                    sideFace1 = GRE;
                    sideFace2 = GRE;
                end
            sMRSY:
                begin
                    mainFace1 = RED;
                    mainFace2 = RED;
                    sideFace1 = YEL;
                    sideFace2 = YEL;
                end
            default:
                begin
                    mainFace1 = RED;
                    mainFace2 = RED;
                    sideFace1 = RED;
                    sideFace2 = RED;
                end
            endcase
    end
endmodule
