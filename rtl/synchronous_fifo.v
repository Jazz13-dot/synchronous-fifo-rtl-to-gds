module synchronous_fifo #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 8
)(
  input  wire                  clk,
  input  wire                  rst,
  input  wire                  wr_en,
  input  wire                  rd_en,
  input  wire [DATA_WIDTH-1:0] data_in,
  output reg  [DATA_WIDTH-1:0] data_out,
  output wire                  full,
  output wire                  empty
);

  localparam PTR_WIDTH = $clog2(DEPTH);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  reg [PTR_WIDTH-1:0]  wr_ptr;
  reg [PTR_WIDTH-1:0]  rd_ptr;
  reg [PTR_WIDTH:0]    count;

  wire write_accepted;
  wire read_accepted;

  assign full  = (count == DEPTH);
  assign empty = (count == 0);

  assign write_accepted = wr_en && !full;
  assign read_accepted  = rd_en && !empty;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr   <= 0;
      rd_ptr   <= 0;
      count    <= 0;
      data_out <= 0;
    end
    else begin

      // Write operation
      if (write_accepted) begin
        mem[wr_ptr] <= data_in;

        if (wr_ptr == DEPTH-1)
          wr_ptr <= 0;
        else
          wr_ptr <= wr_ptr + 1'b1;
      end

      // Read operation
      if (read_accepted) begin
        data_out <= mem[rd_ptr];

        if (rd_ptr == DEPTH-1)
          rd_ptr <= 0;
        else
          rd_ptr <= rd_ptr + 1'b1;
      end

      // FIFO occupancy
      case ({write_accepted, read_accepted})

        2'b10: begin
          count <= count + 1'b1;
        end

        2'b01: begin
          count <= count - 1'b1;
        end

        2'b11: begin
          count <= count;
        end

        2'b00: begin
          count <= count;
        end

      endcase
    end
  end

endmodule


