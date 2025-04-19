return {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = function(bufnr, on_dir)
        local cmd = { 'go', 'list', '-m', '-json' }
        vim.system(cmd, { text = true }, function(output)
            if output.code == 0 and output.stdout then
                local json = vim.json.decode(output.stdout)
                if json and json.Dir then
                    on_dir(json.Dir)
                    return
                end
            end
            -- Fallback to current directory if module root not found
            on_dir(vim.fn.getcwd())
        end)
    end,
    settings = {
        gopls = {
            -- Analysis settings
            analyses = {
                -- These are not enabled by default
                asmdecl = true,              -- Check assembly declarations
                assign = true,               -- Check for useless assignments
                atomic = true,               -- Check for common mistakes using sync/atomic
                bools = true,                -- Check for common mistakes with boolean operators
                buildtag = true,             -- Check that +build tags are well-formed
                cgocall = true,              -- Check for mistakes in cgo calls
                composites = true,           -- Check for unkeyed composite literals
                copylocks = true,            -- Check for locks erroneously passed by value
                deepequalerrors = true,      -- Check for calls of reflect.DeepEqual on error values
                embed = true,                -- Check for //go:embed directives
                errorsas = true,             -- Check that errors.As is used correctly
                httpresponse = true,         -- Check for mistakes using HTTP responses
                ifaceassert = true,          -- Check for impossible interface-to-interface type assertions
                loopclosure = true,          -- Check for references to enclosing loop variables
                lostcancel = true,           -- Check for context.WithCancel not being called
                nilfunc = true,              -- Check for useless comparisons between functions and nil
                nilness = true,              -- Check for redundant or impossible nil comparisons
                printf = true,               -- Check consistency of Printf format strings and arguments
                shadow = true,               -- Check for possible unintended shadowing of variables
                shift = true,                -- Check for shifts that equal or exceed the width of the integer
                simplifycompositelit = true, -- Check for composite literal simplifications
                simplifyrange = true,        -- Check for range loop simplifications
                simplifyslice = true,        -- Check for slice simplifications
                sortslice = true,            -- Check for calls to sort.Slice that do not use a slice type
                stdmethods = true,           -- Check for misspellings in standard library method names
                stringintconv = true,        -- Check for string(int) conversions
                structtag = true,            -- Check that struct field tags conform to reflect.StructTag.Get
                testinggoroutine = true,     -- Check for common mistakes in goroutines started by tests
                tests = true,                -- Check for common mistakes in tests
                timeformat = true,           -- Check for common mistakes in time.Format calls
                unmarshal = true,            -- Check for passing non-pointer or non-interface values to unmarshal
                unreachable = true,          -- Check for unreachable code
                unsafeptr = true,            -- Check for invalid uses of unsafe.Pointer
                unusedparams = true,         -- Check for unused parameters
                unusedresult = true,         -- Check for unused results of calls to certain functions
                unusedwrite = true,          -- Check for unused writes
                useany = true,               -- Check for use of interface{} instead of any
            },

            -- Static analysis
            staticcheck = true, -- Run staticcheck analyses

            -- Completion settings
            completeUnimported = true,      -- Complete unimported packages
            completionDocumentation = true, -- Show documentation in completion items

            -- Diagnostic settings
            diagnosticsDelay = "250ms",  -- Delay before showing diagnostics
            diagnosticsTrigger = "Save", -- When to show diagnostics: "Save" or "Change"

            -- Formatting settings
            gofumpt = true, -- Use gofumpt for formatting

            -- Hover settings
            hoverKind = "FullDocumentation", -- "NoDocumentation", "SynopsisDocumentation", "FullDocumentation"

            -- Semantic highlighting
            semanticTokens = true, -- Enable semantic highlighting

            -- Symbol settings
            symbolMatcher = "fuzzy", -- "fuzzy" or "caseSensitive"
            symbolStyle = "dynamic", -- "dynamic" or "static"

            -- Template settings
            templateExtensions = { "tmpl", "gotmpl" }, -- Additional template extensions

            -- Code lens settings
            codelenses = {
                gc_details = true,      -- Show GC details
                regenerate_cgo = true,  -- Regenerate cgo
                run_govulncheck = true, -- Run govulncheck
                test = true,            -- Run tests
                tidy = true,            -- Run go mod tidy
            },

            -- Directory filters
            directoryFilters = { "-.git", "-node_modules" },

            -- Links settings
            linksInHover = true, -- Show links in hover

            -- Vulncheck settings
            vulncheck = "Imports", -- "Imports" or "Off"
        }
    },
}
