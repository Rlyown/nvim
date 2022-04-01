local refactoring_status_ok, refactoring = pcall(require, "refactoring")
if not refactoring_status_ok then
	return
end

refactoring.setup()
