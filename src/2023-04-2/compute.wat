(module
  (memory (export "mem") 1)

  (func $parseNumbers (param $i i32) (result i32) (result i64) (result i64) 
    (local $bitArrA i64)
    (local $bitArrB i64)
    (local $current i32)
    (local $char i32)
    (local $readNumber i32)

    (loop $l
      local.get $i
      i32.load8_u

      ;; Read a digit
      local.tee $char
      i32.const 0x30
      i32.ge_u
      local.get $char
      i32.const 0x3A
      i32.lt_u
      i32.and
      if
        i32.const 1
        local.set $readNumber

        local.get $current
        i32.const 10
        i32.mul
        local.get $char
        i32.const 0x30
        i32.sub
        i32.add
        local.set $current
        i32.const 1
        local.get $i
        i32.add
        local.set $i
        br $l
      else
        local.get $readNumber
        if
          local.get $current
          i32.const 64
          i32.lt_u
          if
            i64.const 1
            local.get $current
            i64.extend_i32_u
            i64.shl
            local.get $bitArrA
            i64.or
            local.set $bitArrA
          else
            i64.const 1
            local.get $current
            i32.const 64
            i32.sub
            i64.extend_i32_u
            i64.shl
            local.get $bitArrB
            i64.or
            local.set $bitArrB
          end

          i32.const 0
          local.set $readNumber
          i32.const 0
          local.set $current
        end
        ;; continue if space
        local.get $char
        i32.const 0x20
        i32.eq
        if
          i32.const 1
          local.get $i
          i32.add
          local.set $i
          br $l
        end
      end
    )
    local.get $i
    local.get $bitArrA
    local.get $bitArrB
  )

  (func $parseGame (param $i i32) (result i32) (result i32)
    (local $count i32)
    (local $nums1BitArrA i64)
    (local $nums1BitArrB i64)
    ;; advance to :
    (loop $l
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (i32.ne (i32.const 0x3A) (i32.load8_u (local.get $i)))
      br_if $l
    )
    local.get $i
    i32.const 1
    i32.add
    call $parseNumbers
    local.set $nums1BitArrA
    local.set $nums1BitArrB
    i32.const 1
    i32.add
    call $parseNumbers
    local.get $nums1BitArrA
    i64.and
    i64.popcnt
    i32.wrap_i64
    local.set $count
    local.get $nums1BitArrB
    i64.and
    i64.popcnt
    i32.wrap_i64
    local.get $count
    i32.add
    local.set $count

    ;; inc i
    i32.const 1
    i32.add

    local.get $count
  )

  (func $storeFutureGameCount (param $j i32) (param $nums i32) (param $gameCopies i32)
    (local $k i32)
    local.get $nums
    local.get $j
    i32.add
    local.set $k

    loop $l
      local.get $k
      local.get $j
      i32.ne
      if
        local.get $k
        i32.const 4
        i32.mul
        local.get $k
        i32.const 4
        i32.mul
        i32.load
        local.get $gameCopies
        i32.add
        i32.store

        local.get $k
        i32.const 1
        i32.sub
        local.set $k
        br $l
      end
    end
  )

  (func (export "compute") (param $length i32) (result i32)
    (local $sum i32)
    (local $i i32)
    (local $j i32)
    (local $gameCopies i32)
    (local $nums i32)
    local.get $length
    i32.const 3
    i32.add
    i32.const 4
    i32.div_u
    local.set $j
    (loop $l
      local.get $i
      local.get $length
      i32.lt_u
      (if
        (then
          local.get $i
          call $parseGame
          local.set $nums
          local.set $i

          local.get $j
          i32.const 4
          i32.mul
          i32.load
          i32.const 1
          i32.add

          local.tee $gameCopies
          local.get $sum
          i32.add
          local.set $sum

          local.get $j
          local.get $nums
          local.get $gameCopies
          call $storeFutureGameCount

          local.get $j
          i32.const 1
          i32.add
          local.set $j
          br $l
        )
      )
    )
    (return (local.get $sum))
  )
)
