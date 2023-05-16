# Truncated Averages - Assembly Language

This project is a demonstration of low-level I/O procedures using string primitives and macros in assembly language. The program asks the user to input 10 signed numbers (not exceeding the size of a 32-bit register). Once the user has entered the numbers, the program displays a list of the inputted numbers, their total sum, and the truncated average.

# Author
Paola Cernada

# Description
The program consists of several macros and procedures to handle user input, display messages, and perform calculations. Here is a brief overview of the key components:

# Macros
mGetString: Displays an input prompt and collects input from the user.
mDisplayString: Displays a string on the console.
mDisplayTotal: Displays a running subtotal of the user's valid numbers.

# Constants
NUM_COUNT: The number of signed numbers to be inputted by the user (set to 10).
MAX_INPUT_LEN: The maximum length of the input string (set to 15).

# Data
The program contains various string messages and output buffers necessary for displaying messages and storing user input.

# Procedures
ReadVal: Converts user input from a string to a signed integer. Verifies the validity of the input and handles error cases.
confirmString: Verifies the validity of each character in the input string and sets the error flag if invalid.
confirm1stChar: Verifies the validity of the first character in the input string and sets the error flag and sign flag accordingly.

# How to Use
Run the program.
Follow the instructions provided to enter 10 signed decimal integers.
After entering all the numbers, the program will display the list of entered numbers, their sum, and the truncated average.
The program will terminate with a farewell message.
Please ensure that the input numbers are small enough to fit inside a 32-bit register.

This program includes an option that numbers each line of user input and displays a running subtotal of the valid numbers entered.

# Requirements
This program is written using Irvine32 library for Assembly language programming. The library must be properly installed and set up to compile and run the program successfully.
