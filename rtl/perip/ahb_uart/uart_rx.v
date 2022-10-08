`timescale 1ns/1ns

module uart_rx (
    input   wire            clk         ,
    input   wire            rst_n       ,
    output  wire    [7:0]   data_o      ,

    input   wire            full_i      ,
    output  wire            we_o        ,

    input   wire            rx
);

    localparam idle = 2'b00;
    localparam starting = 2'b01;    
    localparam receving = 2'b10;
    localparam endrece = 2'b11;

    reg [7:0]   data_r, data_temp;
    reg [1:0]   state, next_state;
    reg         count_3, count_8;
    reg         end_flag;
    reg [1:0]   uart_count_3;
    reg [2:0]   uart_count_8;
    reg [3:0]   uart_count_bit;
    reg [7:0]   uart_shift_rx;
    reg         uart_parity;
    reg         rece_correct;
    reg         we_r;

    assign we_o = we_r;
    assign data_o = data_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = idle;
        count_3 = 1'b0;
        count_8 = 1'b0;
        end_flag = 1'b0;
        case (state)
            idle : begin
                if (!rx && !full_i) begin
                    next_state = starting;
                    count_3 = 1'b1;                   
                end else begin
                    next_state = idle;
                end
            end 
            starting : begin
                count_3 = 1'b1; 
                if (uart_count_3 == 2'd3) begin
                    next_state = receving;
                end else if (!rx) begin
                    next_state = starting;
                end else begin
                    next_state = idle;
                end             
            end   
            receving : begin
                count_8 = 1'b1;
                if ((uart_count_bit[3] == 1'b1) && (uart_count_8 == 3'd7)) begin
                    next_state = endrece;
                    end_flag = 1'b1;
                end else begin
                    next_state = receving;
                end
            end 
            endrece : begin
                count_8 = 1'b1;
                end_flag = 1'b1;
                if (uart_count_8 == 3'd7) begin
                    next_state = idle;
                    count_8 = 1'b0;
                end else begin
                    next_state = endrece;
                end
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_count_3 <= 2'd0;
        end else if (count_3 && !rx) begin
            uart_count_3 <= uart_count_3 + 2'd1;
        end else begin
            uart_count_3 <= 2'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_count_8 <= 3'd0;
        end else if (count_8) begin
            uart_count_8 <= uart_count_8 + 3'd1;
        end else begin
            uart_count_8 <= 3'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_count_bit <= 4'd0;
        end else if ((uart_count_8 == 3'd7) && !end_flag) begin
            uart_count_bit <= uart_count_bit + 4'd1;
        end else if ((uart_count_8 == 3'd7) && end_flag) begin
            uart_count_bit <= 4'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_shift_rx <= 8'd0;
        end else if ((uart_count_8 == 3'd7) && !end_flag) begin
            uart_shift_rx <= {rx,uart_shift_rx[7:1]};
        end else if ((uart_count_8 == 3'd7) && end_flag) begin
            uart_shift_rx <= 8'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_parity <= 1'b1;
        end else if ((uart_count_8 == 3'd7) && rx && !end_flag) begin
            uart_parity <= ~uart_parity;
        end else if ((uart_count_8 == 3'd7) && end_flag) begin
            uart_parity <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rece_correct <= 1'b0;
        end else if (!count_8) begin
            rece_correct <= 1'b0;
        end else if ((uart_count_8 == 3'd7) && end_flag) begin
            rece_correct <= (rx == uart_parity) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_temp <= 8'd0;
        end else if (!count_8) begin
            data_temp <= 8'd0;
        end else if ((uart_count_8 == 3'd7) && end_flag) begin
            data_temp <= uart_shift_rx;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            we_r <= 1'b0;
        end else if ((uart_count_8 == 3'd0) && rece_correct) begin
            we_r <= 1'b1;
        end else begin
            we_r <= 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_r <= 8'd0;
        end else if ((uart_count_8 == 3'd0) && rece_correct) begin
            data_r <= data_temp;
        end else begin
            data_r <= 8'd0;
        end
    end

endmodule

