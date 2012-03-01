Getting started
===============

Installation
------------

The XMOS ethernet package can be found at git repository:
  
       git://github.com/xcore/sc_multi_uart.git

Additionally, the package requires sc_ethernet, sc_xtcp components and xcommon packages to build.

Once the zipfiles are downloaded you can install, build and use the software.


Building with the XDE
~~~~~~~~~~~~~~~~~~~~~

To install the software, open the XDE (XMOS Development Tools) and
follow these steps:

#. Choose `File` |submenu| `Import`.

#. Choose `General` |submenu| `Existing Projects into Workspace` and
   click **Next**.

#. Click **Browse** next to `Select archive file` and select
   the file firmware ZIP file.

#. Make sure the projects you want to import are ticked in the
   `Projects` list. Import all the components and whichever
   applications you are interested in.

#. Click **Finish**.


To build, select `app_serial_to_ethernet_demo` in the Project Explorer and click the **Build** icon.

Building from the command line
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To install, unzip the package zip.

To build, change into the app_serial_to_ethernet_demo directory and
execute the command:

::

       xmake all

Makefiles
~~~~~~~~~

The main Makefile for the project is in the application directory. 
This file specifies build
options and used modules. The Makefile uses the common build
infrastructure in ``module_xmos_common``. This system includes
the source files from the relevant modules and is documented within
``module_xmos_common``.

Installing the application onto flash
-------------------------------------

To upgrade the firmware you must, firstly:


#. Plug the hardware board into your computer.

#. Connect the XTAG-2 to hardware board and plug the XTAG-2
   into your PC or Mac.


Using the XMOS Development Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To upgrade the flash from the XDE, follow these steps:


#. Start the XMOS Development Environment and open a workspace.

#. Choose *File* |submenu| *Import* |submenu| *C/XC* |submenu| *C/XC Executable*

#. Click **Browse** and select the new firmware (XE) file.

#. Click **Next** and **Finish**.

#. A Debug Configurations window is displayed. Click **Close**.

#. Choose *Run* |submenu| *Run Configurations*.

#. Double-click *Flash Programmer* to create a new
   configuration.

#. Browse for the XE file in the *Project* and
   *C/XC Application* boxes.

#. Ensure the *XTAG-2* device appears in the adapter
   list.

#. Click **Run**.


Using Command Line Tools
~~~~~~~~~~~~~~~~~~~~~~~~


#. Open the XMOS command line tools (Desktop Tools Prompt) and
   execute the following command:

   ::

       xflash <binary>.xe



