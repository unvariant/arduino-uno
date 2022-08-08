# Keypad
Testing out assembly keypad library written specifically for a [4x4 keypad](https://components101.com/sites/default/files/component_datasheet/4x4%20Keypad%20Module%20Datasheet.pdf).

## Reading from keypad
There are many different ways to read from the keypad. The method I selected allows the keypad to be easily read from left to right and top to bottom.
 1. set all row pins to output and all column pins to input pullup
 2. pull selected row low and the rest of the rows high
 3. read the states of the columns
    - zero indicates a button press in the current row and column
    - one means no button press

## TODO
 - replace key_state_old with key_state_toggle
 - remove unnecessary key_info list
 - remove unnecessary _keypad_update

## Bugs
 - the culprit for any sort of bugs that occur when using the keypad is usually hardware delay and can be solved be adding more nops to the key press detection code
