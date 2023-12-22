(module
  (import "js" "logGhostEnd" (func $logGhostEnd (param externref) (param i32) (param i32) (param i64) (param i32)))
  (memory (export "mem") 1)

  (func $initialiseGhosts
    (param $networkPointer i32)
    (param $networkCount i32)
    (param $ghostPointer i32)
    (result i32)

    (local $ghostCount i32)
    (local $networkIndex i32)
    (local $labelPointer i32)

    local.get $networkPointer
    i32.const 2 ;; Offset within struct to 3rd char
    i32.add
    local.set $labelPointer

    loop $l
      local.get $networkIndex
      local.get $networkCount
      i32.lt_u
      if
        local.get $labelPointer
        i32.load8_u
        i32.const 0x41 ;; ASCII A
        i32.eq
        if
          local.get $ghostPointer
          local.get $networkIndex
          i32.store16

          local.get $ghostPointer
          i32.const 2
          i32.add
          local.set $ghostPointer

          local.get $ghostCount
          i32.const 1
          i32.add
          local.set $ghostCount
        end
        
        local.get $labelPointer
        i32.const 8
        i32.add
        local.set $labelPointer

        local.get $networkIndex
        i32.const 1
        i32.add
        local.set $networkIndex
        br $l
      end
    end
    local.get $ghostCount
  )

  (func $advanceGhosts
    (param $instructionIndex i32)
    (param $instructionCount i32)
    (param $networkPointer i32)
    (param $ghostPointer i32)
    (param $ghostCount i32)
    (param $loggerInstance externref)
    (param $stepCount i64)
    (result i32)

    (local $ghostIndex i32)
    (local $moveL i32)
    (local $ghostNetworkIndex i32)
    (local $ghostsFinished i32)

    i32.const 1
    local.set $ghostsFinished

    local.get $instructionIndex
    i32.load8_u
    i32.const 0x4C ;; ASCII L
    i32.eq
    local.set $moveL

    loop $l
      local.get $ghostIndex
      local.get $ghostCount
      i32.lt_u
      if
        local.get $ghostPointer
        local.get $ghostPointer
        i32.load16_u
        i32.const 8
        i32.mul
        i32.const 4 ;; L index in the network struct
        i32.const 6 ;; R Index in the network struct
        local.get $moveL
        select
        i32.add
        local.get $networkPointer
        i32.add
        i32.load16_u
        local.tee $ghostNetworkIndex
        i32.store16

        local.get $ghostNetworkIndex
        i32.const 8
        i32.mul
        i32.const 2 ;; 3rd letter index
        i32.add
        local.get $networkPointer
        i32.add
        i32.load16_u
        i32.const 0x5A ;; ASCII Z
        i32.eq
        if
          local.get $loggerInstance
          local.get $ghostIndex
          local.get $ghostNetworkIndex
          local.get $stepCount
          local.get $instructionIndex
          call $logGhostEnd
        else
          i32.const 0
          local.set $ghostsFinished
        end
      
        local.get $ghostIndex
        i32.const 1
        i32.add
        local.set $ghostIndex

        local.get $ghostPointer
        i32.const 2
        i32.add
        local.set $ghostPointer
        br $l
      end
    end
    local.get $ghostsFinished
  )

  (func (export "compute")
    (param $instructionCount i32)
    (param $networkPointer i32)
    (param $networkCount i32)
    (param $maxSteps i64)
    (param $loggerInstance externref)
    (result i64)

    (local $stepCount i64)
    (local $instructionIndex i32)
    (local $ghostCount i32)
    (local $ghostPointer i32)

    local.get $networkPointer
    local.get $networkCount
    i32.const 8 ;; Size of struct
    i32.mul
    i32.add
    local.set $ghostPointer

    local.get $networkPointer
    local.get $networkCount
    local.get $ghostPointer
    call $initialiseGhosts
    local.set $ghostCount

    i64.const 1
    local.set $stepCount

    loop $moveLoop
      local.get $instructionIndex
      local.get $instructionCount
      local.get $networkPointer
      local.get $ghostPointer
      local.get $ghostCount
      local.get $loggerInstance
      local.get $stepCount
      call $advanceGhosts
      i32.eqz
      
      if
        local.get $instructionIndex
        i32.const 1
        i32.add
        local.get $instructionCount
        i32.rem_u
        local.set $instructionIndex
      
        local.get $stepCount
        i64.const 1
        i64.add
        local.tee $stepCount
        local.get $maxSteps
        i64.lt_u
        br_if $moveLoop
      end
    end

    local.get $stepCount
  )
)
