require 'test_helper'

class ActiveFlagTest < Minitest::Test
  def setup
    @profile = Profile.first
  end

  def test_predicate
    assert @profile.languages.english?
    refute @profile.languages.chinese?
  end

  def test_set_and_unset?
    assert @profile.languages.set?(:english)
    assert @profile.languages.unset?(:chinese)
  end

  def test_set_and_unset
    @profile.languages.set(:chinese)
    assert @profile.languages.chinese?

    @profile.languages.unset(:chinese)
    refute @profile.languages.chinese?
  end

  def test_set_and_unset!
    @profile.languages.set!(:chinese)
    assert Profile.first.languages.chinese?

    @profile.languages.unset!(:chinese)
    refute Profile.first.languages.chinese?
  end

  def test_direct_assign
    @profile.languages = [:french, :japanese]
    assert @profile.languages.french?
    assert @profile.languages.japanese?
  end

  def test_raw
    assert_equal @profile.languages.raw, 1

    @profile.languages.set(:spanish)
    assert_equal @profile.languages.raw, 3

    @profile.languages.set(:chinese)
    assert_equal @profile.languages.raw, 7
  end

  def test_to_s
    assert_equal @profile.languages.to_s, '[:english]'
  end

  def test_locale
    @profile.languages.set(:spanish)

    I18n.locale = :ja
    assert_equal ['英語', 'スペイン語'], @profile.languages.to_human

    I18n.locale = :en
    assert_equal ['English', 'Spanish'], @profile.languages.to_human
  end

  def test_set_all_and_unset_all
    Profile.languages.set_all!(:chinese)
    assert Profile.first.languages.chinese?

    Profile.languages.unset_all!(:chinese)
    refute Profile.first.languages.chinese?
  end

  def test_multiple_flags
    assert Profile.languages
    assert Profile.others
  end

  def test_subclass
    assert_equal SubProfile.languages.keys, Profile.languages.keys
    assert_raises { SubProfile.flag :languages, [:english] }
  end

  def test_same_column_in_other_class
    assert_equal Profile.others.keys, [:thing]
    assert_equal Other.others.keys, [:another]
  end
end
