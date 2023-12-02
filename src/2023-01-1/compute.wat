(module
  (memory (export "mem") 1)

  (func (export "calculate") (param $byteLength i32) (result i32)
    (local $sum i32)
    (local $seenNum i32)
    (local $firstNum i32)
    (local $lastNum i32)
    (local $i i32)
    (local $char i32)

    (loop $loop
      (if (i32.lt_u (local.get $i) (local.get $byteLength))
        (then
          (local.tee $char (i32.load8_u (local.get $i)))
          (if (i32.and (i32.eq (i32.const 10)) (local.get $seenNum))
            (then
              (local.set $sum
                (i32.add
                  (local.get $sum)
                  (i32.add
                    (i32.mul
                      (local.get $firstNum)
                      (i32.const 10)
                    )
                    (local.get $lastNum)
                  )
                )
              )
              (local.set $seenNum (i32.const 0))
            )
            (else
              (if (i32.and (i32.ge_u (local.get $char) (i32.const 48)) (i32.le_u (local.get $char) (i32.const 57)))
                (then
                  (local.set $lastNum (i32.sub (local.get $char) (i32.const 48)))
                  (if (local.get $seenNum)
                    (then)
                    (else
                      (local.set $firstNum (local.get $lastNum))
                      (local.set $seenNum (i32.const 1))
                    )
                  )
                )
              )
            )
          ) 
          (local.set $i (i32.add (local.get $i) (i32.const 1)))
          (br $loop)
        )
      )
    )
 
    (local.get $sum)
  )
)
