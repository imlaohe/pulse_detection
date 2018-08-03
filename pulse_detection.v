`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/05 15:33:14
// Design Name:
// Module Name: pulse_detection
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module pulse_detection (
	//input        pl_clk      ,
	output        adc_clk          ,
	input  [ 1:0] gpio_pd_ctrl     ,
	//work mode
	output [ 1:0] work_mode        ,
	//adc
	input  [ 7:0] ADC_DI_P         ,
	input  [ 7:0] ADC_DI_N         ,
	input  [ 7:0] ADC_DID_P        ,
	input  [ 7:0] ADC_DID_N        ,
	input  [ 7:0] ADC_DQ_P         ,
	input  [ 7:0] ADC_DQ_N         ,
	input  [ 7:0] ADC_DQD_P        ,
	input  [ 7:0] ADC_DQD_N        ,
	input         ADC_DCLK_P       ,
	input         ADC_DCLK_N       ,
	input         ADC_OR_P         ,
	input         ADC_OR_N         ,
	output        ADC_DCLK_RST     ,
	output        ADC_PD           ,
	output        ADC_PDQ          ,
	//din ram1
	output [ 7:0] din_buffer1_addra,
	output        din_buffer1_wea  ,
	output [31:0] din_buffer1_dina ,
	input  [31:0] din_buffer1_douta,
	//din ram2
	output [ 7:0] din_buffer2_addra,
	output        din_buffer2_wea  ,
	output [31:0] din_buffer2_dina ,
	input  [31:0] din_buffer2_douta,
	//ram1 to arm
	output [12:0] ram1_to_arm_addra,
	output [ 3:0] ram1_to_arm_wea  ,
	output [31:0] ram1_to_arm_dina ,
	output        pulse_data_valid1,
	//ram2
	output [12:0] ram2_to_arm_addra,
	output [ 3:0] ram2_to_arm_wea  ,
	output [31:0] ram2_to_arm_dina ,
	output        pulse_data_valid2,
	//command_ram
	(* keep="true" *)
	output [ 7:0] command_wen      ,
	output        command_enb      ,
	output        command_rstb     ,
	(* keep="true" *)
	output [31:0] command_addr     ,
	output [63:0] command_2_arm    ,
	input  [63:0] command          ,
	//led
	output        led0             ,
	output        led1             ,
	output        led2             ,
	output        led3             ,
	//
	output        i_pulse_valid    ,
	output        q_pulse_valid
);
	
	//ad ctrl signal
	assign ADC_DCLK_RST = 1'b0;
	assign ADC_PD       = gpio_pd_ctrl[1];
	assign ADC_PDQ      = gpio_pd_ctrl[0];

	//pulse valid signal
	assign i_pulse_valid = pulse_data_valid1;
	assign q_pulse_valid = pulse_data_valid2;

	



	//wire [ 1:0] work_mode  ;
	(* keep="true" *)
	wire [7:0] threshold1;
	(* keep="true" *)
	wire [ 7:0] threshold2 ;
	wire [63:0] timecounter;

	wire pulse_led_i;
	wire pulse_led_q;
	
	assign led0 = ADC_PD;
	assign led1 = ADC_PDQ;
	assign led2 = pulse_led_i;
	assign led3 = pulse_led_q;

	assign command_enb  = 1'b1;
	assign command_rstb = 1'b0;

	wire [10:0] ram1_to_arm_addra_local;
	assign ram1_to_arm_addra = {ram1_to_arm_addra_local,2'b00};
	wire ram1_to_arm_wea_local;
	assign ram1_to_arm_wea = {4{ram1_to_arm_wea_local}};

	wire [10:0] ram2_to_arm_addra_local;
	assign ram2_to_arm_addra = {ram2_to_arm_addra_local,2'b00};
	wire ram2_to_arm_wea_local;
	assign ram2_to_arm_wea = {4{ram2_to_arm_wea_local}};

	(* keep="true" *)
		wire [7:0] adc_di;
	(* keep="true" *)
	wire [7:0] adc_did;
	(* keep="true" *)
	wire [7:0] adc_dq;
	(* keep="true" *)
	wire [7:0] adc_dqd;
	(* keep="true" *)
	wire       adc_or ;

	adc_interface i_adc_interface (
		.ADC_DI_P  (ADC_DI_P  ),
		.ADC_DI_N  (ADC_DI_N  ),
		.ADC_DID_P (ADC_DID_P ),
		.ADC_DID_N (ADC_DID_N ),
		.ADC_DQ_P  (ADC_DQ_P  ),
		.ADC_DQ_N  (ADC_DQ_N  ),
		.ADC_DQD_P (ADC_DQD_P ),
		.ADC_DQD_N (ADC_DQD_N ),
		.ADC_DCLK_P(ADC_DCLK_P),
		.ADC_DCLK_N(ADC_DCLK_N),
		.ADC_OR_P  (ADC_OR_P  ),
		.ADC_OR_N  (ADC_OR_N  ),
		.adc_clk   (adc_clk   ),
		.adc_di    (adc_di    ),
		.adc_did   (adc_did   ),
		.adc_dq    (adc_dq    ),
		.adc_dqd   (adc_dqd   ),
		.adc_or    (adc_or    )
	);

	(* keep="true" *)
		wire [63:0] time_value;

	command_interface i_command_interface (
		.clk          (adc_clk      ),
		.command_wen  (command_wen  ),
		.command_addr (command_addr ),
		.command_2_arm(command_2_arm),
		.command      (command      ),
		.work_mode    (work_mode    ),
		.time_value   (time_value   ),
		.threshold1   (threshold1   ),
		.threshold2   (threshold2   )
	);



	detection i_detection (
		.adc_clk          (adc_clk                ),
		.threshold1       (threshold1             ),
		.threshold2       (threshold2             ),
		.adc_di           (adc_di                 ),
		.adc_did          (adc_did                ),
		.adc_dq           (adc_dq                 ),
		.adc_dqd          (adc_dqd                ),
		.work_mode        (work_mode              ),
		.time_value       (time_value             ),
		.din_buffer1_addra(din_buffer1_addra      ),
		.din_buffer1_wea  (din_buffer1_wea        ),
		.din_buffer1_dina (din_buffer1_dina       ),
		.din_buffer1_douta(din_buffer1_douta      ),
		.din_buffer2_addra(din_buffer2_addra      ),
		.din_buffer2_wea  (din_buffer2_wea        ),
		.din_buffer2_dina (din_buffer2_dina       ),
		.din_buffer2_douta(din_buffer2_douta      ),
		.pulse_led_i      (pulse_led_i            ),
		.pulse_led_q      (pulse_led_q            ),
		.ram1_to_arm_addra(ram1_to_arm_addra_local),
		.ram1_to_arm_wea  (ram1_to_arm_wea_local  ),
		.ram1_to_arm_dina (ram1_to_arm_dina       ),
		.pulse_data_valid1(pulse_data_valid1      ),
		.ram2_to_arm_addra(ram2_to_arm_addra_local),
		.ram2_to_arm_wea  (ram2_to_arm_wea_local  ),
		.ram2_to_arm_dina (ram2_to_arm_dina       ),
		.pulse_data_valid2(pulse_data_valid2      )
	);



endmodule
