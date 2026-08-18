require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  test "gera código de 6 dígitos e expiração ao criar" do
    magic_link = users(:gui).magic_links.create!

    assert_match(/\A\d{6}\z/, magic_link.code)
    assert_in_delta 15.minutes.from_now, magic_link.expires_at, 5.seconds
  end

  test "consume devolve o link ativo e o destrói" do
    magic_link = users(:gui).magic_links.create!

    consumed = MagicLink.consume(magic_link.code)

    assert_equal magic_link, consumed
    assert_not MagicLink.exists?(magic_link.id)
  end

  test "consume ignora código vencido" do
    magic_link = users(:gui).magic_links.create!

    travel 16.minutes do
      assert_nil MagicLink.consume(magic_link.code)
    end
  end

  test "consume ignora código inexistente" do
    assert_nil MagicLink.consume("000000")
  end
end
