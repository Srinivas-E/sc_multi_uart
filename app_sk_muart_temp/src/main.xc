#include <xs1.h>
#include <platform.h>
#include <print.h>
#include "multi_uart_common.h"
#include "multi_uart_helper.h"
#include "multi_uart_rxtx.h"
#include <stdio.h>
#include <stdlib.h>
#include <syscall.h>

/* define UART_CORE for Motor Control Board as 1 */
#define UART_CORE   1
#define BUFFER_SIZE 23971

on tile[1]: s_multi_uart_tx_ports uart_tx_ports = { XS1_PORT_8B };
on tile[1]: s_multi_uart_rx_ports uart_rx_ports = { XS1_PORT_8A };
/* Define 1 bit external clock */
on tile[1]: in port p_uart_ref_ext_clk = XS1_PORT_1F;

on tile[1]: clock clk_uart_tx = XS1_CLKBLK_4;
on tile[1]: clock clk_uart_rx = XS1_CLKBLK_5;


/* Do simple test */
#define SIMPLE_TEST



/**
 * Basic test of the TX server - will transmit an identifying message on each UART channel
 */
void uart_tx_test(streaming chanend cUART)
{
    char test_str[8][29] = {"UART Channel 1 Test String\n\0",
        "UART Channel 2 Test String\n\0",
        "UART Channel 3 Test String\n\0",
        "UART Channel 4 Test String\n\0",
        "UART Channel 5 Test String\n\0",
        "UART Channel 6 Test String\n\0",
        "UART Channel 7 Test String\n\0",
        "UART Channel 8 Test String\n\0"};
        
    
    unsigned rd_ptr[8] = {0,0,0,0,0,0,0,0};
    unsigned char readBuffer[BUFFER_SIZE];

    char temp = 0;
    int chan_id = 0;
    unsigned baud_rate = 115200;
    int buffer_space = 0;
    
    timer t;
    unsigned int ts;
    /* configure UARTs */
    for (int i = 0; i < 8; i++)
    {
        if ((int)baud_rate <= 225)
           baud_rate = 225;
       
       printintln(baud_rate);
       
       if (uart_tx_initialise_channel( i, even, sb_1, start_0, baud_rate, 8 ))
       {
           printstr("Invalid baud rate for tx channel ");
           printintln(i);
       }
       //baud_rate >>= 1;
    }
   read_from_file("test4.txt", readBuffer, BUFFER_SIZE);


   while (temp != MULTI_UART_GO)
   {
       cUART :> temp;
   }
   cUART <: 1;
   
   t :> ts;
   ts += 20 * 100000000; // 20 second

   while (rd_ptr[chan_id]<BUFFER_SIZE)
   {

       buffer_space = uart_tx_put_char(chan_id, (unsigned int)readBuffer[rd_ptr[chan_id]]); //(unsigned int)test_str[chan_id][rd_ptr[chan_id]]);
       if (buffer_space != -1)


               rd_ptr[chan_id]++;

   }
}

/**
 * Basic test of the RX - will print out a character at a time - will break on continuous 
 * data because of the prints
 */
void uart_rx_test(streaming chanend cUART)
{
    unsigned uart_char, temp;
    char receive_buf[100] = {'u'};
    char go;
    unsigned int buf_ptr = 0;
    unsigned baud_rate = 115200;
    int fd1;
    
    timer t;
    unsigned ts;
    
    
    /* configure UARTs */
    for (int i = 0; i < 8; i++)
    {
        if ((int)baud_rate <= 225)
            baud_rate = 225;
        if (uart_rx_initialise_channel( i, even, sb_1, start_0, baud_rate, 8 ))
        {
            printstr("Invalid baud rate for rx channel ");
            printintln(i);
        }
        //baud_rate /= 2;
    }
    
    //:xc_release_uart
    /* release UART rx thread */
    do { cUART :> go; } while (go != MULTI_UART_GO);
    cUART <: 1;
    //:
    
    t :> ts;
    ts += 20 * 100000000; // 20 second
    
    /* main loop */
    while (1)
    {
        char chan_id;
        
        select
        {
            
            case cUART :> chan_id:
                /* get character over channel */
                uart_char = (unsigned)uart_rx_grab_char((unsigned)chan_id);
        
                /* process received value */
                temp = uart_char;
                
                if (chan_id == 0)
                {
                    if (uart_rx_validate_char( chan_id, uart_char ) == 0)
                    {
                        receive_buf[buf_ptr] = (char)uart_char;
                        buf_ptr++;
                        if (buf_ptr >= 100)
                        {
                            buf_ptr = 0;
                            for (int i = 0; i < 100; i++)
                                printchar(receive_buf[i]);
                        }
                        printchar(uart_char);
                    }
                    else printstr("Invalid\n");
                }
                break;
        }
        write_to_file("test1.txt", receive_buf, 100);


    }
}

void dummy()
{
    while (1);
}

/**
 * Top level main for multi-UART demonstration
 */
int main(void)
{
    streaming chan cTxUART;
    streaming chan cRxUART;
    streaming chan cRxBuf;
    
    par
    {
        /* use all 8 threads */
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        
        #ifdef SIMPLE_TEST
        /* TX test thread */
        on stdcore[UART_CORE]: uart_tx_test(cTxUART);
        
        /* RX test thread */
        on stdcore[UART_CORE]: uart_rx_test(cRxUART);
        #endif
        
        
        /* run the multi-uart RX & TX with a common external clock - (2 threads) */
        on tile[UART_CORE]: run_multi_uart_rxtx( cTxUART,  uart_tx_ports, cRxUART, uart_rx_ports, clk_uart_rx,p_uart_ref_ext_clk , clk_uart_tx);
    }
    return 0;
}

