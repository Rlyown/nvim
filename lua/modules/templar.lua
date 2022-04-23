local templar_status_ok, templar = pcall(require, "templar")
if not templar_status_ok then
	return
end

-- If a file doesn't have extension, the template name should add '.' to filename tail
-- example:
--         fullname '.clang-tidy' -> template name '.clang-tidy.'

-- lua pattern, but * will be replaced to .* automatically
-- and pattern will be used for template filename, so set alias to deal with it
templar.register(".clang%-tidy", ".clang-tidy")
templar.register(".clang%-format", ".clang-format")
