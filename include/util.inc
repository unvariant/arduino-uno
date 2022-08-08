    .ifndef _UTIL_INC_
    .define _UTIL_INC_

.macro ldist
    ldi @0, @1
    st  @2, @0
.endmacro

.macro ldw
    ldi r@0+1, HIGH(@1)
    ldi r@0, LOW(@1)
.endmacro
    
    .endif
