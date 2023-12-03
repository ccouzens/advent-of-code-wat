(module
  (memory (export "mem") 1)

  ;; Read a cell of memory.
  ;; Out of bounds and `.` will be read as 10.
  ;; Digits will be read as their digit value.
  ;; Symbols will be read as 11.
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
    (if (i32.eq (local.get $char) (i32.const 0x2E))
      (then (return (i32.const 10)))
    )

    (i32.ge_u (local.get $char) (i32.const 0x30))
    (i32.lt_u (local.get $char) (i32.const 0x3A))
    i32.and

    (if
      (then (return (i32.sub (local.get $char) (i32.const 0x30))))
    )

    (return (i32.const 11))
  )

  (func $surroundingSymbol (param $width i32) (param $height i32) (param $x i32) (param $y i32) (result i32)
    (local $i i32)
    (loop $loop
      (call $readCell
        (local.get $width)
        (local.get $height)
        (i32.sub (i32.add (local.get $x) (i32.rem_u (local.get $i) (i32.const 3))) (i32.const 1))
        (i32.sub (i32.add (local.get $y) (i32.div_u (local.get $i) (i32.const 3))) (i32.const 1))
      )
      (i32.eq (i32.const 11))
      (if (then (return (i32.const 1))))
    
      (local.tee $i (i32.add (local.get $i) (i32.const 1)))
      (br_if $loop (i32.lt_u (i32.const 9)))
    )
    (return (i32.const 0))
  )
  
  (func (export "compute") (param $width i32) (param $height i32) (result i32)
    (local $sum i32)
    (local $num i32)
    (local $hasSymbol i32)
    (local $x i32)
    (local $y i32)
    (local $current i32)
    (loop $vloop
      (if (i32.lt_s (local.get $y) (local.get $height))
        (then
          (loop $hloop
            (if (i32.lt_s (local.get $x) (local.get $width))
              (then
                (local.set $current (call $readCell (local.get $width) (local.get $height) (local.get $x) (local.get $y)))

                (if (i32.lt_s (local.get $current) (i32.const 10))
                  (then
                    (local.set $num (i32.add (i32.mul (local.get $num) (i32.const 10)) (local.get $current)))
                    (if (local.get $hasSymbol)
                      (then)
                      (else
                        (local.set $hasSymbol (call $surroundingSymbol (local.get $width) (local.get $height) (local.get $x) (local.get $y)))
                      )
                    )
                  )
                )

                (i32.eq (i32.add (local.get $x) (i32.const 1)) (local.get $width))
                (i32.ge_u (local.get $current) (i32.const 10))
                i32.or
                (if
                  (then
                    (if (local.get $hasSymbol)
                      (then
                        (local.set $hasSymbol (i32.const 0))
                        (local.set $sum (i32.add (local.get $num) (local.get $sum)))
                      )
                    )
                    (local.set $num (i32.const 0))
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
