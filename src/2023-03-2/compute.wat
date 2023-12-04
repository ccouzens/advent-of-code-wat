(module
  (memory (export "mem") 1)

  ;; Read a cell of memory.
  ;; Out of bounds and `.` non gear symbols will be read as 10.
  ;; Digits will be read as their digit value.
  ;; Gears will be read as 11.
  (func $readCell (param $width i32) (param $height i32) (param $x i32) (param $y i32) (result i32)
    (local $char i32)
    (i32.lt_s (local.get $x) (i32.const 0))
    (i32.lt_s (local.get $y) (i32.const 0))
    (i32.ge_s (local.get $x) (local.get $width))
    (i32.ge_s (local.get $y) (local.get $height))
    i32.or
    i32.or
    i32.or
    (if
      (then (return (i32.const 10)))
    )
    (local.set $char (i32.load8_u (i32.add (i32.mul (local.get $y) (local.get $width)) (local.get $x))))
    (if (i32.eq (local.get $char) (i32.const 0x2A))
      (then (return (i32.const 11)))
    )

    (i32.ge_u (local.get $char) (i32.const 0x30))
    (i32.lt_u (local.get $char) (i32.const 0x3A))
    i32.and

    (if
      (then (return (i32.sub (local.get $char) (i32.const 0x30))))
    )

    (return (i32.const 10))
  )

  (func $readNum (param $width i32) (param $height i32) (param $x i32) (param $y i32) (result i32)
    (local $digit i32)
    (local $num i32)
    (loop $loop
      (local.set $digit (call $readCell (local.get $width) (local.get $height) (local.get $x) (local.get $y)))
      (if (i32.lt_u (local.get $digit) (i32.const 10))
        (then
          (local.set $num (i32.add (local.get $digit) (i32.mul (local.get $num) (i32.const 10))))
          (local.set $x (i32.add (local.get $x) (i32.const 1)))
          br $loop
        )
      )
    )
    (local.get $num)
  )

  (func $startOfNum (param $width i32) (param $height i32) (param $x i32) (param $y i32) (result i32)
    (loop $loop
      (i32.lt_u
        (call $readCell (local.get $width) (local.get $height) (i32.sub (local.get $x) (i32.const 1)) (local.get $y))
        (i32.const 10)
      )
      (if
        (then
          (local.set $x (i32.sub (local.get $x) (i32.const 1)))
          br $loop
        )
      )
    )
    local.get $x
  )

  (func $gearRatio (param $width i32) (param $height i32) (param $x i32) (param $y i32) (result i32)  
    (local $firstNumFound i32)
    (local $firstNumX i32)
    (local $firstNumY i32)
    (local $lastNumFound i32)
    (local $lastNumX i32)
    (local $lastNumY i32)
    (local $i i32)
    (local $dx i32)

    (loop $loop
      (if (i32.eq (local.get $firstNumFound) (i32.const 0))
        (then
          (local.set $dx (i32.sub (i32.add (local.get $x) (i32.rem_u (local.get $i) (i32.const 3))) (i32.const 1)))
          (local.set $firstNumY (i32.sub (i32.add (local.get $y) (i32.div_u (local.get $i) (i32.const 3))) (i32.const 1)))
          (i32.lt_u
            (call $readCell
              (local.get $width) (local.get $height) (local.get $dx) (local.get $firstNumY)
            )
            (i32.const 10)
          )
          (if 
            (then
              (local.set $firstNumFound (i32.const 1))
              (local.set $firstNumX (call $startOfNum 
                (local.get $width) (local.get $height) (local.get $dx) (local.get $firstNumY)
              ))
            )
          )
        )
      )
      (if (i32.eq (local.get $lastNumFound) (i32.const 0))
        (then
          (local.set $dx (i32.add (local.get $x) (i32.sub (i32.const 1) (i32.rem_u (local.get $i) (i32.const 3)))))
          (local.set $lastNumY (i32.add (local.get $y) (i32.sub (i32.const 1) (i32.div_u (local.get $i) (i32.const 3)))))
          (i32.lt_u
            (call $readCell
              (local.get $width) (local.get $height) (local.get $dx) (local.get $lastNumY)
            )
            (i32.const 10)
          )
          (if 
            (then
              (local.set $lastNumFound (i32.const 1))
              (local.set $lastNumX (call $startOfNum 
                (local.get $width) (local.get $height) (local.get $dx) (local.get $lastNumY)
              ))
            )
          )
        )
      )
    
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $loop (i32.lt_u (i32.const 9)))
    )
    local.get $firstNumFound
    local.get $lastNumFound
    i32.and
    local.get $firstNumX
    local.get $lastNumX
    i32.ne
    local.get $firstNumY
    local.get $lastNumY
    i32.ne
    i32.or
    i32.and
    (if
      (then
        (call $readNum (local.get $width) (local.get $height) (local.get $firstNumX) (local.get $firstNumY))
        (call $readNum (local.get $width) (local.get $height) (local.get $lastNumX) (local.get $lastNumY))
        (return (i32.mul))
      )
    )
    i32.const 0
  )

  (func (export "compute") (param $width i32) (param $height i32) (result i32)
    (local $sum i32)
    (local $x i32)
    (local $y i32)
    (loop $vloop
      (if (i32.lt_s (local.get $y) (local.get $height))
        (then
          (loop $hloop
            (if (i32.lt_s (local.get $x) (local.get $width))
              (then
                (call $readCell (local.get $width) (local.get $height) (local.get $x) (local.get $y))
                (if (i32.eq (i32.const 11))
                  (then
                    (local.set $sum (i32.add (local.get $sum) (call $gearRatio (local.get $width) (local.get $height) (local.get $x) (local.get $y))))
                  )
                )

                (local.set $x (i32.add (local.get $x) (i32.const 1)))
                br $hloop
              )
            )
          )
          (local.set $x (i32.const 0))
          (local.set $y (i32.add (local.get $y) (i32.const 1)))
          br $vloop
        )
      )
    )
    (return (local.get $sum))
  )
)
