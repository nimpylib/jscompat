


when defined(js):
  import ./dispatch
  const DenoDetectedJsExpr* = !notDenoInJs
  when defined(nodejs):
    let inDeno* = false
  else:
    let inDeno* = not notDeno


