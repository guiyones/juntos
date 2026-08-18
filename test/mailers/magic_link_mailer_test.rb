require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "código vai no assunto e no corpo" do
    magic_link = users(:gui).magic_links.create!
    email = MagicLinkMailer.sign_in_code(magic_link)

    assert_equal [ users(:gui).email ], email.to
    assert_includes email.subject, magic_link.code
    assert_includes email.text_part.body.to_s, magic_link.code
    assert_includes email.html_part.body.to_s, magic_link.code
  end

  test "send_magic_link cria o código e enfileira o email" do
    assert_difference -> { users(:gui).magic_links.count } do
      assert_enqueued_emails 1 do
        users(:gui).send_magic_link
      end
    end
  end
end
