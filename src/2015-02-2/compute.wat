(module
  (memory (export "mem") 1)

  (func $smallestEdges (param $x i32) (param $y i32) (param $z i32) (result i32) (result i32)
    (if (i32.and (i32.ge_u (local.get $x) (local.get $y)) (i32.ge_u (local.get $x) (local.get $z)))
      (then
        (return (local.get $y) (local.get $z))
      )
      (else
        (if (i32.ge_u (local.get $y) (local.get $z))
          (then
            (return (local.get $x) (local.get $z))
          )
        )
      )
    )
    (return (local.get $x) (local.get $y))
  )

  (func $calculateSingle (param $x i32) (param $y i32) (param $z i32) (result i32)
    (i32.add
      (i32.mul
        (i32.mul (local.get $x) (local.get $y))
        (local.get $z)
      )
      (i32.mul
        (i32.add
          (call $smallestEdges (local.get $x) (local.get $y) (local.get $z))
        )
        (i32.const 2)
      )
    )
  )

  (func (export "calculate") (param $length i32) (result i32)
    (local $sum i32)
    (local $index i32)

    (loop $loop
      (if (i32.lt_u (local.get $index) (local.get $length))
        (then
          (local.set $sum (i32.add (local.get $sum)
            (call $calculateSingle
              (i32.load8_s (i32.mul (i32.const 3) (local.get $index)))
              (i32.load8_s (i32.add (i32.mul (i32.const 3) (local.get $index)) (i32.const 1)))
              (i32.load8_s (i32.add (i32.mul (i32.const 3) (local.get $index)) (i32.const 2)))
            )
          ))
          (local.set $index (i32.add (local.get $index) (i32.const 1)))
          (br $loop)
        )
      )
    )

    (local.get $sum)
  )
)
