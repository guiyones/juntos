class ChallengesController < ApplicationController
  before_action :require_authentication, only: %i[ new create ]

  def index
  end

  def new
  end

  def create
  end
end
