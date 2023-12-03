(module
  (import "reader" "nextGame" (func $nextGame (result i32)))
  (import "reader" "nextDraw" (func $nextDraw (result i32) (result i32) (result i32)))

  (func (export "compute") (result i32)
    (local $sum i32)
    (local $gameId i32)
    (local $drawRed i32)
    (local $drawGreen i32)
    (local $drawBlue i32)
    (loop $gameLoop
      (local.set $gameId (call $nextGame))
      (if (i32.ne (local.get $gameId) (i32.const -1))
        (then
          (loop $drawLoop
            (call $nextDraw)
            (local.set $drawBlue)
            (local.set $drawGreen)
            (local.set $drawRed)
            (br_if $gameLoop
              (i32.or
                (i32.gt_s (local.get $drawRed) (i32.const 12))
                (i32.or
                  (i32.gt_s (local.get $drawGreen) (i32.const 13))
                  (i32.gt_s (local.get $drawBlue) (i32.const 14))
                )
              )
            )
            (if (i32.eq (local.get $drawRed) (i32.const -1))
              (then
                (local.set $sum (i32.add (local.get $sum) (local.get $gameId)))
                (br $gameLoop)
              )
            )
            (br $drawLoop)
          )
          (br $gameLoop)
        )
      )
    )
  (return (local.get $sum))
  )
)
