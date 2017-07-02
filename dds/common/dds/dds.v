// ----------------------------------------------------------------------------
// 
// 
// ----------------------------------------------------------------------------
// quadSampleState:
// ----------------------------------------------------------------------------
//   [00]: sin(x) = 0 , cos(x) = +1
//   [01]: sin(x) = +1 , cos(x)  = 0
//   [10]: sin(x) = 0 , cos(x) = -1
//   [11]: sin(x) = -1 , cos(x)  = 0
// ----------------------------------------------------------------------------
module dds #(
  parameter asz = 11, // Lookup table address bit width
  parameter lsz = 16, // Lookup table output bit width
  parameter psz = 32  // Frequency tune input bit width
)(
  input clk,
  input rst,
  input [(psz-1):0] phaseInc,
  output reg signed [(lsz-1):0] sin,
  output [1:0] quadSampleState
);

// ----------------------------------------------------------------------------
localparam integer MEM_SIZE = $pow(2,asz) - 1;

// ----------------------------------------------------------------------------
// Phase counter increment to generate desired output frequency
// ----------------------------------------------------------------------------
reg [(psz-1):0] phaseCounter;

// ----------------------------------------------------------------------------
always @(posedge clk)
begin
  if(rst) begin
    phaseCounter <= 0;
  end else begin
    phaseCounter <= phaseCounter + phaseInc;
  end
end

// ----------------------------------------------------------------------------
// quadSampleState will be useful for quadrature detection. Watch for the 
// changes of this 2bit signal and act upon those changes.
// ----------------------------------------------------------------------------
assign quadSampleState = phaseCounter[(psz-1):(psz-2)];

// ----------------------------------------------------------------------------
// Address generation from phase counter.
// ----------------------------------------------------------------------------
wire [(asz-1):0] addr_raw = phaseCounter[(psz-3):(psz-asz-2)];
reg [(asz-1):0] addr;
reg sin_sign;

// ----------------------------------------------------------------------------
always @(*)
begin
  if(rst) begin
    addr = 0;
    sin_sign = 1;
  end else begin
    case(phaseCounter[(psz-1):(psz-2)]) 
      2'd0: begin
        addr = addr_raw;
        sin_sign = 1;
      end
      2'd1: begin
        addr = ~addr_raw;
        sin_sign = 1;
      end
      2'd2: begin
        addr = addr_raw;
        sin_sign = 0;
      end
      2'd3: begin
        addr = ~addr_raw;
        sin_sign = 0;
      end
    endcase
  end
end

// ----------------------------------------------------------------------------
// Quarter cycle sine lookup table
// ----------------------------------------------------------------------------    
reg signed [(lsz-1):0] sin_lut[0:MEM_SIZE];
reg signed [(lsz-1):0] memRaw;

initial
begin
  $readmemh("./common/dds/dds_lut.memh",sin_lut);
  // $readmemh("dds_lut.memh",sin_lut); // Use this one for simulation.
end
always @(posedge clk)
begin
  memRaw <= sin_lut[addr];
end

// ----------------------------------------------------------------------------    
always @(*)
begin
  if(sin_sign) begin
    sin = memRaw;
  end else begin
    sin = ~memRaw;
  end
end

endmodule
