require 'test_helper'

class DatabaseCheckMailerTest < ActionMailer::TestCase
  test "consistency" do
    @expected.subject = 'DatabaseCheckMailer#consistency'
    @expected.body    = read_fixture('consistency')
    @expected.date    = Time.now

    assert_equal @expected.encoded, DatabaseCheckMailer.create_consistency(@expected.date).encoded
  end

  test "nagging" do
    @expected.subject = 'DatabaseCheckMailer#nagging'
    @expected.body    = read_fixture('nagging')
    @expected.date    = Time.now

    assert_equal @expected.encoded, DatabaseCheckMailer.create_nagging(@expected.date).encoded
  end

end
