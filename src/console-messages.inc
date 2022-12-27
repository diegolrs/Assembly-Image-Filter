; Messages that are displayed on the console when requesting inputs
.data
CONSOLE_MSG_INPUT_IMG_FILENAME db "Enter input image name (example: catita.bmp): ", 0H
CONSOLE_MSG_OUTPUT_IMG_FILENAME db "Enter output image name (example: catita2.bmp): ", 0H
CONSOLE_MSG_INDEX_COLORBAND db "Enter BGR band index to modify (B=0, G=1, R=2): ",  0H
CONSOLE_MSG_VALUE_TO_ADD db "Enter a integer to add to the choosed band [0, 255]: ", 0H