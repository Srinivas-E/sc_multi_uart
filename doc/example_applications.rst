Example Applications
====================

This section discusses the demonstration application that uses multi-uart module.

**app_slicekit_com_demo** Application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This application is available as ``app_slicekit_com_demo`` under ``sc_multi_uart`` component directory. See the evaluation platforms section of this document for required hardware.
    
.. _sec_demo_tools:

Required Software Tools
-----------------------

The following tools should be installed on the host system in order to run this application

    * For Win 7: Hercules Setup Utility by HW-Group
      http://www.hw-group.com/products/hercules/index_en.html
    * For MAC users: SecureCRT7.0 
      http://www.vandyke.com/download/securecrt/

.. _sec_slice_card_connection:

Build options
--------------

``app_slicekit_com_demo`` application use the following modules in order to achive its desired functionality.

    * **sc_multi_uart**: utilizes TX and RX servers provided by the component
    * **sc_util**: uses ``module_xc_ptr`` functions to perform pointer related arithmetic such as reading from and writing into memory

This demo application is built by default for XP-SKC-L2 Slicekit Core board, SQAURE connector type. This application can also be built for other compatible connectors as follows:

To build for STAR connector, make the following changes:

.. list-table::
    :header-rows: 1
    
    * - File
      - Original Value
      - New Value
    * - ``src/main.xc``
      - ``#define SK_MULTI_UART_SLOT_SQUARE 1``
      - ``#define SK_MULTI_UART_SLOT_STAR 1``
    * - ``Makefile``
      - ``TARGET = SK_MULTI_UART_SLOT_SQUARE``
      - ``TARGET = SK_MULTI_UART_SLOT_STAR``

To build for TRIANGLE connector, make the following changes:

.. list-table::
    :header-rows: 1
    
    * - File
      - Original Value
      - New Value
    * - ``src/main.xc``
      - ``#define SK_MULTI_UART_SLOT_SQUARE 1``
      - ``#define SK_MULTI_UART_SLOT_TRIANGLE 1``
    * - ``Makefile``
      - ``TARGET = SK_MULTI_UART_SLOT_SQUARE``
      - ``TARGET = SK_MULTI_UART_SLOT_TRIANGLE``

The module requires 8-bit ports for both UART transmit and UART receive ports. Upon selection of an appropriate type of connector, the port declarations for the multi-uart component are derived automatically from the xn file.

This application contains following *xn* files in ``src`` folder under ``app_slicekit_com_demo`` directory.
    * SK_MULTI_UART_SLOT_SQUARE.xn file configures 1 bit port *XS1_PORT_1F* for muart external clock, 8 bit port *XS1_PORT_8B* for muart tx and *XS1_PORT_8A* for muart rx on tile 1
    * SK_MULTI_UART_SLOT_STAR.xn file configures 1 bit port *XS1_PORT_1L* for muart external clock, 8 bit port *XS1_PORT_8D* for muart tx and *XS1_PORT_8C* for muart rx on tile 0
    * SK_MULTI_UART_SLOT_TRIANGLE.xn file configures 1 bit port *XS1_PORT_1F* for muart external clock, 8 bit port *XS1_PORT_8B* for muart tx and *XS1_PORT_8A* for muart rx on tile 0

Hardware Settings
-----------------

Voltage Levels
++++++++++++++

The XA-SK-UART8 Slice Card has two options for uart signalling levels:
    * CMOS TTL
    * RS-232
    
By default, this Slice Card uses the RS-232 levels. In order to use the CMOS TTL levels, short J3 pins (25-26) of the Slice Card. All 8 UART channels must use the same voltage setting. 

Uart Header Connections
+++++++++++++++++++++++

When using the RS-232 levels, UART device pins must be connected to J4 of XA-SK-UART8 Slice Card.

When using TTL levels, UART device pins must be connected to J3 of Multi-UART Slice Card (along with J3 25-26 pins shorted). UART information of XA-SK-UART8 Slice Card is as follows:

.. image:: images/XA-SK-UART8-SquareConnected.png
    :align: center

.. _table_connector_breakout:

XA-SK-UART8 Slice Card for Demo Applications 

=================== ===================== =====================
**UART Identifier** **J3/J4 Pin no.(TX)** **J3/J4 Pin no.(RX)**
=================== ===================== =====================
0                   1                     2
1                   5                     6
2                   7                     8 
3                   11                    12
4                   13                    14
5                   17                    18
6                   19                    20
7                   23                    24
=================== ===================== =====================

Optionally, Uart #0 may be accessed via the DB9 connector on the end of the Slice Card and thus connected directly to a PC COM port.

Application Configuration
-------------------------

``app_slicekit_com_demo`` application configuration is done utilising the defines listed out below:

.. literalinclude:: app_slicekit_com_demo/src/common.h
    :start-after: //:demo_app_config
    :end-before:  //:
    
    
Application Description
-----------------------

The demonstration application shows a typical application structure that would employ the Multi-UART module. 

In addition to the two Multi-UART threads used by ``sc_multi_uart``, the application utilises one more thread to manage UART data from transmit and receive threads. 

UART data received may be user commands to perform various user actions or transaction data related to a user action (see :ref:`sec_demo_features`).

The application operates a state machine to differentiate between user commands and user data, and provides some buffers to hold data received from UARTs. When the RX thread receives a character over the UART it saves it into the local buffer. A state handler operates on the received data to identify its type and performs relevant actions .

Generally, the data token received by RX buffering thread tells which UART channel a character has been received on. The thread then extracts this character out of the buffer slot, validates it utilising the provided validation function and inserts it into a larger, more comprehensive buffer.The RX buffering is implemented as an example only and may not be necessary for other applications. The TX thread already provides some buffering supported at the component level. 

The TX handler operates by polling the buffer which is filled by the Rx handler. When an entry is seen, Tx handler pulls it from the buffer and perform an action based on current state of the handler.

The channel for the TX thread is primarily used for reconfiguration. This is discussed in more detail in :ref:`sec_reconf_rxtx`. Specific usage of the API is also discussed in :ref:`sec_interfacing_tx` and :ref:`sec_interfacing_rx`.


.. _sec_demo_usage:

Quick Start Guide
-----------------

**FIXME: add link for quickstart guide**

.. _sec_demo_features:

Interacting with the Application
--------------------------------

Command Interface
+++++++++++++++++

The application provides the following commands to interact with it:

    * e - in this mode, an entered character is echoed back on the console. In order to come out of this mode, press the ``Esc`` key
    * r - reconfigure UART for a different baud rate
    * g - upload a file via console option; the uploaded file should be of size < 1024 characters and crc_appender application should be run on the file prior to file upload (see :ref:`sec_crc_appender_usage`)
    * p - this option prints previously uploaded file via get option on to the console; at the end, it displays timing consumed (in milliseconds) to upload a file and transmit back the same file to console
    * h - displays user menu
    
    At any instance ``Esc`` key can be pressed to revert back to user menu.


.. _sec_crc_appender_usage:

CRC Calculation Application
+++++++++++++++++++++++++++

**FIXME:This application is to be tested and added to test folder, with more usage guidelines** To upload a file via the UART console, select any file with size < 1024 bytes. If the file size is greater than this size, only the first 1024 bytes are used. This limitation is due to buffer length constraints of the application, in order to store the received file and send it back when requested.

An application executable ``crc_appender`` which is available in ``test`` folder should be executed in order to calculate CRC of the selected file. This application appends calculated crc at the end of the file. ``app_slicekit_com_demo`` calculates CRC of the received bytes and checks it against the CRC value calculated by ``crc_appender`` application. This ensures all the user uploaded data is integrity checked.

Sample Usage:

   ::

       crc_appender <file_name>



Makefiles
---------

The main Makefile for the project is in the application directory. This file specifies build options and used modules. The Makefile uses the common build infrastructure in ``xcommon``. This system includes the source files from the relevant modules and is documented within ``xcommon``.


Using Command Line Tools
------------------------

To build from the command line, change to `app_slicekit_com_demo` directory and execute the command:

   ::

       xmake all

Open the XMOS command line tools (Desktop Tools Prompt) and execute the following command:

   ::

       xflash <binary>.xe

