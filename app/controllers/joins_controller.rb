class JoinsController < ApplicationController
  before_action :set_challenge

  def new
    redirect_to @challenge if current_participant_for(@challenge)
  end

  def create
    @challenge.join name: params[:name], person_token: person_token, user: current_user
    redirect_to @challenge
  rescue ActiveRecord::RecordInvalid
    redirect_to join_path(@challenge.token), alert: "Conta pra gente como você quer ser chamado."
  end

  private
    def set_challenge
      @challenge = Challenge.find_by!(token: params[:token])
    end
end
