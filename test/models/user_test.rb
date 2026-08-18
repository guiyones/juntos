require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normaliza o email" do
    user = User.create!(email: "  GUI+Novo@Example.COM ")
    assert_equal "gui+novo@example.com", user.email
  end

  test "exige email com formato válido" do
    assert_not User.new(email: "nao-e-email").valid?
    assert_not User.new(email: "").valid?
  end

  test "email é único" do
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(email: users(:gui).email)
    end
  end
end
