# active_flag v2.1.0 Cleanup Plan

## Files to Modify

### 1. `lib/active_flag/definition.rb`

- `Hash[keys.map.with_index{...}]` → `keys.map.with_index{...}.to_h`

### 2. `lib/active_flag/value.rb`

- Add `respond_to_missing?` to match `method_missing` (so `respond_to?(:english?)` works)

### 3. `lib/active_flag/railtie.rb`

- Remove unused `|app|` block param

### 4. `active_flag.gemspec`

- Remove `# coding: utf-8` (unnecessary since Ruby 2.0)
- `File.expand_path('../lib', __FILE__)` → `File.expand_path('lib', __dir__)`
- Remove `logger` from dev deps (stdlib)
- Remove `bundler` from dev deps (assumed)

### 5. `test/load_fixtures.rb`

- `File.dirname(__FILE__)` → `__dir__`

### 6. `test/active_flag_test.rb`

- Fix `assert @profile.languages, 0` → `assert_equal 0, @profile.languages.raw` (2 occurrences)
- Add `test_respond_to` for `respond_to_missing?`

### 7. `Rakefile`

- `task :default => :test` → `task default: :test`

### 8. `gemfiles/7.2.gemfile`

- `~> 7.0.0` → `~> 7.2.0` (matches CI matrix)

### 9. `lib/active_flag/version.rb`

- Bump `VERSION = '2.0.3'` → `'2.1.0'`

## Not Changing (would be breaking or adds implicit requirements)

- `options={}` → `**options` in value.rb and definition.rb (breaking for positional hash callers)
- `and` → `&&` in method_missing (needs rewrite, save for later)
- Ruby/Rails version requirements (keep >= 5 for AR)
- `s && @maps[...]` guard (protects against nil/false)
- `map{...}.compact` → `filter_map` (requires Ruby 2.7+)
- `bin/setup` noise (optional, leave as-is)
