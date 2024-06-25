module turnTop(
    input init,
    input res,
    input clk,
    output reg [3:0] state,
    output [7:0] seg,
    output [3:0] an,
    input MLTReg,
    input SLTReg 
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
               sMRSR2 = 5,
               sMTGSR = 6,
               sMTYSR = 7,
               sMRSTG = 8,
               sMRSTY = 9,
               sINITOFF = 10,
               sINITON = 11;
                
    wire dn;
    reg [31:0] statesCountVal;
    wire [15:0] lightVec = {sideFace2, sideFace1, mainFace2, mainFace1};
    
    dispdHex LED(.indata(lightVec), .clk(clk), .sseg(seg), .latchAN(an));
    fsmDelayCntr counter(.len(statesCountVal), .clk(clk), .dn(dn), .reset(res));
     
    always@(state)
    begin
        case(state)
            sMGSR: statesCountVal = 500000000;
            sMYSR: statesCountVal = 100000000;
            sMRSR1: statesCountVal = 50000000;
            sMRSG: statesCountVal = 300000000;
            sMRSY: statesCountVal = 100000000;
            sMRSR2: statesCountVal = 50000000;
            sMTGSR: statesCountVal = 200000000;
            sMTYSR: statesCountVal = 100000000;
            sMRSTG: statesCountVal = 200000000;
            sMRSTY: statesCountVal = 100000000;
            sINITOFF: statesCountVal = 50000000;
            sINITON: statesCountVal = 50000000;     
            default: statesCountVal = 100000000;        
        endcase
    end    
    
    always@(posedge clk)
    begin
        if(res)
            state <= sINITON;
        else
        begin
            case(state)
            sINITOFF:
                begin
                    if(init)
                        state <= sMGSR;
                    else
                        state <= sINITON;
                end
            sINITON:
                begin
                    if(dn)
                        state <= sINITOFF;
                end
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
                    if(dn && ~SLTReg)
                        state <= sMRSG;
                    else if (dn && SLTReg)
                        state <= sMRSTG;
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
                    if(dn && ~MLTReg)
                        state <= sMGSR;
                    else if (dn && MLTReg)
                        state <= sMTGSR;
                end
            sMTGSR:
                begin
                    if(dn)
                        state <= sMTYSR;
                end   
            sMTYSR:
                begin
                    if(dn)
                        state <= sMGSR;
                end
            sMRSTG:
                begin
                    if(dn)
                        state <= sMRSTY;
                end
            sMRSTY:
                begin
                    if(dn)
                        state <= sMRSG;
                end     
            default:
                begin
                    state <= sMRSR1;
                end
            endcase
        end
    end
    
    always @(state)
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
                sMTGSR:
                    begin
                        mainFace1 = LFTGRE;
                        mainFace2 = LFTGRE;
                        sideFace1 = RED;
                        sideFace2 = RED;
                    end
                sMTYSR:
                    begin
                        mainFace1 = LFTYEL;
                        mainFace2 = LFTYEL;
                        sideFace1 = RED;
                        sideFace2 = RED;
                    end
                sMRSTG:
                    begin
                        mainFace1 = RED;
                        mainFace2 = RED;
                        sideFace1 = LFTGRE;
                        sideFace2 = LFTGRE;
                    end 
                sMRSTY:
                    begin
                        mainFace1 = RED;
                        mainFace2 = RED;
                        sideFace1 = LFTYEL;
                        sideFace2 = LFTYEL;
                    end      
                sINITOFF:
                    begin
                        mainFace1 = ALLOFF;
                        mainFace2 = ALLOFF;
                        sideFace1 = ALLOFF;
                        sideFace2 = ALLOFF;
                    end   
                sINITON:
                    begin
                        mainFace1 = RED;
                        mainFace2 = RED;
                        sideFace1 = RED;
                        sideFace2 = RED;
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
