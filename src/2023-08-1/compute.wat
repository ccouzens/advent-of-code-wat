(module
  (memory (export "mem") 1)

  (func (export "compute")
    (param $instructionCount i32)
    (param $networkCount i32)
    (param $networkIndex i32)
    (param $finalIndex i32)
    (result i32)

    (local $stepCount i32)
    (local $instructionIndex i32)

    loop $moveLoop
      local.get $networkIndex
      local.get $finalIndex
      i32.ne
      if
        i32.const 4 ;; L index in the network struct
        i32.const 6 ;; R Index in the network struct
        local.get $instructionIndex
        i32.load8_u
        i32.const 0x4C ;; L ascii value
        i32.eq
        select
        local.get $networkIndex
        i32.const 8 ;; Size of the network struct
        i32.mul
        i32.add
        local.get $instructionCount
        i32.add
        i32.load16_u
        local.set $networkIndex
        
        local.get $instructionIndex
        i32.const 1
        i32.add
        local.get $instructionCount
        i32.rem_u
        local.set $instructionIndex
      
        local.get $stepCount
        i32.const 1
        i32.add
        local.set $stepCount
        br $moveLoop
      end
    end

    local.get $stepCount
  )
)
