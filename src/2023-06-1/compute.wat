(module
  (func (export "compute") (param $time f32) (param $record f32) (result f32)
    (local $mid f32) ;; t/2
    (local $+- f32) ;; sqrt(t * t - 4 r) / 2
    (local $xraw f32)
    (local $xmin f32) ;; the minimum integer time that wins
    (local $xmax f32) ;; the maximum integer time that wins

    local.get $time
    f32.const 2
    f32.div
    local.set $mid

    local.get $time
    local.get $time
    f32.mul
    f32.const 4
    local.get $record
    f32.mul
    f32.sub
    f32.sqrt
    f32.const 2
    f32.div
    local.set $+-

    local.get $mid
    local.get $+-
    f32.sub
    local.tee $xraw
    local.get $xraw
    f32.floor
    f32.eq
    if
      local.get $xraw
      f32.const 1
      f32.add
      local.set $xmin
    else
      local.get $xraw
      f32.ceil
      local.set $xmin
    end

    local.get $mid
    local.get $+-
    f32.add
    local.tee $xraw
    local.get $xraw
    f32.floor
    f32.eq
    if
      local.get $xraw
      f32.const 1
      f32.sub
      local.set $xmax
    else
      local.get $xraw
      f32.floor
      local.set $xmax
    end

    local.get $xmax
    local.get $xmin
    f32.lt
    if
      f32.const 0
      return
    end
    local.get $xmax
    local.get $xmin
    f32.sub
    f32.const 1
    f32.add    
  )
)
