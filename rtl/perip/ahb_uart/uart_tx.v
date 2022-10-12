`timescale 1ns/1ns

module uart_tx (
    input   wire            clk     ,
    input   wire            rst_n   ,
    input   wire    [7:0]   data_i  ,

    input   wire            empty_i ,    
    output  wire            re_o    ,

    output  wire            tx      
);
    localparam idle = 3'b000;
    localparam prepare = 3'b001;
    localparam ready = 3'b010;
    localparam starting = 3'b011;    
    localparam sending = 3'b100;
    localparam endsend = 3'b101;

    reg         re_r;
    reg         re_valid;   
    reg [8:0]   uart_shift_tx;
    reg         start, shift;
    reg [2:0]   uart_cnt;
    reg [2:0]   state, next_state;
    reg         end_flag;
    reg         uart_parity;

    assign tx = uart_shift_tx[0];

    assign re_o = re_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = idle;
        re_r = 1'b0;
        re_valid = 1'b0;
        start = 1'b0;
        shift = 1'b0;
        end_flag = 1'b0;
        case (state)
            idle : begin
                if (!empty_i) begin
                    re_r = 1'b1;
                    next_state = prepare;
                end else begin
                    next_state = idle;
                end
            end
            prepare : begin  //因为读使能ren会打一拍
                next_state = ready;                
            end            
            ready : begin    //因为异步fifo读会打一拍
                re_valid = 1'b1;
                next_state = starting;                
            end
            starting : begin
                next_state = sending; 
                start = 1'b1;
            end
            sending : begin
                shift = 1'b1;
                if (uart_cnt == 3'd7) begin
                    next_state = endsend;
                end else begin
                    next_state = sending;
                end
            end
            endsend : begin
                end_flag = 1'b1; 
                next_state = idle;              
            end
        endcase
    end



    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_shift_tx <= 9'h1ff;
        end else if (re_valid) begin
            uart_shift_tx <= {data_i,1'b1};
        end else if (start) begin
            uart_shift_tx <= {uart_shift_tx[8:1],1'b0}; 
        end else if (shift) begin
            uart_shift_tx <= uart_shift_tx >> 1;
        end else if (end_flag) begin
            uart_shift_tx[0] <= uart_parity;
        end else begin
            uart_shift_tx <= 9'h1ff;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_cnt <= 3'd0;
        end else if (shift) begin
            uart_cnt <= uart_cnt + 3'd1;
        end else begin
            uart_cnt <= 3'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_parity <= 1'd1;
        end else if (shift && uart_shift_tx[1]) begin
            uart_parity <= !uart_parity;
        end else if (end_flag) begin
            uart_parity <= 1'd1;
        end
    end

endmodule