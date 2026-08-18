class ChallengesController < ApplicationController
  before_action :require_authentication, only: %i[ new create ]

  def index
    @active, @finished = my_challenges.partition { |challenge| !challenge.finished? }
  end

  def new
    @challenge = Challenge.new(starts_on: Date.tomorrow, days: 21)
  end

  def create
    @challenge = current_user.challenges.new(challenge_params)

    if @challenge.save
      @challenge.join name: params.expect(:participant_name), person_token: person_token, user: current_user
      redirect_to @challenge
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @challenge = Challenge.find(params[:id])
    @participant = current_participant_for(@challenge)

    redirect_to join_path(@challenge.token) if @participant.nil?
  end

  private
    def challenge_params
      params.expect(challenge: %i[ name starts_on days ])
    end

    def my_challenges
      Challenge.involving(person_token: cookies.signed[:person_token], user: current_user).latest_first
    end
end
