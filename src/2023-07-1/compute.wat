(module
  (memory (export "mem") 1)

  (func $valueCard (param $char i32) (result i32)
    i32.const 0x41 ;; A
    local.get $char
    i32.eq
    if
      i32.const 14
      return
    end

    i32.const 0x4B ;; K
    local.get $char
    i32.eq
    if
      i32.const 13
      return
    end

    i32.const 0x51 ;; Q
    local.get $char
    i32.eq
    if
      i32.const 12
      return
    end

    i32.const 0x4A ;; J
    local.get $char
    i32.eq
    if
      i32.const 11
      return
    end

    i32.const 0x54 ;; T
    local.get $char
    i32.eq
    if
      i32.const 10
      return
    end

    i32.const 0x32 ;; 2
    local.get $char
    i32.le_u
    i32.const 0x39 ;; 9
    local.get $char
    i32.ge_u
    i32.and
    if
      local.get $char
      i32.const 0x30 ;; 0
      i32.sub
      return
    end

    i32.const 0
  )

  (func $valueHand (param $handPointer i32)
    (local $i i32)
    (local $j i32)
    (local $char i32)
    (local $count i32)
    
    loop $li
      local.get $i
      i32.const 5
      i32.lt_u
      if
        local.get $handPointer
        local.get $i
        i32.add
        i32.load8_u
        local.set $char

        i32.const 5
        local.get $i
        i32.sub
        local.get $handPointer
        i32.add
        i32.const 8
        i32.add
        local.get $char
        call $valueCard
        i32.store8

        i32.const 0
        local.set $j
        loop $lj
          local.get $j
          i32.const 5
          i32.lt_u
          if
            local.get $handPointer
            local.get $j
            i32.add
            i32.load8_u
            local.get $char
            i32.eq
            if
              local.get $count
              i32.const 1
              i32.add
              local.set $count
            end

            local.get $j
            i32.const 1
            i32.add
            local.set $j
            br $lj
          end
        end

        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $li
      end
    end

    local.get $handPointer
    i32.const 15
    i32.add
    local.get $count
    i32.store8
  )

  (func $valueHands
    (local $handCount i32)
    (local $handPointer i32)
    i32.const 0
    i32.load16_u
    local.set $handCount

    i32.const 8
    local.set $handPointer

    loop $l
      local.get $handCount
      i32.const 0
      i32.ne
      if
        local.get $handPointer
        call $valueHand
      
        local.get $handPointer
        i32.const 16
        i32.add
        local.set $handPointer

        local.get $handCount
        i32.const 1
        i32.sub
        local.set $handCount

        br $l
      end
    end
  )

  (func $mergeSubArrays
    (param $pointer i32)
    (param $aLength i32)
    (param $bLength i32)
    (param $scratchSpace i32)

    (local $i i32)
    (local $j i32)
    (local $k i32)
    (local $iMax i32)
    (local $jMax i32)
    (local $kMax i32)


    ;; copy both arrays to scratch space
    local.get $scratchSpace
    local.get $pointer
    local.get $aLength
    local.get $bLength
    i32.add
    i32.const 2
    i32.mul
    memory.copy

    ;; merge copy back to original space
    local.get $pointer
    local.set $i

    local.get $pointer
    local.get $aLength
    local.get $bLength
    i32.add
    i32.const 2
    i32.mul
    i32.add
    local.set $iMax

    local.get $scratchSpace
    local.set $j

    local.get $scratchSpace
    local.get $aLength
    i32.const 2
    i32.mul
    i32.add
    local.tee $k
    local.tee $jMax

    local.get $bLength
    i32.const 2
    i32.mul
    i32.add
    local.set $kMax

    loop $l
      block $b
        ;; If we've finished copying everything from a-array, then what's untouched from b-array is already in order
        local.get $j
        local.get $jMax
        i32.eq
        br_if $b

        ;; If we've finished copying everything from b-array, then copy the rest of a-array to the end
        local.get $k
        local.get $kMax
        i32.eq
        if
          local.get $i
          local.get $j
          local.get $jMax
          local.get $j
          i32.sub
          memory.copy
          br $b
        end

        local.get $j
        i32.load16_u
        i32.const 16 ;; The size of each hand record
        i32.mul
        i32.const 16 ;; The offset to the value struct, including the 8 bytes for the hands count
        i32.add
        i64.load
        
        local.get $k
        i32.load16_u
        i32.const 16 ;; The size of each hand record
        i32.mul
        i32.const 16 ;; The offset to the value struct, including the 8 bytes for the hands count
        i32.add
        i64.load

        i64.lt_u
        if
          local.get $i
          local.get $j
          i32.const 2
          memory.copy

          local.get $j
          i32.const 2
          i32.add
          local.set $j
        else
          local.get $i
          local.get $k
          i32.const 2
          memory.copy

          local.get $k
          i32.const 2
          i32.add
          local.set $k
        end

        local.get $i
        i32.const 2
        i32.add
        local.set $i
        br $l
      end
    end
  )

  (func $sortHands
    (local $handCount i32)
    (local $sortPointer i32)
    (local $mergeSpacePointer i32)
    (local $i i32)
    (local $bArrayLen i32)
    (local $subListSize i32)

    i32.const 0
    i32.load16_u
    local.set $handCount

    i32.const 16 ;; size of hand struct
    local.get $handCount
    i32.mul
    i32.const 8 ;; offset to first hand
    i32.add
    local.set $sortPointer

    i32.const 18 ;; size of hand struct + size of sort index
    local.get $handCount
    i32.mul
    i32.const 8 ;; offset to first hand
    i32.add
    local.set $mergeSpacePointer

    ;; Set up an initial order
    loop $l
      local.get $i
      local.get $handCount
      i32.lt_u
      if
        local.get $i
        i32.const 2
        i32.mul
        local.get $sortPointer
        i32.add
        local.get $i

        i32.store16
      
        local.get $i
        i32.const 1
        i32.add
        local.set $i

        br $l
      end
    end

    i32.const 1
    local.set $subListSize
    loop $lSmallToLargeSubLists ;; loop over increasingly large sublists
      local.get $subListSize
      local.get $handCount
      i32.lt_u
      if
        local.get $sortPointer
        local.set $i
        loop $lOverSublists
          local.get $i
          local.get $subListSize
          i32.const 2
          i32.mul
          i32.add
          local.get $mergeSpacePointer
          i32.lt_u
          if
            local.get $subListSize
            local.set $bArrayLen

            local.get $i
            local.get $subListSize
            i32.const 4
            i32.mul
            i32.add
            local.get $mergeSpacePointer
            i32.ge_u
            if
              local.get $mergeSpacePointer
              local.get $subListSize
              i32.const 2
              i32.mul
              i32.sub
              local.get $i
              i32.sub
              i32.const 2
              i32.div_u
              local.set $bArrayLen
            end

            local.get $i
            local.get $subListSize
            local.get $bArrayLen
            local.get $mergeSpacePointer
            call $mergeSubArrays
            
            local.get $i
            local.get $subListSize
            i32.const 4
            i32.mul
            i32.add
            local.set $i
            br $lOverSublists
          end
        end

        local.get $subListSize
        i32.const 2
        i32.mul
        local.set $subListSize
        
        br $lSmallToLargeSubLists
      end
    end
  )

  (func $totalWinnings (result i32)
    (local $handCount i32)
    (local $sortPointer i32)
    (local $i i32)
    (local $total i32)

    i32.const 0
    i32.load16_u
    local.set $handCount

    i32.const 16 ;; size of hand struct
    local.get $handCount
    i32.mul
    i32.const 8 ;; offset to first hand
    i32.add
    local.set $sortPointer

    loop $l
      local.get $i
      local.get $handCount
      i32.lt_u
      if
        ;; load bid
        local.get $i
        i32.const 2
        i32.mul
        local.get $sortPointer
        i32.add
        i32.load16_u
        i32.const 16
        i32.mul
        i32.const 14 ;; offset to first value - 8 offset to first hand + 8 inside hand struct
        i32.add
        i32.load16_u

        local.get $i
        i32.const 1
        i32.add
        i32.mul

        local.get $total
        i32.add
        local.set $total
      
        local.get $i
        i32.const 1
        i32.add
        local.set $i

        br $l
      end
    end
    local.get $total
  )
  
  (func (export "compute") (result i32)
    call $valueHands
    call $sortHands
    call $totalWinnings
  )
)
