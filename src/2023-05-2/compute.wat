(module
  (memory (export "mem") 1)

  (func $traverseRange (param $seed i64) (param $range i64) (param $rangePointer i32) (result i64) (result i64) (result i32)
    (local $output i64)
    (local $ranges i64)
    (local $sourceRangeStart i64)
    (local $destinationRangeStart i64)
    (local $rangeLength i64)
    (local $seedClearance i64)

    local.get $seed
    local.set $output

    local.get $rangePointer
    i64.load
    local.set $ranges

    local.get $rangePointer
    i32.const 8
    i32.add
    local.set $rangePointer

    loop $l
      local.get $ranges
      i64.const 0
      i64.gt_u
      if
        local.get $rangePointer
        i64.load
        local.set $destinationRangeStart

        local.get $rangePointer
        i32.const 8
        i32.add
        i64.load
        local.set $sourceRangeStart

        local.get $rangePointer
        i32.const 16
        i32.add
        i64.load
        local.set $rangeLength

        ;; seed >= sourceRangeStart && seed < sourceRangeStart + rangeLength
        local.get $seed
        local.get $sourceRangeStart
        i64.ge_u

        local.get $seed
        local.get $sourceRangeStart
        local.get $rangeLength
        i64.add
        i64.lt_u

        i32.and
        if
          ;; range = min(range, rangeLength + sourceRangeStart - seed)
          local.get $rangeLength
          local.get $sourceRangeStart
          i64.add
          local.get $seed
          i64.sub
          local.tee $seedClearance
          local.get $range
          i64.lt_s
          if
            local.get $seedClearance
            local.set $range
          end

          ;; output = seed + destinationRangeStart - sourceRangeStart
          local.get $seed
          local.get $destinationRangeStart
          i64.add
          local.get $sourceRangeStart
          i64.sub
          local.set $output

        end
      
        local.get $ranges
        i64.const 1
        i64.sub
        local.set $ranges

        local.get $rangePointer
        i32.const 24
        i32.add
        local.set $rangePointer
        
        br $l
      end
    end

    local.get $output
    local.get $range
    local.get $rangePointer
  )

  (func (export "compute") (param $seed i64) (param $range i64) (result i64) (result i64)
    (local $numOfMaps i64)
    (local $mapPointer i32)
    i32.const 0
    i64.load
    local.set $numOfMaps

    i32.const 8
    local.set $mapPointer

    loop $l
      local.get $numOfMaps
      i64.const 0
      i64.gt_u
      if
        local.get $seed
        local.get $range
        local.get $mapPointer
        call $traverseRange
        local.set $mapPointer
        local.set $range
        local.set $seed
      
        local.get $numOfMaps
        i64.const 1
        i64.sub
        local.set $numOfMaps
        br $l
      end
    end
    
    local.get $seed
    local.get $range
  )
)
