require "application_system_test_case"

class ChallengeFlowTest < ApplicationSystemTestCase
  test "criar sala, convidar e fazer check-in em dupla" do
    # Gui cria a sala (o formulário de login não tem labels — achar pelo tipo/name do input)
    visit new_challenge_path
    find("input[type=email]").set(users(:gui).email)
    click_on "Me manda o código"
    find("input[name=code]").set(MagicLink.last.code)
    click_on "Entrar"

    fill_in "O desafio", with: "Beber 2L de água"
    fill_in "Quantos dias", with: 21
    fill_in "Começa em", with: Date.current
    fill_in "Seu nome no desafio", with: "Gui"
    click_on "Criar e pegar o link"

    assert_text "Beber 2L de água"
    invite_url = find("code").text

    # Gui marca o dia
    click_on "Fiz hoje ✓"
    assert_selector ".today li.is-done", text: "Gui"

    # Ana entra pelo link em outro navegador
    using_session :ana do
      visit invite_url
      fill_in "Como você quer ser chamado?", with: "Ana"
      click_on "Entrar no desafio"

      assert_text "Beber 2L de água"
      click_on "Fiz hoje ✓"
      assert_selector ".today li.is-done", text: "Ana"
    end

    # Gui vê a Ana na sala (via broadcast ou reload)
    visit current_path
    assert_selector ".today li.is-done", text: "Ana"
  end
end
