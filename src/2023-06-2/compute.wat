(module
  (func (export "compute") (param $time f64) (param $record f64) (result f64)
    (local $mid f64) ;; t/2
    (local $+- f64) ;; sqrt(t * t - 4 r) / 2
    (local $xraw f64)
    (local $xmin f64) ;; the minimum integer time that wins
    (local $xmax f64) ;; the maximum integer time that wins

    local.get $time
    f64.const 2
    f64.div
    local.set $mid

    local.get $time
    local.get $time
    f64.mul
    f64.const 4
    local.get $record
    f64.mul
    f64.sub
    f64.sqrt
    f64.const 2
    f64.div
    local.set $+-

    local.get $mid
    local.get $+-
    f64.sub
    local.tee $xraw
    local.get $xraw
    f64.floor
    f64.eq
    if
      local.get $xraw
      f64.const 1
      f64.add
      local.set $xmin
    else
      local.get $xraw
      f64.ceil
      local.set $xmin
    end

    local.get $mid
    local.get $+-
    f64.add
    local.tee $xraw
    local.get $xraw
    f64.floor
    f64.eq
    if
      local.get $xraw
      f64.const 1
      f64.sub
      local.set $xmax
    else
      local.get $xraw
      f64.floor
      local.set $xmax
    end

    local.get $xmax
    local.get $xmin
    f64.lt
    if
      f64.const 0
      return
    end
    local.get $xmax
    local.get $xmin
    f64.sub
    f64.const 1
    f64.add    
  )
)
