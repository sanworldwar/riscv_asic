module ahb_gpio #(
    parameter  AWIDTH = 32,   
    parameter  DWIDTH = 32     
)(
    input   wire                    hclk        ,
    input   wire    		        hresetn     ,

    input   wire    		        hsel_i      ,
    input   wire   	 	            hwrite_i    ,
    input   wire			        hready_i    ,
    input   wire    [2:0]  	        hsize_i     ,
    input   wire    [2:0]  	        hburst_i    ,
    input   wire    [1:0]  	        htrans_i    ,
    input   wire    [DWIDTH-1:0] 	hwdata_i    ,
    input   wire    [AWIDTH-1:0] 	haddr_i     ,	
    
    output  wire                    hreadyout_o ,
    output  wire                    hresp_o     ,
    output  wire    [DWIDTH-1:0]    hrdata_o    ,

    inout   wire    [1:0]           pin_io    
);
    //HTRANS
    localparam HTRANS_IDLE = 2'b00;
    //localparam HTRANS_BUSY = 2'b00;
    localparam HTRANS_NONSEQ = 2'b10;
    //localparam HTRANS_SEQ = 2'b00;  

    //HBURSTS
    localparam HBURSTS_SINGLE = 3'b000;
    //localparam HBURSTS_INCR = 3'b001;
    //localparam HBURSTS_WRAP4 = 3'b010;
    //...... 

    localparam IDLE = 2'b00;
    localparam PREPARE = 2'b01;
    localparam READ = 2'b10;

    // GPIO数据寄存器
    localparam GPIO_DATA = 4'h0;
    // GPIO控制寄存器
    localparam GPIO_CTRL = 4'h4;

    reg                 hwrite_r    ;
    reg [2:0]           hsize_r     ;
    reg [2:0]           hburst_r    ;
    reg [1:0]           htrans_r    ;
    reg [AWIDTH-1:0] 	haddr_r     ;

    always @(posedge hclk or negedge hresetn) begin
        if(!hresetn) begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end else if (hsel_i) begin
            if (hready_i) begin
                hwrite_r <= hwrite_i;
                hsize_r <= hsize_i;
                hburst_r <= hburst_i; //一直为single
                htrans_r <= htrans_i;
                haddr_r <= haddr_i;
            end
        end else begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end
    end

    // 每2位控制1个IO的模式，最多支持16个IO
    // 0: 高阻，1：输出，2：输入
    reg [DWIDTH-1:0]    gpio_ctrl;
    // 输入输出数据
    reg [DWIDTH-1:0]    gpio_data;


    wire [1:0]   gpio_en;    

    reg [1:0]   state, next_state;

    wire gpio_cs = hsel_i && (hburst_r == HBURSTS_SINGLE) && (htrans_r == HTRANS_NONSEQ);
    wire gpio_read = gpio_cs && !hwrite_r;
    wire gpio_write = gpio_cs && hwrite_r;
    
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        case (state)
            IDLE : begin
                if (hsel_i) begin
                    next_state = PREPARE;
                end else begin
                    next_state = IDLE;
                end
            end
           PREPARE : begin
                if (hsel_i) begin
                    if (gpio_read) begin
                        next_state = PREPARE; //PREPARE   hready_i=1时会无效读，lsu此时地址未备好，hsel_i至少拉低一周期，下同
                    end else if (gpio_write) begin 
                        next_state = PREPARE; //PREPARE
                    end else begin
                        next_state = PREPARE;
                    end 
                end else begin
                    next_state = IDLE;
                end
            end      
        endcase
    end
    
    wire    [1:0]  io_pin;

    assign io_pin = pin_io;

    generate
        genvar i;
        for (i=0; i<2; i=i+1) begin : gpio
            assign pin_io[i] = gpio_en[i] ? gpio_data[i] : 1'bz;
        end
    endgenerate


    // 写寄存器
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            gpio_data <= {DWIDTH{1'b0}};
            gpio_ctrl <= {DWIDTH{1'b0}};
        end else if (gpio_write && (state == PREPARE)) begin
            case (haddr_r[3:0])
                GPIO_CTRL: begin
                    gpio_ctrl <= hwdata_i;
                end
                GPIO_DATA: begin
                    gpio_data <= hwdata_i;
                end
                default: begin
                
                end                    
            endcase
        end else begin
            if (gpio_ctrl[1:0] == 2'b10) begin
                gpio_data[0] <= io_pin[0];
            end
            if (gpio_ctrl[3:2] == 2'b10) begin
                gpio_data[1] <= io_pin[1];
            end
        end
    end

//    always @(posedge hclk or negedge hresetn) begin
//        if (!hresetn) begin
//            gpio_en = 2'b00;
//        end else begin
//            if (gpio_ctrl[1:0] == 2'b01) begin
//                gpio_en[0] <= 1'b1;
//            end else begin
//                gpio_en[0] <= 1'b0;
//            end
//            if (gpio_ctrl[3:2] == 2'b01) begin
//                gpio_en[1] <= 1'b1;
//            end else begin
//                gpio_en[1] <= 1'b0;
//            end
//        end
//    end

    generate
        genvar j;
        for (j=0; j<2; j=j+1) begin : gpio_en_data
            assign gpio_en[j] = gpio_ctrl[j*2 +: 2] == 2'b01;
        end
    endgenerate

    reg [DWIDTH-1:0]    hrdata_r;

    // read regs
    always @ (*) begin
        if (gpio_read && (state == PREPARE)) begin
            case (haddr_r[3:0])
                GPIO_CTRL: begin
                    hrdata_r = gpio_ctrl;
                end
                GPIO_DATA: begin
                    hrdata_r = gpio_data;
                end
                default: begin
                    hrdata_r = {DWIDTH{1'b0}};
                end
            endcase
        end
        else begin
            hrdata_r = {DWIDTH{1'b0}};
        end
    end

    assign hrdata_o = hrdata_r;
    assign hreadyout_o = ((next_state == IDLE) || (next_state == PREPARE));
    assign hresp_o = 1'b0; //ok


endmodule
