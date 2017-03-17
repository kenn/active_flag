# ActiveFlag - Bit array for ActiveRecord

[![Build Status](https://travis-ci.org/kenn/active_flag.svg)](https://travis-ci.org/kenn/active_flag)

Store up to 64 multiple flags ([bit array](https://en.wikipedia.org/wiki/Bit_array)) in a single integer column with ActiveRecord. From a UI standpoint, it can be used as a  multi-select checkbox storage.

Perfect solution to store multiple boolean values such as preferences, notification settings, achievement status, profile options, etc. in a single column.

* **Single column to group multiple boolean values.** You don't need to have many separate columns. You don't even need a migration when you add a new flag item to the list.
* **Fast bitwise operations.** `WHERE languages & 3 > 0` is faster than `WHERE (english = true) OR (spanish = true) OR ...`

## Usage

```ruby
class Profile < ActiveRecord::Base
  flag :languages, [:english, :spanish, :chinese, :french, :japanese]
end

# Instance methods
profile.languages                           #=> #<ActiveFlag::Value: {:english, :japanese}>
profile.languages.english?                  #=> true
profile.languages.set(:spanish)
profile.languages.unset(:japanese)
profile.languages.raw                       #=> 3
profile.languages.to_a                      #=> [:english, :spanish]

profile.languages = [:spanish, :japanese]   # Direct assignment that works with forms

# Class methods
Profile.where_languages(:french, :spanish)  #=> SELECT * FROM profiles WHERE languages & 10 > 0
Profile.languages.maps                      #=> {:english=>1, :spanish=>2, :chinese=>4, :french=>8, :japanese=>16 }
Profile.languages.set_all!(:chinese)        #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) | 4
Profile.languages.unset_all!(:chinese)      #=> UPDATE "profiles" SET languages = COALESCE(languages, 0) & ~4
```

## Install

```ruby
gem 'active_flag'
```

### Migration

Always set `0` as a default.

```ruby
t.integer :languages,                    null: false, default: 0, limit: 8
# OR
add_column :users, :languages, :integer, null: false, default: 0, limit: 8
```

`limit: 8` is only required if you need more than 32 flags.

## Query

For a querying purpose, use `where_[column]` scope.

```ruby
Profile.where_languages(:french)            #=> SELECT * FROM profiles WHERE languages = 8
```

Also takes multiple values.

```ruby
Profile.where_languages(:french, :spanish)  #=> SELECT * FROM profiles WHERE languages & 10 > 0
```

By default, it searches with `or` operation, so the query above returns profiles that have either French or Spanish.

If you want to change it to `and` operation, you can specify:

```ruby
Profile.where_languages(:french, :spanish, op: :and)
```

## Translation

`ActiveFlag` supports [i18n](http://guides.rubyonrails.org/i18n.html) just as ActiveModel does.

For instance, create a Japanese translation in `config/locales/ja.yml`

```yaml
ja:
  active_flag:
    profile:
      languages:
        english: 英語
        spanish: スペイン語
        chinese: 中国語
        french: フランス語
        japanese: 日本語
```

and now `to_human` method returns a translated string.

```ruby
I18n.locale = :ja
profile.languages.to_human  #=> ['英語', 'スペイン語']

I18n.locale = :en
profile.languages.to_human  #=> ['English', 'Spanish']
```

## Forms

Thanks to the translation support, forms just work as you would expect with the `pairs` convenience method.

```ruby
# With FormBuilder
= form_for(@profile) do |f|
  = f.collection_check_boxes :languages, Profile.languages.pairs

# With SimpleForm
= simple_form_for(@profile) do |f|
  = f.input :languages, as: :check_boxes, collection: Profile.languages.pairs
```

## Other solutions

There are plenty of gems that share the same goal. However they have messy syntax than necessary in my opinion, and I wanted a better API to achieve that goal.

- [bitfields](https://github.com/grosser/bitfields)
- [flag_shih_tzu](https://github.com/pboling/flag_shih_tzu)

Also, `ActiveFlag` has one of the simplest code base that you can easily reason about or hack on.
