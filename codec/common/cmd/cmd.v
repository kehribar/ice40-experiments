// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
// RX: [0] + [7b address] + [32b data] 
// TX:
// ----------------------------------------------------------------------------
// RX: [1] + [7b address] + 
// TX:                      [32b data]
// ----------------------------------------------------------------------------
module cmd(
  input clk, // Main clock
  input rst, // Enable high reset
  input [7:0] rxData, // Low level rx data
  input rxValid, // Low level receive flag  
  output reg [7:0] txData, // Low level tx data
  output reg txSend, // Low level transmit flag
  input txBusy, // Transfer busy flag
  output reg we, // Write enable
  output reg [6:0] addr, // Final 7bit r/w address
  input [31:0] rdat, // Final 32bit read databus
  output reg [31:0] wdat, // Final 32bit Write databus
  output reg rxack
);

// ----------------------------------------------------------------------------
reg [2:0] bIndex;
reg sendToHost;
reg rxValid_d;
reg [23:0] dataReg;

// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
always @(posedge clk) begin
  if(rst == 1) begin
    we <= 0;
    wdat <= 0;
    rxack <= 0;
    bIndex <= 0;
    txData <= 0;
    txSend <= 0;
    dataReg <= 0;
    rxValid_d <= 0;
    sendToHost <= 0;
  end else begin
    rxValid_d <= rxValid;
    case (bIndex)
      // ----------------------------------------------------------------------  
      // Wait for read/write address
      3'd0: begin 
        if(rxValid) begin
          sendToHost <= rxData[7];
          addr <= rxData[6:0];
          bIndex <= 3'd1;          
          rxack <= 1;
        end else begin
          rxack <= 0;        
        end        
        we <= 0;
        txSend <= 0;          
      end
      // ----------------------------------------------------------------------
      // Data [31:24]
      3'd1: begin
        if(sendToHost) begin
          dataReg <= rdat[23:0];
          txData <= rdat[31:24];
          bIndex <= 3'd2;
          txSend <= 1;
        end else begin
          if((rxValid) && (!rxValid_d)) begin
            dataReg[23:16] <= rxData;
            bIndex <= 3'd2;
            rxack <= 1;
          end else begin
            rxack <= 0;
          end
        end
      end
      // ----------------------------------------------------------------------
      // Data [23:16]
      3'd2: begin 
        if(sendToHost) begin
          if(!txBusy) begin
            dataReg[23:8] <= dataReg[15:0];
            txData <= dataReg[23:16];
            bIndex <= 3'd3;
            txSend <= 1;
          end else begin
            txSend <= 0;
          end
        end else begin
          if((rxValid) && (!rxValid_d)) begin
            dataReg[15:8] <= rxData;
            bIndex <= 3'd3;
            rxack <= 1;
          end else begin
            rxack <= 0;
          end          
        end
      end
      // ----------------------------------------------------------------------
      // Data [15:8]
      3'd3: begin
        if(sendToHost) begin
          if(!txBusy) begin
            dataReg[23:8] <= dataReg[15:0];
            txData <= dataReg[23:16];
            bIndex <= 3'd4;
            txSend <= 1;
          end else begin
            txSend <= 0;
          end
        end else begin
          if((rxValid) && (!rxValid_d)) begin
            dataReg[7:0] <= rxData;
            bIndex <= 3'd4;
            rxack <= 1;
          end else begin
            rxack <= 0;
          end
        end
      end
      // ----------------------------------------------------------------------
      // Data [7:0]
      3'd4: begin 
        if(sendToHost) begin
          if(!txBusy) begin
            txData <= dataReg[23:16];
            bIndex <= 3'd5;
            txSend <= 1;
          end else begin
            txSend <= 0;
          end
        end else begin
          if((rxValid) && (!rxValid_d)) begin
            we <= 1;
            bIndex <= 3'd5;
            wdat[7:0] <= rxData;
            wdat[31:8] <= dataReg;
            rxack <= 1;
          end else begin
            rxack <= 0;          
          end          
        end
      end
      // ----------------------------------------------------------------------
      // 1 clock delay ...
      3'd5: begin         
        bIndex <= 3'd0;
      end
      // ----------------------------------------------------------------------
      // Invalid case
      default: begin 
        bIndex <= 0;
      end
    endcase
  end
end

endmodule